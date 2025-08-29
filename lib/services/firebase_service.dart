import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';


class FirebaseService {
FirebaseService._();
static final FirebaseService instance = FirebaseService._();


// Use the same region you set in the functions (asia-south1)
final FirebaseFunctions _functions =
FirebaseFunctions.instanceFor(region: 'asia-south1');


Future<Map<String, dynamic>> verifyQRCode({
required String qrData,
String? userId,
}) async {
final callable = _functions.httpsCallable('verifyQRCode');
final result = await callable.call(<String, dynamic>{
'qrData': qrData,
if (userId != null) 'userId': userId,
});
return Map<String, dynamic>.from(result.data as Map);
}


Future<Map<String, dynamic>> verifyLocation({
required String siteId,
required double lat,
required double lng,
double? toleranceMeters,
}) async {
final callable = _functions.httpsCallable('verifyLocation');
final result = await callable.call(<String, dynamic>{
'siteId': siteId,
'lat': lat,
'lng': lng,
if (toleranceMeters != null) 'toleranceMeters': toleranceMeters,
});
return Map<String, dynamic>.from(result.data as Map);
}


// Optional: call this during debug local testing to hit the emulator.
Future<void> connectToEmulator({
String host = 'localhost',
int port = 5001,
}) async {
try {
FirebaseFunctions.instanceFor(region: 'asia-south1')
.useFunctionsEmulator(host, port);
} catch (_) {
// If the method signature changes across versions, we no-op in release
}
}
}