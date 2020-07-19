import 'package:flutter/material.dart';

class RoundedButton extends StatefulWidget {
  RoundedButton(
      {this.title, this.colourTop, this.colourBottom, @required this.onPressed});

  final Color colourTop;
  final Color colourBottom;
  final String title;
  final Function onPressed;

  @override
  _RoundedButtonState createState() => _RoundedButtonState();

}

class _RoundedButtonState extends State<RoundedButton> {

  double buttonOpacity = 0.8;
  Color shadowChange = Colors.black38;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child:GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (TapDownDetails details){
          setState(() {
            buttonOpacity = 1.0;
            shadowChange = Colors.black12;
          });
        },
        onTapUp: (TapUpDetails details){
          setState(() {
            buttonOpacity = 0.8;
            shadowChange = Colors.black38;
          });
        },
        onTapCancel: (){
          setState(() {
            buttonOpacity = 0.8;
            shadowChange = Colors.black38;
          });
        },
        child: AnimatedContainer(
          margin: const EdgeInsets.only(top: 1.0, bottom:1.0),
          width: 300,
          duration: Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.colourTop.withOpacity(buttonOpacity),
                widget.colourBottom.withOpacity(buttonOpacity),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: shadowChange,
                offset: Offset(5, 5),
                blurRadius: 5,
              )
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


