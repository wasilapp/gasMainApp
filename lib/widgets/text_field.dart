import 'package:EMallApp/api/colors.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:flutter/material.dart';



class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIconData;
  final IconData suffixIconData;
  final bool isPassword;
  final TextInputType keyBoard;
  final TextEditingController controller;
  final Function()? onPrefixIconPress;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.keyBoard,
    required this.prefixIconData,
    this.suffixIconData = Icons.visibility_off,
    this.onPrefixIconPress,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0,left: 20),
      child: TextFormField(
        keyboardType: keyBoard,
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          label: Text(hintText,style: basicPrimary,),
          prefixIcon: InkWell(
            onTap: onPrefixIconPress==null ?  (){}: onPrefixIconPress,
            child: Icon(prefixIconData,color: secondaryColor,)),

          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}
