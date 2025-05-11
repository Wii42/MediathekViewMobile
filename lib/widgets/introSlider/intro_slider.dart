import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';

class IntroScreen extends StatefulWidget {
  var onDonePressed;
  IntroScreen({Key? key, this.onDonePressed}) : super(key: key);

  @override
  IntroScreenState createState() => IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = [];

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
        title: "Suchen und Downloaden",
        maxLineTitle: 2,
        marginTitle: EdgeInsets.only(top: 20.0, bottom: 20.0),
        description: "Durchsuchen von öffentlich-rechtlichen Mediatheken.",
        centerWidget: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Image(
                image: AssetImage("assets/intro/intro_slider_1.png"))),
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      Slide(
        title: "Filtern",
        description: "Filtern nach Thema, Titel, Länge und Fernsehsender",
        centerWidget: Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Image(
                image: AssetImage("assets/intro/intro_slider_2.png"))),
        backgroundColor: Color(0xff203152),
      ),
    );
  }

  void onDonePress() {
    widget.onDonePressed();
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}
