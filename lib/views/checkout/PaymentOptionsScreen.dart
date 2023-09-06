import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/controllers/OrderController.dart';
import 'package:EMallApp/models/AppData.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final double total;
  final bool isShop;
  final int? type; 
  final int? quantity;
  final int? shopId;
  const PaymentOptionsScreen({Key? key, required this.total  ,this.isShop=false,this.type=null,this.quantity=null,this.shopId=null}) : super(key: key);

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  //ThemeData
  ThemeData? themeData;
  late CustomAppTheme customAppTheme;

  bool checkingIfWallet =false;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
     checkIfSuitableWallet();
     log(checkingIfWallet.toString());

     log(widget.quantity.toString());
     log(widget.shopId.toString());
     log(widget.type.toString());
  }

  @override
  void dispose() {
    super.dispose();
  }

  checkIfSuitableWallet(){
  
    if(OrderController.walletsForUser == null){
      checkingIfWallet=false;
      return;
    }

    
     if(OrderController.walletsForUser!.total! >= widget.total  ){
        checkingIfWallet=true;
        return;
      }
    return;

    }


  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: Scaffold(
                backgroundColor: customAppTheme.bgLayer1,
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  leading: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(MdiIcons.chevronLeft),
                  ),
                  centerTitle: true,
                  title: Text(Translator.translate("select_payment"),
                      style: AppTheme.getTextStyle(
                                    themeData!.textTheme.bodyText2,
                          fontWeight: 600)),
                ),
                body: _buildBody()));
      },
    );
  }

  Widget _buildBody() {
    List<Widget> list = [];

    // if (AppData.paymentMethodEnabled(Order.ORDER_PT_STRIPE)) {
    //   list.add(_singleMethod(Order.ORDER_PT_STRIPE));
    // }
    // if (AppData.paymentMethodEnabled(Order.ORDER_PT_RAZORPAY)) {
    //   list.add(_singleMethod(Order.ORDER_PT_RAZORPAY));
    // }
    // if (AppData.paymentMethodEnabled(Order.ORDER_PT_PAYSTACK)) {
    //   list.add(_singleMethod(Order.ORDER_PT_PAYSTACK));
    // }
    if(widget.isShop && widget.type !=null && checkingIfWallet==true){
         list.add(_singleMethod(Order.ORDER_PT_WALLET));
    }
 
    if (AppData.paymentMethodEnabled(Order.ORDER_PT_COD)) {
      list.add(_singleMethod(Order.ORDER_PT_COD));
    }

    return Column(
      children: list,
    );
  }

  Widget _singleMethod(int paymentMethod) {
    return Container(
      margin: Spacing.fromLTRB(16, 8, 16, 8),
      padding: Spacing.xy(16, 8),
      decoration: BoxDecoration(
          color: customAppTheme.bgLayer1,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: customAppTheme.bgLayer4)),
      child: Row(
        children: [
          Expanded(
              child: Text(
                Order.getPaymentTypeText(paymentMethod),
            style: AppTheme.getTextStyle(themeData!.textTheme.bodyText1,
                color: themeData!.colorScheme.onBackground),
          )),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, paymentMethod);
            },
            child: Text(Translator.translate("select")),
          )
        ],
      ),
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
            style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData!.colorScheme.onPrimary)),
        backgroundColor: themeData!.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
