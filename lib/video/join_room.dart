import 'package:flutter/material.dart';
import 'package:flutter_application_2/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'call_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  dynamic incomingSDPOffer;
  // final remoteCallerIdTextEditingController = TextEditingController();
  // final callerId = TextEditingController();
  final roomCtrl = TextEditingController();
  late final database = FirebaseDataSource(userId: callerId);

  final callerId = Uuid().v4();

  @override
  void initState() {
    super.initState();

    // listen for incoming video call
    // SignallingService.instance.socket!.on("newCall", (data) {
    //   if (mounted) {
    //     // set SDP Offer of incoming call
    //     setState(() => incomingSDPOffer = data);
    //   }
    // });
  }

  // join Call
  _joinCall({
    required String callerId,
    // required String calleeId,
    required String roomId,
    dynamic offer,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          callerId: callerId,
          // calleeId: calleeId,
          offer: offer,
          roomId: roomId,
        ),
      ),
    );
  }

  void findCall() async {
    final result = await database.getRoomOfferIfExists(roomId: roomCtrl.text);
    if (result != null) {
      incomingSDPOffer = result;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("P2P Call App"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: TextEditingController(text: callerId),
                      readOnly: true,
                      textAlign: TextAlign.center,
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        labelText: "Your Caller ID",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // TextField(
                    //   // controller: remoteCallerIdTextEditingController,
                    //   textAlign: TextAlign.center,
                    //   decoration: InputDecoration(
                    //     hintText: "Remote Caller ID",
                    //     alignLabelWithHint: true,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 24),
                    TextField(
                      controller: roomCtrl,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Room ID",
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                      ),
                      child: const Text(
                        "Invite",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _joinCall(
                          callerId: callerId,
                          roomId: roomCtrl.text,
                        );
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                      ),
                      child: const Text(
                        "Find",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        findCall();
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (incomingSDPOffer != null)
              Positioned(
                child: ListTile(
                  title: Text(
                    "Incoming Call from ${incomingSDPOffer["callerId"]}",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call_end),
                        color: Colors.redAccent,
                        onPressed: () {
                          setState(() => incomingSDPOffer = null);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call),
                        color: Colors.greenAccent,
                        onPressed: () {
                          _joinCall(
                            callerId: callerId,
                            // calleeId: callerId.text,
                            roomId: roomCtrl.text,
                            offer: incomingSDPOffer["offer"],
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
