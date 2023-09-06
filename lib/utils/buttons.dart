import 'package:EMallApp/api/colors.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:flutter/material.dart';



class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 250,

      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),),
        child: FittedBox(child: Text(label,style: whitebasic,textAlign: TextAlign.center,)),
        onPressed: onPressed,
      ),
    );
  }
}
