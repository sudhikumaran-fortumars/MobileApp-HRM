'use strict';
const { onCall } = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getDistance } = require('geolib');


initializeApp();
const db = getFirestore();


function badRequest(message, code = 'invalid-argument') {
const err = new Error(message);
err.code = code;
throw err;
}


// Callable: verify device location against Firestore doc "geofences/{siteId}"
exports.verifyLocation = onCall({ region: 'asia-south1', cors: true }, async (req) => {
try {
const data = req.data || {};
const siteId = String(data.siteId || '').trim();
const lat = Number(data.lat);
const lng = Number(data.lng);
const toleranceMeters = Number.isFinite(data.toleranceMeters) ? Number(data.toleranceMeters) : 25;


if (!siteId) badRequest('siteId is required');
if (!Number.isFinite(lat) || !Number.isFinite(lng)) badRequest('lat and lng are required numbers');


const ref = db.collection('geofences').doc(siteId);
const snap = await ref.get();
if (!snap.exists) badRequest('Geofence not found', 'not-found');


const gf = snap.data();
if (gf.active === false) badRequest('Geofence inactive', 'failed-precondition');


const centerLat = Number(gf.centerLat);
const centerLng = Number(gf.centerLng);
const radius = Number(gf.radiusMeters);
if (![centerLat, centerLng, radius].every(Number.isFinite)) {
badRequest('Invalid geofence configuration', 'failed-precondition');
}


const distance = getDistance(
{ latitude: lat, longitude: lng },
{ latitude: centerLat, longitude: centerLng }
);
const maxDistance = radius + toleranceMeters;
const within = distance <= maxDistance;


return {
ok: within,
distanceMeters: distance,
allowedMeters: maxDistance,
siteId,
message: within ? 'Location verified' : 'Outside permitted radius'
};
} catch (e) {
logger.warn('verifyLocation error', e);
const code = e.code || 'internal';
return { ok: false, code, message: e.message || 'Verification failed' };
}
});