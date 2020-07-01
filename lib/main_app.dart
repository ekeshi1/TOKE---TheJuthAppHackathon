import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juth_app_toke/connectivity_widget.dart';

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orangeAccent,
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/Rectangle-1.png"),
                          fit: BoxFit.cover)),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
                  child: Row(
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 35.0,
                            semanticLabel:
                                'Text to announce in accessibility modes',
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Text(
                              "TOKE!",
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  fontFamily: "Schyler",
                                  fontSize: 40,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      Flexible(child: Container(), fit: FlexFit.loose),
                      Icon(Icons.info, color: Colors.white, size: 35.0),
                    ],
                  ),
                )
              ],
            ),
            Expanded(
                child: Column(

              children: [Expanded(child: CustomBar()),
                Padding(
                  padding: const EdgeInsets.only(left:10,right:10),
                  child: Container(
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        image: DecorationImage(
                            image: AssetImage("assets/juth.png"),
                            fit: BoxFit.scaleDown)),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),],
/*    decoration: new BoxDecoration(
        gradient: new LinearGradient(colors: [
          const Color(0xF19A2A),
          const Color(0xF19A2B),
        ],
      begin:const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(1.0, 0.0),
      stops: [0.0,1.0],
      tileMode: TileMode.clamp

      ),)*/
            ))
          ]),
    );
  }
}

class CustomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.orangeAccent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBar(
              backgroundColor: Colors.transparent,
              bottom: TabBar(
                tabs: <Widget>[
                  new Tab(text: "TOKE!"),
                  new Tab(
                    text: "Rendtija",
                  ),
                ],
                indicator:   ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0))),
              color: Colors.orangeAccent
          ),
              ),

            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ConnectivityWidget(),
             new FlareActor("assets/Youth app animation.flr", alignment:Alignment.center, fit:BoxFit.contain, animation:"Untitled")

            ],
          ),
        ),
      ),
    );
  }
}
