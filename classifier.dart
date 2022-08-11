import 'dart:collection';
import 'dart:io';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  Classifier();

  classify(var img) async {
    var inputImage = File(img.path);

    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(224, 224, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255))
        .build();

    TensorImage tensorImage = TensorImage.fromFile(inputImage);
    tensorImage = imageProcessor.process(tensorImage);

    TensorBuffer probabilityBuffer =
        TensorBuffer.createFixedSize(<int>[1, 50], TfLiteType.float32);

    try {
      Interpreter interpreter =
          await Interpreter.fromAsset('efficientnetb0.tflite');
      interpreter.run(tensorImage.buffer, probabilityBuffer.buffer);
    } catch (e) {
      print('[ERROR] UNABLE TO LOAD OR RUN MODEL');
      print(e);
    }

    List<String> labels = await FileUtil.loadLabels('assets/labels.txt');
    SequentialProcessor<TensorBuffer> probabilityProcessor =
        TensorProcessorBuilder().build();

    TensorLabel tensorLabel = TensorLabel.fromList(
        labels, probabilityProcessor.process(probabilityBuffer));

    Map labeledProb = tensorLabel.getMapWithFloatValue();
    double highestProb = 0;
    String itemName = '[ERROR]';

    var sortedLabels = labeledProb.keys.toList(growable: false)
      ..sort((label1, label2) =>
          labeledProb[label2]!.compareTo(labeledProb[label1]!));
    LinkedHashMap maxLabels = LinkedHashMap.fromIterable(
      sortedLabels.take(5),
      key: (k) => k,
      value: (k) => (labeledProb[k] * 100).toStringAsFixed(1),
    );

    // labeledProb.forEach((key, value) {
    //   if (value * 100 > highestProb) {
    //     highestProb = value * 100;
    //     itemName = key;
    //   }
    // });

    // var outputProb = highestProb.toStringAsFixed(1);
    // return [itemName, outputProb];

    List outputList = [];
    maxLabels.forEach((key, value) {
      outputList.addAll([key, value]);
    });

    print(outputList);
    return outputList;
  }
}
