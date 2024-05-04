// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final GlobalKey webViewKey = GlobalKey();
//   InAppWebViewController? webViewController;
//   final htmlString = ValueNotifier('');
//   // late WebViewController webViewController;
//   final list = [
//     'eyJob190ZW4iOiJ0aCIsImdpb2lfdGluaCI6MSwibmdheV9zaW5oX2R1b25nX2xpY2giOiIwMi8wNS8yMDIzIiwiZ2lvX3NpbmgiOiIiLCJzaW1fY3UiOiIiLCJuaGFfbWFuZyI6IkNo4buNbiIsInRoYW5oX3Bob19zaW5oIjowLCJ0aGFuaF9waG9fbyI6MCwic2ltX2NhaV92YW4iOiIwOTA4MTg1MjUyIiwia2hfdG9rZW4iOiJsU3M3U2pxSDlsUGV4K2w2aXhKNWpnPT0iLCJzb19sdW90X3hlbV9jb25fbGFpIjo5NDM2LCJjaGFydF9saW5lIjpbeyJsb2FpIjoiSGnhu4duIHThuqFpIiwiY29udHJhaSI6LTUyLCJjb25nYWkiOi03NCwidGllbnRhaSI6LTc2LCJob25uaGFuIjotNDQsInBoYXBsdWF0IjotNzAsImNvbmdkYW5oIjo5MiwiY2hhIjotOTEsIm1lIjo0NDcsInN1Y2tob2UiOi03MiwiYW5oZW0iOi02MH0seyJsb2FpIjoiQ+G6o2kgduG6rW4oMDkwODE4NTI1MikiLCJjb250cmFpIjotMjgsImNvbmdhaSI6LTM0LCJ0aWVudGFpIjotNTgsImhvbm5oYW4iOi01MCwicGhhcGx1YXQiOjEzLCJjb25nZGFuaCI6NTQsImNoYSI6MzEsIm1lIjoxNjcsInN1Y2tob2UiOi00OSwiYW5oZW0iOi00Nn1dfQ==',
//     'eyJob190ZW4iOiJ0aCIsImdpb2lfdGluaCI6MSwibmdheV9zaW5oX2R1b25nX2xpY2giOiIwMi8wNS8yMDIzIiwiZ2lvX3NpbmgiOiIiLCJzaW1fY3UiOiIiLCJuaGFfbWFuZyI6IkNo4buNbiIsInRoYW5oX3Bob19zaW5oIjowLCJ0aGFuaF9waG9fbyI6MCwic2ltX2NhaV92YW4iOiIwOTA4MTg1MjUyIiwia2hfdG9rZW4iOiJsU3M3U2pxSDlsUGV4K2w2aXhKNWpnPT0iLCJzb19sdW90X3hlbV9jb25fbGFpIjo5NDM2LCJjaGFydF9saW5lIjpbeyJsb2FpIjoiSGnhu4duIHThuqFpIiwiY29udHJhaSI6LTUyLCJjb25nYWkiOi03NCwidGllbnRhaSI6LTc2LCJob25uaGFuIjotNDQsInBoYXBsdWF0IjotNzAsImNvbmdkYW5oIjo5MiwiY2hhIjotOTEsIm1lIjo0NDcsInN1Y2tob2UiOi0xMiwiYW5oZW0iOi0xMH0seyJsb2FpIjoiQ+G6o2kgduG6rW4oMDkwODE4NTI1MikiLCJjb250cmFpIjotMTgsImNvbmdhaSI6LTE0LCJ0aWVudGFpIjotMTgsImhvbm5oYW4iOi01MCwicGhhcGx1YXQiOjEzLCJjb25nZGFuaCI6MTQsImNoYSI6MTEsIm1lIjoxNywic3Vja2hvZSI6LTE5LCJhbmhlbSI6LTE2fV19',
//     'eyJob190ZW4iOiJ0aCIsImdpb2lfdGluaCI6MSwibmdheV9zaW5oX2R1b25nX2xpY2giOiIwMi8wNS8yMDIzIiwiZ2lvX3NpbmgiOiIiLCJzaW1fY3UiOiIiLCJuaGFfbWFuZyI6IkNo4buNbiIsInRoYW5oX3Bob19zaW5oIjowLCJ0aGFuaF9waG9fbyI6MCwic2ltX2NhaV92YW4iOiIwOTA4MTg1MjUyIiwia2hfdG9rZW4iOiJsU3M3U2pxSDlsUGV4K2w2aXhKNWpnPT0iLCJzb19sdW90X3hlbV9jb25fbGFpIjo5NDM2LCJjaGFydF9saW5lIjpbeyJsb2FpIjoiSGnhu4duIHThuqFpIiwiY29udHJhaSI6LTUyLCJjb25nYWkiOi03NCwidGllbnRhaSI6LTc2LCJob25uaGFuIjotNDQsInBoYXBsdWF0IjotNDAsImNvbmdkYW5oIjo0MiwiY2hhIjotNDEsIm1lIjo0Nywic3Vja2hvZSI6LTQyLCJhbmhlbSI6LTEwfSx7ImxvYWkiOiJD4bqjaSB24bqtbigwOTA4MTg1MjUyKSIsImNvbnRyYWkiOi0xOCwiY29uZ2FpIjotMzQsInRpZW50YWkiOi0zOCwiaG9ubmhhbiI6LTMwLCJwaGFwbHVhdCI6MTMsImNvbmdkYW5oIjozNCwiY2hhIjozMSwibWUiOjM3LCJzdWNraG9lIjotMzksImFuaGVtIjotMzZ9XX0='
//   ];
//   int currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     // webViewController = WebViewController();
//     onLoadChartHtml();
//   }

