import 'package:flutter/material.dart';
import 'package:mnist_recognizer/dl_model/classifier.dart';

class DrawPage extends StatefulWidget {


  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  Classifier classifier = Classifier();
  List<Offset> points = List<Offset>();

  int digit = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          points.clear();
          digit = -1;
          setState(() {});
        },
        child: Icon(Icons.close),
      ),
      appBar: AppBar(backgroundColor: Colors.pink,
        title: Text("Mnist Digit Recognizer"),),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Text("Draw a digit", style: TextStyle(fontSize: 20),),
            SizedBox(height: 10,),
            Container(
              height: 300+2*2.0,
              width: 300+2*2.0,

              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  Offset localposition = details.localPosition;
                  setState((){
                    if(localposition.dx >= 0 &&
                    localposition.dx <=300 &&
                    localposition.dy >= 0 &&
                    localposition.dy <= 300){
                      points.add(localposition);
                    }
                  });
                },
                onPanEnd: (DragEndDetails details) async {
                  points.add(null);

                  digit = await classifier.classifyDrawing(points);
                  setState((){});
                },
                child: CustomPaint(
                  painter: Painter(points: points),
                ),
              ),
            ),
            SizedBox(height: 45,),
            Text("Current prediction:", style:
            TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
            Text(digit == -1? " ":"$digit", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),)


          ],
        ),
      ),
    );
  }
}


class Painter extends CustomPainter {
  final List<Offset> points;
  Painter({this.points});

  final Paint paintDetails = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 4.0
  ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size){
    for(int i=0; i< points.length-1; i++){
      if(points[i] != null && points[i+1] != null){
        canvas.drawLine(points[i], points[i+1], paintDetails);
      }

    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate){
    return true;
  }
}



