import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io' as io;
import 'package:image/image.dart' as img;
import 'package:mnist_recognizer/utils/constants.dart';
import 'dart:ui' as ui;

class Classifier{
  Classifier() {
  }

  classify_image(PickedFile image) async {
    var _file = io.File(image.path);
    img.Image imageTemp = img.decodeImage(_file.readAsBytesSync());
    img.Image resizedImg = img.copyResize(imageTemp,
        height: 28, width: 28);
    var imgBytes = resizedImg.getBytes();
    var imgAsList = imgBytes.buffer.asUint8List();

    // Everything "important" is done in getPred
    return getpred(imgAsList);
  }


  classifyDrawing(List<Offset> points) async {
    final picture = toPicture(points); // convert List to Picture
    final image = await picture.toImage(28, 28); // Picture to 28x28 Image
    ByteData imgBytes = await image.toByteData(); // Read this image
    var imgAsList = imgBytes.buffer.asUint8List();

    // Everything "important" is done in getPred
    return getpred(imgAsList);
  }



  Future<int> getpred(Uint8List imgAsList) async {
    List resultBytes = List(28*28);
    // edited this

    int index = 0;

    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];

      resultBytes[index] = ((r + g + b) / 3.0) / 255.0;
      index++;
    }

    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(1 * 10, null, growable: false).reshape([1, 10]);
    //edited this

    InterpreterOptions interpreterOptions = InterpreterOptions();

    try {
      Interpreter interpreter = await Interpreter.fromAsset(
        "model.tflite",
        options: interpreterOptions,
      );
      interpreter.run(input, output);
    }
      catch (e) {
        print("error loading model");
    }

    double highestprob = 0;
    int digitpred=-1;

    print(output);
    for(int i = 0; i<output[0].length; i++){
      if (output[0][i] > highestprob){
        highestprob = output[0][i];
        digitpred = i;
      }
    }

    return digitpred;
  }
}


ui.Picture toPicture(List<Offset> points) {

  final _whitePaint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.white
    ..strokeWidth = 16.0;

  final _bgPaint = Paint()..color = Colors.black;
  final _canvasCullRect = Rect.fromPoints(Offset(0, 0),
      Offset(28.toDouble(), 28.toDouble()));
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, _canvasCullRect)
    ..scale(mnistSize / canvasSize);

  canvas.drawRect(Rect.fromLTWH(0, 0, 28, 28), _bgPaint);

  for (int i = 0; i < points.length - 1; i++) {
    if (points[i] != null && points[i + 1] != null) {
      canvas.drawLine(points[i], points[i + 1], _whitePaint);
    }
  }

  return recorder.endRecording();
}
