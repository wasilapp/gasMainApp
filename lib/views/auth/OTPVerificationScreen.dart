import 'dart:developer';


import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../AppTheme.dart';
import '../../AppThemeNotifier.dart';
import '../AppScreen.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late ThemeData themeData;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  new GlobalKey<ScaffoldMessengerState>();

  TextEditingController? _numberController;
  TextEditingController? _otpController;
  FocusNode otpFN = FocusNode();
  String? numper;
  bool isInProgress = false;
  String? _verificationId;

  final GlobalKey _countryCodeSelectionKey = new GlobalKey();
  int selectedCountryCode = 0;
  List<PopupMenuEntry<Object>>? countryList;
  List<dynamic> countryCode = TextUtils.countryCode;

  List<bool> _dataExpansionPanel = [true, false];

  @override
  void initState() {
    super.initState();
    getNumper();
    _numberController = TextEditingController();
    _otpController = TextEditingController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      showMessage(message: "Please verify your phone number");
    });
  }

  getNumper()async{
    log("i am in get");
    final prefs = await SharedPreferences.getInstance();
    numper = "+${prefs.getString('number')}";
    
    print("qqqqqqqq${numper}");
    sendOTP();
  }

  @override
  void dispose() {
    super.dispose();
    _numberController!.dispose();
  }

  Future<void> sendOTP() async {
    String? phoneNumber = numper;
    if (numper == null) {
      return;
    }
    setState(() {
      isInProgress = true;
    });

    MyResponse myResponse =
    await AuthController.verifyMobileNumber(numper!);

    // ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
    if (!myResponse.success) {
      showMessage(message: "This is used phone number ");
      setState(() {
        isInProgress = false;
      });
      return;
    }

    await Firebase.initializeApp();

    print(numper);

    void verificationCompleted(AuthCredential phoneAuthCredential) {
      verifiedComplete(numper);
    }

    void verificationFailed(FirebaseAuthException error) {
      if (error.code == 'invalid-phone-number') {
        showMessage(message: "Please use [country code] then [number] format");
      }
      showMessage(message: error.code);
    }

    void codeSent(String verificationId, [int? code]) {
      setState(() {
        _dataExpansionPanel[1] = true;
        otpFN.requestFocus();
      });
      _verificationId = verificationId;
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      print('codeAutoRetrievalTimeout');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(

      phoneNumber: numper,
      timeout: Duration(milliseconds: 10000),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  getNumberWithFormat() {
    
    String number = numper!;

    if (number.contains("+")) {
      showMessage(message: "Please enter number properly");
      return null;
    }

    if (number.length < 6) {
      showMessage(message: "Please enter number properly");
      return null;
    }

    return number;
  }

  onOTPVerify() async {
    String? number = getNumberWithFormat();
    String otp = _otpController!.text.trim();
    if (otp.isEmpty) {
      showMessage(message: "Please fill OTP");
    } else if (otp.length != 6) {
      showMessage(message: "Your OTP is not 6 digit");
    } else {
      try {
        PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        verifiedComplete(numper);
      } catch (e) {
        showMessage(message: "Your verification code is wrong");
      }
    }
  }

  verifiedComplete(String? number) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    try {
      MyResponse response = await AuthController.mobileVerified(number);

      AuthType authType = await AuthController.userAuthType();

      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }

      if (authType == AuthType.VERIFIED) {

        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) => AppScreen()), (Route route) => false);
      } else if (authType == AuthType.LOGIN) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OTPVerificationScreen(),
          ),
        );
      } else {
        await AuthController.logoutUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen(),
          ),
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
              // appBar: AppBar(
              //   elevation: 0,
              //   centerTitle: true,
              //   title: Text("OTP Verification",
              //       style: themeData.appBarTheme.textTheme!.headline6),
              // ),
                body: Container(
                  margin: Spacing.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 70,
                          height: 70,
                        ),
                      ),
                      Spacer(),
                      // Container(
                      //   child: Text("رمز التأكيد ",style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 25
                      //   ),),
                      // ),
                      Container(
                        child: Text(Translator.translate("send_otp"),style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        )),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 20,bottom: 20),
                        child: Text(Translator.translate("enter_otp"),style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        )),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width-100,
                          child:
                          PinCodeTextField(

                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              inactiveColor: Colors.grey,
                              selectedColor: Colors.greenAccent,
                              activeColor: Colors.greenAccent,
                              errorBorderColor: Colors.greenAccent,
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 40,

                              activeFillColor: Colors.white,
                            ),
                            enablePinAutofill:false,
                            autovalidateMode:AutovalidateMode.disabled,
                            cursorColor: Colors.green,
                            autoFocus: false,
                            autoUnfocus: false,
                            animationDuration: Duration(milliseconds: 300),
                            enableActiveFill: false,
                            autoDisposeControllers: false,
                            onAutoFillDisposeAction:AutofillContextAction.cancel,
                            // errorAnimationController: errorController,
                            controller: _otpController,
                            onCompleted: (v) {
                              print("Completed");
                              // otp =v;
                            },
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                // otp = value;
                              });
                            },
                            // beforeTextPaste: (text) {
                            //   print("Allowing to paste $text");
                            //   //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //   //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            //   return true;
                            // },
                            appContext: context,
                          )

                        // PinCodeFields(
                        //
                        //   borderWidth:1,
                        //   activeBorderColor:Color(0xff2AD376),
                        //   keyboardType:TextInputType.number,
                        //   fieldBorderStyle:FieldBorderStyle.square,
                        //   length: 6,
                        //   onComplete: (output) {
                        //       setState(() {
                        //         otp = output;
                        //       });
                        //     print(output);
                        //   },
                        // ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all(Spacing.xy(16, 0))),
                                  onPressed: () {
                                    onOTPVerify();
                                  },

                                  child: Container(
                                    width: MediaQuery.of(context).size.width-100,

                                    child: Center(
                                      child: Text(
                                        Translator.translate("confirm"),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),

                                      ),
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Center(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    Spacing.xy(16, 0))),
                            onPressed: () async {
                              await AuthController.logoutUser();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LoginScreen(),
                                ),
                              );
                            },
                            child: Text(Translator.translate("logout"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    fontWeight: 600,
                                    color: themeData.colorScheme.onPrimary)
                            )
                        ),
                      )
                    ],
                  ),
                )));
      },
    );
  }

  void showMessage({String message = "Something wrong", Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldMessengerKey.currentState!.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  List<PopupMenuEntry<Object>> getCountryList() {
    if (countryList != null) return countryList!;
    countryList = <PopupMenuEntry<Object>>[];
    for (int i = 0; i < countryCode.length; i++) {
      countryList!.add(PopupMenuItem(
        value: i,
        child: Container(
          margin: Spacing.vertical(2),
          child: Text(
              countryCode[i]['name'] + " ( " + countryCode[i]['code'] + " )",
              style: AppTheme.getTextStyle(
                themeData.textTheme.subtitle2,
                color: themeData.colorScheme.onBackground,
              )),
        ),
      ));
      countryList!.add(
        PopupMenuDivider(
          height: 10,
        ),
      );
    }
    return countryList!;
  }
}
