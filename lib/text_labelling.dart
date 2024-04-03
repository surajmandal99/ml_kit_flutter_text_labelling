import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextLabelling extends StatefulWidget {
  const TextLabelling({super.key});

  @override
  TextLabellingState createState() => TextLabellingState();
}

class TextLabellingState extends State<TextLabelling> {
  XFile? pickedImage;
  String mytext = '';
  bool scanning = false;

  final ImagePicker _imagePicker = ImagePicker();

  getImage(ImageSource ourSource) async {
    XFile? result = await _imagePicker.pickImage(source: ourSource);

    if (result != null) {
      setState(() {
        pickedImage = result;
      });

      performTextLabelling();
    }
  }

  performTextLabelling() async {
    if (!mounted) return;
    setState(() {
      mytext = '';
      scanning = true;
    });
    try {
      final inputImage = InputImage.fromFilePath(pickedImage!.path);

      final imageLabeler = GoogleMlKit.vision.imageLabeler();

      final List labels = await imageLabeler.processImage(inputImage);

      for (var label in labels) {
        mytext +=
            '${label.label} (${(label.confidence * 100).toStringAsFixed(2)}%)\n';
      }

      setState(() {
        scanning = false;
      });

      imageLabeler.close();
    } catch (e) {
      print('Error during text recognition: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Labelling App'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          pickedImage == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: ClayContainer(
                    height: 400,
                    child: Center(
                      child: Text('No Image Selected'),
                    ),
                  ),
                )
              : Center(
                  child: Image.file(
                  File(pickedImage!.path),
                  height: 400,
                )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Recognized Labels:')),
          const SizedBox(height: 30),
          scanning
              ? const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                      child: SpinKitThreeBounce(
                    color: Colors.black,
                    size: 20,
                  )),
                )
              : Center(
                  child: AnimatedTextKit(
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TypewriterAnimatedText(mytext,
                            textAlign: TextAlign.center,
                            textStyle: const TextStyle(fontSize: 20)),
                      ]),
                ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
