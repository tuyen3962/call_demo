import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class MapScreenCapture extends StatefulWidget {
  @override
  _MapScreenCaptureState createState() => _MapScreenCaptureState();
}

class _MapScreenCaptureState extends State<MapScreenCapture> {
  GlobalKey globalKey = GlobalKey();
  Timer? _timer;
  int _captureIntervalInSeconds =
      10; // Khoảng thời gian giữa các lần chụp (60 giây trong ví dụ này)

  Future<void> _saveImageToLocalAsset(Uint8List imageData) async {
    try {
      final directory = await getExternalStorageDirectory();
      final assetsDirectory = Directory('${directory?.path}/assets');
      if (!assetsDirectory.existsSync()) {
        assetsDirectory.createSync();
      }
      final imagePath = '${assetsDirectory.path}/map_screenshot.png';
      await File(imagePath).writeAsBytes(imageData);
      print('Đã lưu ảnh vào local asset: $imagePath');
    } catch (e) {
      print('Lỗi khi lưu ảnh vào local asset: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Khởi động timer để tự động chụp ảnh sau mỗi khoảng thời gian
    // _timer = Timer.periodic(Duration(seconds: _captureIntervalInSeconds), (timer) {
    //   _captureAndSave();
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _captureAndSave() async {
    try {
      // Kiểm tra xem globalKey có khả năng trỏ đến một RenderObject không
      if (globalKey.currentContext != null) {
        // Kiểm tra kiểu của RenderObject
        final renderObject = globalKey.currentContext!.findRenderObject();
        // Chắc chắn kiểu là RenderRepaintBoundary trước khi chuyển đổi
        if (renderObject is RenderRepaintBoundary) {
          RenderRepaintBoundary boundary = renderObject;
          ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData!.buffer.asUint8List();

          await _saveImageToLocalAsset(pngBytes);
        } else {
          print(
              "Không thể chụp ảnh màn hình: renderObject không phải là RenderRepaintBoundary");
        }
      } else {
        print("Không thể chụp ảnh màn hình: globalKey không có currentContext");
      }
    } catch (e) {
      print("Không thể chụp ảnh màn hình: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Screen Capture"),
        actions: [
          GestureDetector(
            onTap: _captureAndSave,
            child: Icon(Icons.abc_sharp),
          )
        ],
      ),
      body: RepaintBoundary(
          key: globalKey,
          child: Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTb5z6MCCSYYRWCiVDmoNaRZ1qEwl6MlQCOzkSBJbdMlg&s')),
    );
  }
}
