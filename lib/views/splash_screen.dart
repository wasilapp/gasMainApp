import 'package:EMallApp/main.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/navigator.dart';
import 'package:EMallApp/views/HomeScreen.dart';
import 'package:EMallApp/views/onboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  
  @override
  void initState() {
    super.initState();
    
    // Add a delay to simulate a long-running task
    Future.delayed(Duration(seconds: 3), () {
      checkOnBoard();
    });
  }

  checkOnBoard()async{
   

      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      

    String? isChecked = sharedPreferences.getString("isChecked");
   // isChecked=null;
    if(isChecked==null){
      sharedPreferences.setString("isChecked","1");
      pushReplacementScreen(context, OnboardingScreen());
    }else{
        pushReplacementScreen(context, MyHomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
     MySize().init(context);
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 200.0,
            height: 200.0,
          ),
        ),
      ),
    );
  }
}
