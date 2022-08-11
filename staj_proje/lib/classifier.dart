import 'dart:collection';
import 'dart:io';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  Classifier();

  classify(var img) async {
    //resim dosyasını alırız.
    var inputImage = File(img.path);

// Resim modelin anlayacağı formata dönüştürülür (resize ve normalization işlemeleri)
    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(32, 32, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255))
        .build();

// resim tensorflow un kolay çalışabileceği formata dönüştürülür ve işlenir.
    TensorImage tensorImage = TensorImage.fromFile(inputImage);
    tensorImage = imageProcessor.process(tensorImage);

// cifar10 da 10 sınıf old. için ayrı ayrı olasılıklarını alıyoruz
    TensorBuffer probabilityBuffer =
        TensorBuffer.createFixedSize(<int>[1, 10], TfLiteType.float32);

    try {
      //model çalıştırılır. collab kodları bağlanır.
      Interpreter interpreter =
          await Interpreter.fromAsset('my_model.tflite');
      interpreter.run(tensorImage.buffer, probabilityBuffer.buffer);
    } catch (e) {
      print('[ERROR] UNABLE TO LOAD OR RUN MODEL');
      print(e);
    }

// labellar txt dosyasından çekilir (tensorflow labelları direkt saklamıyor)
    List<String> labels = await FileUtil.loadLabels('assets/labels.txt');
    SequentialProcessor<TensorBuffer> probabilityProcessor =
        TensorProcessorBuilder().build();

    TensorLabel tensorLabel = TensorLabel.fromList(
        labels, probabilityProcessor.process(probabilityBuffer));

//tahminler map formatında alınır {tahmin : olasılık}. Sözlük mantığı vardır 2 veri birleştirilip map ortaya çıkarılır.
    Map labeledProb = tensorLabel.getMapWithFloatValue();
    double highestProb = 0;
    String itemName = '[ERROR]';

// tahminlerin sıralanıp (sort) en yüksek 5 inin seçilmesi ve ondalıklı olarak olasılığı belirtmesi için *100
    var sortedLabels = labeledProb.keys.toList(growable: false)
      ..sort((label1, label2) =>
          labeledProb[label2]!.compareTo(labeledProb[label1]!));
    LinkedHashMap maxLabels = LinkedHashMap.fromIterable(
      sortedLabels.take(5),
      key: (k) => k,
      value: (k) => (labeledProb[k] * 100).toStringAsFixed(1),
    );
   
   // en yüksek 5 tahminin map den listeye dönüştürülmesi
    List outputList = [];
    maxLabels.forEach((key, value) {
      outputList.addAll([key, value]);
    });


//label listesi döndürülür [tahmin: olasılık, tahmin: olasılık, ...] olarak dictionary gibi.

    print(outputList);
    return outputList;
  }
}