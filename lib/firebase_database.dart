import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

class FirebaseDataSource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _roomsCollection = 'rooms';
  static const String _candidatesCollection = 'candidates';
  static const String _candidateUidField = 'uid';
  final String userId;
  FirebaseDataSource({required this.userId});

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

  Future<void> addCandidateToRoom({
    required String roomId,
    required RTCIceCandidate candidate,
  }) async {
    final roomRef = _db.collection(_roomsCollection).doc(roomId);
    final candidatesCollection = roomRef.collection(_candidatesCollection);
    await candidatesCollection
        .add(candidate.toMap()..[_candidateUidField] = userId);
  }

  Stream<RTCSessionDescription?> getRoomDataStream({required String roomId}) {
    final snapshots = _db.collection(_roomsCollection).doc(roomId).snapshots();
    final filteredStream = snapshots.map((snapshot) => snapshot.data());
    return filteredStream.map(
      (data) {
        if (data != null && data['answer'] != null) {
          return RTCSessionDescription(
            data['answer']['sdp'],
            data['answer']['type'],
          );
        } else {
          return null;
        }
      },
    );
  }

  Future<List<RTCIceCandidate>> getCandidatesAddedToRoom({
    required String roomId,
  }) async {
    try {
      final snapshots = await _db
          .collection(_roomsCollection)
          .doc(roomId)
          .collection(_candidatesCollection)
          .where(_candidateUidField, isNotEqualTo: userId)
          .get();
      return snapshots.docs.map(
        (docChangesList) {
          final data = docChangesList.data();
          return RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
        },
      ).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Stream<List<RTCIceCandidate>> getCandidatesAddedToRoomStream({
    required String roomId,
    required bool listenCaller,
  }) {
    final snapshots = _db
        .collection(_roomsCollection)
        .doc(roomId)
        .collection(_candidatesCollection)
        .where(_candidateUidField, isNotEqualTo: userId)
        .snapshots();

    final convertedStream = snapshots.map(
      (snapshot) {
        final docChangesList = listenCaller
            ? snapshot.docChanges
            : snapshot.docChanges
                .where((change) => change.type == DocumentChangeType.added);
        return docChangesList.map((change) {
          final data = change.doc.data() as Map<String, dynamic>;
          return RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          );
        }).toList();
      },
    );

    return convertedStream;
  }

  Future<Map<String, dynamic>?> getRoomOfferIfExists(
      {required String roomId}) async {
    final roomDoc = await _db.collection(_roomsCollection).doc(roomId).get();
    if (!roomDoc.exists) {
      return null;
    } else {
      final data = roomDoc.data() as Map<String, dynamic>;
      // final offer = data['offer'];
      return data;
    }
  }

  Future<void> setAnswer({
    required String roomId,
    required RTCSessionDescription answer,
  }) async {
    final roomRef = _db.collection(_roomsCollection).doc(roomId);
    final answerMap = <String, dynamic>{
      'answer': {'type': answer.type, 'sdp': answer.sdp}
    };
    await roomRef.update(answerMap);
  }
}