//   Future<void> onLoadChartHtml() async {
//     htmlString.value = await rootBundle.loadString('assets/indexv3.html');

//     // final contentBase64 = base64Encode(Utf8Encoder().convert(key));
//     // webViewController =
//     // await webViewController.loadFlutterAsset('assets/chart.html');
//   }

//   // void updateChartData() {
//   //   var newData = {
//   //     "labels": ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
//   //     "datasets": [
//   //       {
//   //         "label": 'Votes',
//   //         "data": List.generate(6, (index) => Random().nextInt(30)),
//   //         "backgroundColor": [
//   //           'rgba(255, 99, 132, 0.2)',
//   //           'rgba(54, 162, 235, 0.2)',
//   //           'rgba(255, 206, 86, 0.2)',
//   //           'rgba(75, 192, 192, 0.2)',
//   //           'rgba(153, 102, 255, 0.2)',
//   //           'rgba(255, 159, 64, 0.2)'
//   //         ],
//   //         "borderColor": [
//   //           'rgba(255, 99, 132, 1)',
//   //           'rgba(54, 162, 235, 1)',
//   //           'rgba(255, 206, 86, 1)',
//   //           'rgba(75, 192, 192, 1)',
//   //           'rgba(153, 102, 255, 1)',
//   //           'rgba(255, 159, 64, 1)'
//   //         ],
//   //         "borderWidth": 1
//   //       }
//   //     ]
//   //   };

//   //   webViewController?.evaluateJavascript(source: """
//   //     updateChart(${jsonEncode(newData)});
//   //   """);
//   // }

//   // Map<String, dynamic> getData() => {
//   //       "labels": ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
//   //       "datasets": [
//   //         {
//   //           "label": 'Votes',
//   //           "data": [12, 19, 3, 5, 2, 3],
//   //           "backgroundColor": [
//   //             'rgba(255, 99, 132, 0.2)',
//   //             'rgba(54, 162, 235, 0.2)',
//   //             'rgba(255, 206, 86, 0.2)',
//   //             'rgba(75, 192, 192, 0.2)',
//   //             'rgba(153, 102, 255, 0.2)',
//   //             'rgba(255, 159, 64, 0.2)'
//   //           ],
//   //           "borderColor": [
//   //             'rgba(255, 99, 132, 1)',
//   //             'rgba(54, 162, 235, 1)',
//   //             'rgba(255, 206, 86, 1)',
//   //             'rgba(75, 192, 192, 1)',
//   //             'rgba(153, 102, 255, 1)',
//   //             'rgba(255, 159, 64, 1)'
//   //           ],
//   //           "borderWidth": 1
//   //         }
//   //       ]
//   //     };

//   void onChangeData() {
//     final key = list[currentIndex];
//     webViewController?.evaluateJavascript(source: """
//       bind_chart_flutter(${jsonEncode(key)});
//     """);
//     currentIndex += 1;
//     if (currentIndex >= list.length) {
//       currentIndex = 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test'),
//         // actions: [InkWell(onTap: updateChartData, child: Text('press'))],
//         actions: [
//           OutlinedButton(onPressed: onChangeData, child: Text('Press here'))
//         ],
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: htmlString,
//         builder: (context, html, child) => html.isEmpty
//             ? Center(child: CircularProgressIndicator())
//             : InAppWebView(
//                 key: webViewKey,
//                 initialData: InAppWebViewInitialData(data: html),
//                 onWebViewCreated: (controller) {
//                   webViewController = controller;
//                 },
//               ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
