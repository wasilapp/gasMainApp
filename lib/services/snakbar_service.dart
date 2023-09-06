import 'package:flutter/material.dart';

void showSnackBar(context,String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value))); 
}