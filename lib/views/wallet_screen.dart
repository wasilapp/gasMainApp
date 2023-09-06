import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/controllers/UserCouponController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/UserWallet.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>{
  //ThemeData
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;
  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  new GlobalKey<ScaffoldMessengerState>();

  bool isInProgress = false;
  UserWallet? wallet;
  @override
  void initState() {
    super.initState();
    _getWallet();

  }

  @override
  void dispose() {
    super.dispose();

  }

  _getWallet() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<UserWallet> myResponse =
    await UserCouponController.getWallet();

    if (myResponse.success) {
      print("wallet done12");
      print(myResponse.data);
      wallet = myResponse.data;


    } else {
      print("wallet er");
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child){
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return Scaffold(
          appBar: AppBar(

            elevation: 2,
            title: Center(child: Text(Translator.translate("wallet"),style: boldSecondry,)),

          ),

          body: wallet ==null ? Container() : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Your Balance is", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(wallet!.total.toString(), style: TextStyle(fontSize: 16)),
                      ],
                    ),
          ),



        );
      },

    );

  }
  showMessage({String message = "Something wrong", Duration? duration}) {
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

}
