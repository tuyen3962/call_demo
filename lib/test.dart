// import 'dart:typed_data';

// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:esc_pos_printer/esc_pos_printer.dart';
// import 'package:network_info_plus/network_info_plus.dart';

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   bool isDiscovering = false;
//   int found = -1;
//   TextEditingController portController = TextEditingController(text: '9100');
//   TextEditingController localIpCtrl = TextEditingController();
//   final portNode = FocusNode();

//   @override
//   void initState() {
//     localIpCtrl.addListener(() {
//       setState(() {});
//     });
//     portNode.addListener(() {
//       if (!portNode.hasFocus) {
//         setState(() {});
//       }
//     });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     portNode.dispose();
//     portController.dispose();
//     super.dispose();
//   }

//   void discover(BuildContext ctx) async {
//     setState(() {
//       isDiscovering = true;
//       found = -1;
//     });

//     String ip;
//     try {
//       final info = NetworkInfo();

//       ip = await info.getWifiIP() ?? ''; // 192.168.1.43
//     } catch (e) {
//       final snackBar = SnackBar(
//           content: Text('WiFi is not connected', textAlign: TextAlign.center));
//       return;
//     }
//     localIpCtrl.text = ip;

//     final String subnet = ip.substring(0, ip.lastIndexOf('.'));
//     int port = 9100;
//     try {
//       port = int.parse(portController.text);
//     } catch (e) {
//       portController.text = port.toString();
//     }
//     print('subnet:\t$subnet, port:\t$port');
//   }

//   Future<void> testReceipt(NetworkPrinter printer) async {
//     printer.text(
//         'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//     printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//         styles: PosStyles(codeTable: 'CP1252'));
//     printer.text('Special 2: blåbærgrød',
//         styles: PosStyles(codeTable: 'CP1252'));

//     printer.text('Bold text', styles: PosStyles(bold: true));
//     printer.text('Reverse text', styles: PosStyles(reverse: true));
//     printer.text('Underlined text',
//         styles: PosStyles(underline: true), linesAfter: 1);
//     printer.text('Align left', styles: PosStyles(align: PosAlign.left));
//     printer.text('Align center', styles: PosStyles(align: PosAlign.center));
//     printer.text('Align right',
//         styles: PosStyles(align: PosAlign.right), linesAfter: 1);

//     printer.row([
//       PosColumn(
//         text: 'col3',
//         width: 3,
//         styles: PosStyles(align: PosAlign.center, underline: true),
//       ),
//       PosColumn(
//         text: 'col6',
//         width: 6,
//         styles: PosStyles(align: PosAlign.center, underline: true),
//       ),
//       PosColumn(
//         text: 'col3',
//         width: 3,
//         styles: PosStyles(align: PosAlign.center, underline: true),
//       ),
//     ]);

//     printer.text('Text size 200%',
//         styles: PosStyles(
//           height: PosTextSize.size2,
//           width: PosTextSize.size2,
//         ));

//     // Print barcode
//     final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
//     printer.barcode(Barcode.upcA(barData));

//     // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
//     // printer.text(
//     //   'hello ! 中文字 # world @ éphémère &',
//     //   styles: PosStyles(codeTable: PosCodeTable.westEur),
//     //   containsChinese: true,
//     // );

//     printer.feed(2);
//     printer.cut();
//   }

//   // Future<void> printDemoReceipt(NetworkPrinter printer) async {
//   //   // Print image
//   //   final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
//   //   final Uint8List bytes = data.buffer.asUint8List();
//   //   final Image image = decodeImage(bytes);
//   //   printer.image(image);

//   //   printer.text('GROCERYLY',
//   //       styles: PosStyles(
//   //         align: PosAlign.center,
//   //         height: PosTextSize.size2,
//   //         width: PosTextSize.size2,
//   //       ),
//   //       linesAfter: 1);

//   //   printer.text('889  Watson Lane', styles: PosStyles(align: PosAlign.center));
//   //   printer.text('New Braunfels, TX',
//   //       styles: PosStyles(align: PosAlign.center));
//   //   printer.text('Tel: 830-221-1234',
//   //       styles: PosStyles(align: PosAlign.center));
//   //   printer.text('Web: www.example.com',
//   //       styles: PosStyles(align: PosAlign.center), linesAfter: 1);

//   //   printer.hr();
//   //   printer.row([
//   //     PosColumn(text: 'Qty', width: 1),
//   //     PosColumn(text: 'Item', width: 7),
//   //     PosColumn(
//   //         text: 'Price', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //     PosColumn(
//   //         text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //   ]);

//   //   printer.row([
//   //     PosColumn(text: '2', width: 1),
//   //     PosColumn(text: 'ONION RINGS', width: 7),
//   //     PosColumn(
//   //         text: '0.99', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //     PosColumn(
//   //         text: '1.98', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //   ]);
//   //   printer.row([
//   //     PosColumn(text: '1', width: 1),
//   //     PosColumn(text: 'PIZZA', width: 7),
//   //     PosColumn(
//   //         text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //     PosColumn(
//   //         text: '3.45', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //   ]);
//   //   printer.row([
//   //     PosColumn(text: '1', width: 1),
//   //     PosColumn(text: 'SPRING ROLLS', width: 7),
//   //     PosColumn(
//   //         text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //     PosColumn(
//   //         text: '2.99', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //   ]);
//   //   printer.row([
//   //     PosColumn(text: '3', width: 1),
//   //     PosColumn(text: 'CRUNCHY STICKS', width: 7),
//   //     PosColumn(
//   //         text: '0.85', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //     PosColumn(
//   //         text: '2.55', width: 2, styles: PosStyles(align: PosAlign.right)),
//   //   ]);
//   //   printer.hr();

