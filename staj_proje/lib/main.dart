
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staj_proje/classifier.dart';
import 'dart:io';

import 'package:staj_proje/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOTAS PROJECT APP',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: redColor,
        primarySwatch: Colors.red,
        textTheme: const TextTheme(
          headline1: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
          headline2: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Classifier classifier = Classifier();
  final picker = ImagePicker();
  String _item = '';
  String _itemProb = '';
  String _item1 = '';
  String _itemProb1 = '';
  String _item2 = '';
  String _itemProb2 = '';
  String _item3 = '';
  String _itemProb3 = '';
  String _item4 = '';
  String _itemProb4 = '';
  var img;

  bool _isLoading = false;
  Widget imShow = Image.asset(
    'assets/botas_logo.jpg',
    fit: BoxFit.contain,
  );

  @override
  void initState() {
    super.initState();

    // Lock screen orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Container(
                color: redColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: whiteColor,
                  ),
                ),
              )
            : Stack(
                children: [
                  Positioned(
                    height: size.height * 0.4,
                    width: size.width,
                    child: imShow,
                  ),
                  Positioned(
                    top: size.height * 0.35,
                    height: size.height * 0.65,
                    width: size.width,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: redColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(42),
                          topRight: Radius.circular(42),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          Text(
                            'Tahminler',
                            style: TextStyle(
                              fontSize: size.height * 0.05,
                              fontFamily: 'times new roman',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          _item == ''
                              ? Text(
                                  'Lütfen bir resim seçiniz',
                                  style: TextStyle(
                                    fontSize: size.height * 0.025,
                                    fontWeight: FontWeight.normal,
                                  ),
                                )
                              : Column(
                                  children: [
                                    Text(
                                      '$_itemProb% $_item',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                      '$_itemProb1% $_item1',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                      '$_itemProb2% $_item2',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                      '$_itemProb3% $_item3',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                      '$_itemProb4% $_item4',
                                      style: TextStyle(
                                        fontSize: size.height * 0.025,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  img = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxHeight: 224,
                                    maxWidth: 224,
                                    imageQuality: 100,
                                  );
                                  if (img == null) {
                                    setState(() {
                                      imShow = Image.asset(
                                        'assets/botas_logo.jpg',
                                        fit: BoxFit.contain,
                                      );
                                      _item = '';
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    final outputs =
                                        await classifier.classify(img);
                                    setState(() {
                                      imShow = Image.file(
                                        File(img.path),
                                        fit: BoxFit.cover,
                                      );
                                      _item = dictionary[outputs[0]] as String;
                                      _itemProb = outputs[1];
                                      _item1 = dictionary[outputs[2]] as String;
                                      _itemProb1 = outputs[3];
                                      _item2 = dictionary[outputs[4]] as String;
                                      _itemProb2 = outputs[5];
                                      _item3 = dictionary[outputs[6]] as String;
                                      _itemProb3 = outputs[7];
                                      _item4 = dictionary[outputs[8]] as String;
                                      _itemProb4 = outputs[9];
                                      _isLoading = false;
                                    });
                                  }
                                },
                                child: Icon(
                                  Icons.photo_outlined,
                                  color: whiteColor,
                                  size: size.height * 0.1,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  img = await picker.pickImage(
                                    source: ImageSource.camera,
                                    maxHeight: 224,
                                    maxWidth: 224,
                                    imageQuality: 100,
                                  );
                                  if (img == null) {
                                    setState(() {
                                      imShow = Image.asset(
                                        'assets/botas_logo.jpg',
                                        fit: BoxFit.contain,
                                      );
                                      _item = '';
                                    });
                                  } else {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    final outputs =
                                        await classifier.classify(img);
                                    setState(() {
                                      imShow = Image.file(
                                        File(img.path),
                                        fit: BoxFit.cover,
                                      );
                                      _item = dictionary[outputs[0]] as String;
                                      _itemProb = outputs[1];
                                      _item1 = dictionary[outputs[2]] as String;
                                      _itemProb1 = outputs[3];
                                      _item2 = dictionary[outputs[4]] as String;
                                      _itemProb2 = outputs[5];
                                      _item3 = dictionary[outputs[6]] as String;
                                      _itemProb3 = outputs[7];
                                      _item4 = dictionary[outputs[8]] as String;
                                      _itemProb4 = outputs[9];
                                      _isLoading = false;
                                    });
                                  }
                                  ;
                                },
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: whiteColor,
                                  size: size.height * 0.1,
                                ),
                              ),
                            ],
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
