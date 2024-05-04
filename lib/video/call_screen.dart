import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_2/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String callerId;
  final dynamic offer;
  final String roomId;
  const CallScreen({
    super.key,
    this.offer,
    required this.roomId,
    required this.callerId,
    // required this.calleeId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  // videoRenderer for localPeer
  final _localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? _localStream;

  // mediaStream for remote
  MediaStream? _remoteStream;

  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  List<MediaStream> _remoteMediaStream = [];

  // media status
  bool isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;

  late final firebaseDatabase = FirebaseDataSource(userId: widget.callerId);

  @override
  void initState() {
    // setup Peer Connection
    _setupPeerConnection();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _setupPeerConnection() async {
    // initializing renderers
    await _localRTCVideoRenderer.initialize();
    await _remoteRTCVideoRenderer.initialize();
    // configure
    final configuration = {
      "iceServers": [
        // {
        //   "urls": "stun:stun.relay.metered.ca:80",
        // },
        // {
        //   "urls": "turn:global.relay.metered.ca:80",
        //   "username": "030e77303ba6728a59912ab1",
        //   "credential": "2RR2ZM7v+ybkAJJJ",
        // },
        // {
        //   "urls": "turn:global.relay.metered.ca:80?transport=tcp",
        //   "username": "030e77303ba6728a59912ab1",
        //   "credential": "2RR2ZM7v+ybkAJJJ",
        // },
        // {
        //   "urls": "turn:global.relay.metered.ca:443",
        //   "username": "030e77303ba6728a59912ab1",
        //   "credential": "2RR2ZM7v+ybkAJJJ",
        // },
        // {
        //   "urls": "turns:global.relay.metered.ca:443?transport=tcp",
        //   "username": "030e77303ba6728a59912ab1",
        //   "credential": "2RR2ZM7v+ybkAJJJ",
        // },
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        },
      ]
    };

    final offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    // create peer connection
    _rtcPeerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);

    _rtcPeerConnection?.onAddStream = (stream) {
      _remoteStream = stream;
      if (_remoteMediaStream.isNotEmpty) {
        _remoteMediaStream.first
            .getTracks()
            .forEach((element) => _remoteStream?.addTrack(element));
      }
      _remoteRTCVideoRenderer.srcObject = _remoteStream;
      setState(() {});
    };

    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) {
      _remoteMediaStream = event.streams;
      setState(() {});
    };

    // get localStream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    // add mediaTrack to peerConnection
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    // _remoteRTCVideoRenderer.srcObject = await createLocalMediaStream('key');

    // set source for local video renderer
    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    // for Incoming call
    if (widget.offer != null) {
      // listen for Remote IceCandidate
      // final candidates = await firebaseDatabase.getCandidatesAddedToRoom(
      //     roomId: widget.roomId);
      // for (final candidate in candidates) {
      //   _rtcPeerConnection!.addCandidate(candidate);
      // }
      firebaseDatabase
          .getCandidatesAddedToRoomStream(
              roomId: widget.roomId, listenCaller: true)
          .listen((candidates) {
        for (final candidate in candidates) {
          _rtcPeerConnection!.addCandidate(candidate);
        }
      });

      // set SDP offer as remoteDescription for peerConnection
      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      // create SDP answer
      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

      // set SDP answer as localDescription for peerConnection
      _rtcPeerConnection!.setLocalDescription(answer);

      // send SDP answer to remote peer over signalling
      // socket!.emit("answerCall", {
      //   "callerId": widget.callerId,
      //   "sdpAnswer": answer.toMap(),
      // });
      firebaseDatabase.setAnswer(roomId: widget.roomId, answer: answer);
    }
    // for Outgoing Call
    else {
      // listen for local iceCandidate and add it to the list of IceCandidate
      _rtcPeerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        firebaseDatabase.addCandidateToRoom(
            roomId: widget.roomId, candidate: candidate);
        rtcIceCadidates.add(candidate);
      };

      // when call is accepted by remote peer
      firebaseDatabase
          .getRoomDataStream(roomId: widget.roomId)
          .listen((event) async {
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(
            event?.sdp,
            event?.type,
          ),
        );
      });

      firebaseDatabase
          .getCandidatesAddedToRoomStream(
              roomId: widget.roomId, listenCaller: false)
          .listen((candidates) {
        for (final candidate in candidates) {
          _rtcPeerConnection!.addCandidate(candidate);
        }
      });

      // create SDP Offer
      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      firebaseDatabase.createRoom(
        roomId: widget.roomId,
        offer: offer,
        callerId: widget.callerId,
      );
    }
  }

  _leaveCall() {
    // if(widget.offer == null) {
    //   firebaseDatabase.
    // }
    Navigator.pop(context);
  }

  _toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    // change status
    isVideoOn = !isVideoOn;

    // enable or disable video track
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("P2P Call App"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                  child: RTCVideoView(
                    _remoteRTCVideoRenderer,
                    mirror: true,
                    filterQuality: FilterQuality.high,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    placeholderBuilder: (context) =>
                        CircularProgressIndicator(),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: SizedBox(
                    height: 150,
                    width: 120,
                    child: RTCVideoView(
                      _localRTCVideoRenderer,
                      mirror: isFrontCameraSelected,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                    onPressed: _toggleMic,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end),
                    iconSize: 30,
                    onPressed: _leaveCall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cameraswitch),
                    onPressed: _switchCamera,
                  ),
                  IconButton(
                    icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remoteStream?.getTracks().forEach((track) => track.stop());
    _rtcPeerConnection?.close();
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    _remoteStream?.dispose();
    super.dispose();
  }
}