//   //   printer.row([
//   //     PosColumn(
//   //         text: 'TOTAL',
//   //         width: 6,
//   //         styles: PosStyles(
//   //           height: PosTextSize.size2,
//   //           width: PosTextSize.size2,
//   //         )),
//   //     PosColumn(
//   //         text: '\$10.97',
//   //         width: 6,
//   //         styles: PosStyles(
//   //           align: PosAlign.right,
//   //           height: PosTextSize.size2,
//   //           width: PosTextSize.size2,
//   //         )),
//   //   ]);

//   //   printer.hr(ch: '=', linesAfter: 1);

//   //   printer.row([
//   //     PosColumn(
//   //         text: 'Cash',
//   //         width: 8,
//   //         styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
//   //     PosColumn(
//   //         text: '\$15.00',
//   //         width: 4,
//   //         styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
//   //   ]);
//   //   printer.row([
//   //     PosColumn(
//   //         text: 'Change',
//   //         width: 8,
//   //         styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
//   //     PosColumn(
//   //         text: '\$4.03',
//   //         width: 4,
//   //         styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
//   //   ]);

//   //   printer.feed(2);
//   //   printer.text('Thank you!',
//   //       styles: PosStyles(align: PosAlign.center, bold: true));

//   //   final now = DateTime.now();
//   //   final formatter = DateFormat('MM/dd/yyyy H:m');
//   //   final String timestamp = formatter.format(now);
//   //   printer.text(timestamp,
//   //       styles: PosStyles(align: PosAlign.center), linesAfter: 2);

//   //   // Print QR Code from image
//   //   // try {
//   //   //   const String qrData = 'example.com';
//   //   //   const double qrSize = 200;
//   //   //   final uiImg = await QrPainter(
//   //   //     data: qrData,
//   //   //     version: QrVersions.auto,
//   //   //     gapless: false,
//   //   //   ).toImageData(qrSize);
//   //   //   final dir = await getTemporaryDirectory();
//   //   //   final pathName = '${dir.path}/qr_tmp.png';
//   //   //   final qrFile = File(pathName);
//   //   //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
//   //   //   final img = decodeImage(imgFile.readAsBytesSync());

//   //   //   printer.image(img);
//   //   // } catch (e) {
//   //   //   print(e);
//   //   // }

//   //   // Print QR Code using native function
//   //   // printer.qrcode('example.com');

//   //   printer.feed(1);
//   //   printer.cut();
//   // }

//   void testPrint(BuildContext ctx) async {
//     if (localIpCtrl.text.isEmpty) return;
//     const PaperSize paper = PaperSize.mm80;
//     final profile = await CapabilityProfile.load();
//     final printer = NetworkPrinter(paper, profile);

//     final PosPrintResult res = await printer.connect(localIpCtrl.text,
//         port: int.tryParse(portController.text) ?? 9100);

//     SnackBar snackBar;
//     if (res == PosPrintResult.success) {
//       // DEMO RECEIPT
//       // await printDemoReceipt(printer);
//       // TEST PRINT
//       await testReceipt(printer);
//       printer.disconnect();
//       snackBar = SnackBar(content: Text(res.msg, textAlign: TextAlign.center));
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     } else {
//       snackBar =
//           SnackBar(content: Text("Thất bại", textAlign: TextAlign.center));
//     }
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Discover Printers'),
//       ),
//       body: Builder(
//         builder: (BuildContext context) {
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 TextField(
//                   controller: portController,
//                   keyboardType: TextInputType.number,
//                   focusNode: portNode,
//                   decoration: InputDecoration(
//                     labelText: 'Port',
//                     hintText: 'Port',
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text('Local ip: ${localIpCtrl.text}',
//                     style: TextStyle(fontSize: 16)),
//                 TextField(
//                   controller: localIpCtrl,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'Ip',
//                     hintText: 'Ip',
//                   ),
//                 ),
//                 SizedBox(height: 15),
//                 InkWell(
//                     child: Text(
//                         '${isDiscovering ? 'Discovering...' : 'Discover'}'),
//                     onTap: isDiscovering ? null : () => discover(context)),
//                 SizedBox(height: 15),
//                 found >= 0
//                     ? Text('Found: $found device(s)',
//                         style: TextStyle(fontSize: 16))
//                     : Container(),
//                 if (localIpCtrl.text.isNotEmpty)
//                   InkWell(
//                     onTap: () => testPrint(context),
//                     child: Column(
//                       children: <Widget>[
//                         Container(
//                           height: 60,
//                           padding: EdgeInsets.only(left: 10),
//                           alignment: Alignment.centerLeft,
//                           child: Row(
//                             children: <Widget>[
//                               Icon(Icons.print),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: <Widget>[
//                                     Text(
//                                       '${localIpCtrl.text}:${portController.text}',
//                                       style: TextStyle(fontSize: 16),
//                                     ),
//                                     Text(
//                                       'Click to print a test receipt',
//                                       style: TextStyle(color: Colors.grey[700]),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Icon(Icons.chevron_right),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
