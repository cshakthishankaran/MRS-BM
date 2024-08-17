import "package:flutter/material.dart";


class MyButton extends StatelessWidget {

  final Function()? onTap;
  final String text;
  final EdgeInsets padding;
  final bool isEnabled;


  const MyButton({super.key, required this.onTap, required this.text,required this.padding,this.isEnabled = true,});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(

      onTap:onTap,
      child: Container(
        padding: padding,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(8),

        ),

        child: Center(
          child: Text(
              text,
              style:TextStyle(
                fontWeight: FontWeight.bold,
                backgroundColor:Colors.yellow ,
                color : Colors.black,
                fontSize: 16,
              )
          ),

        ),
      ),
    );
  }
}