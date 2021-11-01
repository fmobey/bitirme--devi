import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(title: "Yarın'ın Suyu"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final dref = FirebaseDatabase.instance.reference();
  late DatabaseReference databaseReference;
  showData() {
    dref.once().then((snapshot) {
      print(snapshot.value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseReference = dref;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            title: Center(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        body: FirebaseAnimatedList(
          shrinkWrap: true,
          query: databaseReference,
          itemBuilder: (BuildContext? context, DataSnapshot snapshot,
                  Animation animation, int index) =>
              Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  snapshot.value['Anlikbaslik'].toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(minimum: 0, maximum: 30, ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 0, endValue: 10, color: Colors.green),
                      GaugeRange(
                          startValue: 10, endValue: 20, color: Colors.orange),
                      GaugeRange(
                          startValue: 20, endValue: 30, color: Colors.red)
                    ], pointers: <GaugePointer>[
                      NeedlePointer(value: snapshot.value['Anlik'])
                    ], annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Container(
                              child: Text(snapshot.value['Anlik'].toString(),
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          angle: 90,
                          positionFactor: 0.5)
                    ])
                  ],
                ),
              ),
              Container(
                height: 130,
                width: 400,
                margin: EdgeInsets.only(right: 50, left: 50, top: 90),
                decoration: BoxDecoration(
                    color: Colors.cyanAccent.shade200,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25.0),
                        bottomLeft: Radius.circular(25.0))),
                alignment: Alignment.center,
                child: Container(
                  height: 80,
                  width: 240,
                  decoration: BoxDecoration(
                      color: Colors.cyanAccent.shade700,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25.0),
                          bottomLeft: Radius.circular(25.0))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        snapshot.value['Toplambaslik'].toString(),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      Text(
                        snapshot.value['Toplam'].toString(),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
