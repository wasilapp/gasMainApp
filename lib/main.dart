
import 'dart:developer';

import 'package:EMallApp/controllers/AppDataController.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/firebase_options.dart';
import 'package:EMallApp/models/AppData.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/services/PushNotificationsManager.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/BlockedScreen.dart';
import 'package:EMallApp/views/HomeScreen.dart';
import 'package:EMallApp/views/MaintenanceScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:EMallApp/views/auth/OTPVerificationScreen.dart';
import 'package:EMallApp/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'AppTheme.dart';
import 'AppThemeNotifier.dart';
import 'api/api_util.dart';

Future<void> main() async {

  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   
  options: DefaultFirebaseOptions.currentPlatform,
);
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) async {
    String langCode = await AllLanguage.getLanguage();
    await Translator.load(langCode);

    runApp(ChangeNotifierProvider<AppThemeNotifier>(
      create: (context) => AppThemeNotifier(),
      child: MyApp(),
    ));
  });
}

class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl ,

          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
              home: SplashScreen()),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ThemeData? themeData;

  @override
  void initState() {
    super.initState();
    initFCM();

    getAppData();
  }

  getAppData() async {
    MyResponse<AppData> myResponse = await AppDataController.getAppData();

  
   if(myResponse.data!=null) {
    log("response data" + myResponse.data!.paymentMethod.toString());
     print('asoom1');
     if (!myResponse.data!.isAppUpdated()) {
       print('asoom2');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MaintenanceScreen(
              isNeedUpdate: true,
            ),
          ),
          (route) => false,
        );
        return;
      } else {
       print('asoom3');
        if (myResponse.data!.user != null) {
          AuthController.saveUserFromUser(myResponse.data!.user!);
        }
      }
    } else {
     print(myResponse.responseCode);
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
    }
  }

  initFCM() async {
    PushNotificationsManager pushNotificationsManager =
        PushNotificationsManager();
    await pushNotificationsManager.init();
  }

 

  @override
  Widget build(BuildContext context) {
    MySize().init(context);
    themeData = Theme.of(context);
    return FutureBuilder<AuthType>(
        future: AuthController.userAuthType(),
        builder: (context, AsyncSnapshot<AuthType> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == AuthType.VERIFIED) {
              return HomeScreen();
            } else if (snapshot.data == AuthType.LOGIN) {
              return OTPVerificationScreen();
            } else if (snapshot.data == AuthType.BLOCKED) {
              return BlockedScreen();
            } else {
              return LoginScreen();
            }
          } else {
            return CircularProgressIndicator();
          }
        }
    );
  }
}
