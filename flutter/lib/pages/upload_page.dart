import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "dart:io";
import 'package:mnist_recognizer/dl_model/classifier.dart';

class UploadImage extends StatefulWidget {


  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final picker = ImagePicker();
  Classifier classifier = Classifier();
   PickedFile image;
  int digit = -1;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async{
      image = await ImagePicker.platform.pickImage(source: ImageSource.gallery, maxHeight: 300, maxWidth: 300, imageQuality: 100) as PickedFile;
      digit = await classifier.classify_image(image);

      setState(() {});
        },
        child: Icon(Icons.camera_alt_outlined),
      ),
      appBar: AppBar(backgroundColor: Colors.pink,
      title: Text("Mnist Digit Recognizer"),),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Text("Image will be shown below", style: TextStyle(fontSize: 20),),
            SizedBox(height: 10,),
            Container(
              height: 300,
              width: 300,

              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.0),
                image: DecorationImage(
                      image: digit==-1 ?
                      AssetImage("assets/white_background.jpeg") :
                      FileImage(File(image.path)) as ImageProvider,
                  ),
              ),
            ),
            SizedBox(height: 45,),
            Text("Current prediction:", style:
            TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
            Text(digit==-1?" ":"$digit", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),)

          ]

        ),
      ),
    );
  }
}
