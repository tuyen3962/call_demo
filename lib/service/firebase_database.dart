import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

class FirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _users = 'users';
  static const String _roomsCollection = 'rooms';
  static const String _activeCallers = 'ActiveCallers';
  static const String _callerCandidates = 'callerCandidates';
  static const String _calleeCandidates = 'calleeCandidates';
  FirebaseDataSource();

  Future<String> registerUser(
      {required String userId, required String fcmToken}) async {
    final userRef = _db.collection(_users).doc(fcmToken);

    await userRef.set({'id': userId, 'token': fcmToken});
    return userId;
  }

  Future<String> createRoom(
      {required String roomId,
      required RTCSessionDescription offer,
      required String callerId}) async {
    final roomRef = _db.collection(_roomsCollection).doc(roomId);
    final roomWithOffer = <String, dynamic>{
      'offer': offer.toMap(),
      'callerId': callerId
    };

    await roomRef.set(roomWithOffer);
    return roomRef.id;
  }

  Future<void> addActiveCaller(Map<String, dynamic> json) async {
    final activecallers = _db.collection('ActiveCallers');
    activecallers.add(json);
  }

  Future<Map<String, dynamic>?> getOtherUser() async {
    final userRef =
        await _db.collection(_users).where('id', isNotEqualTo: userId).get();
    if (userRef.docs.isNotEmpty) {
      return userRef.docs.first.data();
    }

    return null;
  }

  Future<void> onDeleteRoom(String roomId) async {
    await _db.collection(_roomsCollection).doc(roomId).delete();
    final result = await _db
        .collection(_activeCallers)
        .where('id', isEqualTo: roomId)
        .get();
    if (result.docs.isNotEmpty) {
      for (final doc in result.docs) {
        await _db.collection(_activeCallers).doc(doc.id).delete();
      }
    }
  }

  // Future<List<RTCIceCandidate>> getCandidatesAddedToRoom({
  //   required String roomId,
  // }) async {
  //   try {
  //     final snapshots = await _db
  //         .collection(_roomsCollection)
  //         .doc(roomId)
  //         .collection(_candidatesCollection)
  //         .where(_candidateUidField, isNotEqualTo: userId)
  //         .get();
  //     return snapshots.docs.map(
  //       (docChangesList) {
  //         final data = docChangesList.data();
  //         return RTCIceCandidate(
  //           data['candidate'],
  //           data['sdpMid'],
  //           data['sdpMLineIndex'],
  //         );
  //       },
  //     ).toList();
  //   } catch (e) {
  //     print(e);
  //     return [];
  //   }
  // }

  // Stream<List<RTCIceCandidate>> getCandidatesAddedToRoomStream({
  //   required String roomId,
  //   required bool listenCaller,
  // }) {
  //   final snapshots = _db
  //       .collection(_roomsCollection)
  //       .doc(roomId)
  //       .collection(_candidatesCollection)
  //       .where(_candidateUidField, isNotEqualTo: userId)
  //       .snapshots();

  //   final convertedStream = snapshots.map(
  //     (snapshot) {
  //       final docChangesList = listenCaller
  //           ? snapshot.docChanges
  //           : snapshot.docChanges
  //               .where((change) => change.type == DocumentChangeType.added);
  //       return docChangesList.map((change) {
  //         final data = change.doc.data() as Map<String, dynamic>;
  //         return RTCIceCandidate(
  //           data['candidate'],
  //           data['sdpMid'],
  //           data['sdpMLineIndex'],
  //         );
  //       }).toList();
  //     },
  //   );

  //   return convertedStream;
  // }

  // Future<Map<String, dynamic>?> getRoomOfferIfExists(
  //     {required String roomId}) async {
  //   final roomDoc = await _db.collection(_roomsCollection).doc(roomId).get();
  //   if (!roomDoc.exists) {
  //     return null;
  //   } else {
  //     final data = roomDoc.data() as Map<String, dynamic>;
  //     // final offer = data['offer'];
  //     return data;
  //   }
  // }

  // Future<void> setAnswer({
  //   required String roomId,
  //   required RTCSessionDescription answer,
  // }) async {
  //   final roomRef = _db.collection(_roomsCollection).doc(roomId);
  //   final answerMap = <String, dynamic>{
  //     'answer': {'type': answer.type, 'sdp': answer.sdp}
  //   };
  //   await roomRef.update(answerMap);
  // }
}
