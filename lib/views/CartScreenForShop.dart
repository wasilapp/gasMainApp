import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';

import 'package:EMallApp/api/currency_api.dart';

import 'package:EMallApp/models/CustomCart.dart';
import 'package:EMallApp/models/ProductItem.dart';

import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/ProductUtils.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/AppScreen.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/checkout/CheckoutScreenShop.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../models/Categories.dart' as ct;

class CartScreenForShop extends StatefulWidget {
  final ct.SubCategory? subcategories;
  final ct.Category? category;
  final ct.Shop? shop;
  CartScreenForShop({required this.subcategories,required this.category,this.shop});
  @override
  _CartScreenForShopState createState() => _CartScreenForShopState();
}

class _CartScreenForShopState extends State<CartScreenForShop> {
  //ThemeData
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other variables
  bool isInProgress = false;
  List<CustomCart> customCarts = [];
  List<ct.SubCategory>? subcategory;
 int quantity=1;
  @override
  void initState() {
    super.initState();
    widget.subcategories;

  }

  @override
  void dispose() {
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }



  void _checkoutCart(ct.SubCategory sub) async {
    
   await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => CheckoutShop(
              quantity: quantity,
              subcategories: sub,
              category: widget.category,
              shop: widget.shop
            )));

   // _refresh();
  }


  @override
  Widget build(BuildContext context) {
     log(widget.category!.title.toString());
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
                backgroundColor: customAppTheme!.bgLayer1,
                key: _scaffoldKey,
                // appBar: AppBar(
                //   backgroundColor: customAppTheme!.bgLayer1,
                //   elevation: 0,
                
                //   centerTitle: true,
                //   title: Text(Translator.translate("cart"),
                //       style: AppTheme.getTextStyle(
                //           themeData!.appBarTheme.textTheme!.headline6,
                //           fontWeight: 600)),
                // ),
                body: Column(
                  children: [
                                         Container(
                      width:MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.4,
                       child: Stack(
                         children: [
                           Positioned(
                            top: 0,
                            right: 0,
                             child: Container(
                                  width:MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.4,
                               child: Image.asset(
                                  "assets/images/Map.png",
                               
                                  fit: BoxFit.fitWidth,
                                ),
                             ),
                           ),
                            Center(child: Image.asset(
                              "assets/images/Tracking.png",
                           
                              fit: BoxFit.fill,
                            ) ,)
                         ],
                       ),
                     ),
                    Container(
                      height: MySize.size3,
                      child: isInProgress
                          ? LinearProgressIndicator(
                              minHeight: MySize.size3,
                            )
                          : Container(
                              height: MySize.size3,
                            ),
                    ),
                    Expanded(
                      child: _buildBody(),
                    )
                  ],
                )));
      },
    );
  }

  _buildBody() {
    if (customCarts.length == 0) {
      return showCartProducts();
    } else if (isInProgress) {
      return LoadingScreens.getCartLoadingScreen(
          context, themeData, customAppTheme!);
    } else {
      return Container(
        margin: Spacing.top(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image(
                image: AssetImage(
                  './assets/images/empty-cart.png',
                ),
                height: MySize.safeWidth! * 0.5,
                width: MySize.safeWidth! * 0.5,
              ),
            ),
            Container(
              margin: Spacing.only(top: 24),
              child: Text(
                Translator.translate("your_cart_is_empty"),
                style: AppTheme.getTextStyle(themeData!.textTheme.subtitle1,
                    color: themeData!.colorScheme.onBackground,
                    fontWeight: 600,
                    letterSpacing: 0),
              ),
            ),
            Container(
              margin: Spacing.only(top: 24),
              child: ElevatedButton(
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.9, 50)),
                      padding: MaterialStateProperty.all(Spacing.xy(24,12)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ))
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => AppScreen()));
                  },
                  child: Text(Translator.translate("lets_shopping"),
                      style: AppTheme.getTextStyle(
                          themeData!.textTheme.bodyText2,
                          fontWeight: 600,
                          color: themeData!.colorScheme.onPrimary,
                          letterSpacing: 0.5))),
            )
          ],
        ),
      );
    }
  }



  Widget showCartProducts() {

    return Container(
      decoration: BoxDecoration(
        color: customAppTheme!.bgLayer1,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: customAppTheme!.bgLayer4, width: 1),
      ),
      padding: Spacing.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(height: 50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                     Text(Translator.translate("price"),style: TextStyle(color: Colors.grey,fontSize: 15),),
                  SizedBox(height: 10,),
                  Container(
                    margin: Spacing.left(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                         
                        Text(widget.subcategories!.title,
                            style: AppTheme.getTextStyle(
                                themeData!.textTheme.bodyText1,
                                fontWeight: 600,
                                letterSpacing: 0)),
                        Text(
                          CurrencyApi.getSign(afterSpace: true) +
                              CurrencyApi.doubleToString(
                                  ( (widget.subcategories!.price + widget.category!.commesion) * quantity) ),
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.subtitle2,
                              fontWeight: 500,
                              letterSpacing: 0),
                        ),
                       
                      ],
                    ),
                  ),
                ],
              ),

               Column(
                 children: [
                  Text(Translator.translate("amount"),style: TextStyle(color: Colors.grey,fontSize: 15),),
                  SizedBox(height: 10,),
                   Container(
                           
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[

                                InkWell(
                                  onTap: () {

                                    _decrementQuantity();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                             Color(0xff15cb95),

                                        borderRadius: BorderRadius.all(
                                            Radius.circular(MySize.size16!))),
                                    padding: Spacing.all(8),
                                    margin: Spacing.right(8),
                                    child: Icon(
                                      MdiIcons.minus,
                                      color: ( quantity< 2)
                                          ? customAppTheme!.onDisabled
                                          : themeData!.colorScheme.onPrimary,
                                      size: MySize.size14,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    quantity.toString(),
                                    style: AppTheme.getTextStyle(
                                        themeData!.textTheme.subtitle2,
                                        fontWeight: 600,
                                        color: themeData!.colorScheme.onBackground),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                  _incrementQuantity();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:
                                            Color(0xff15cb95),

                                        borderRadius: BorderRadius.all(
                                            Radius.circular(MySize.size16!))),
                                    padding: Spacing.all(8),
                                    margin: Spacing.left(8),
                                    child: Icon(MdiIcons.plus,
                                        color: themeData!.colorScheme.onPrimary,
                                        size: MySize.size14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                 ],
               )

              
            ],
          ),

          SizedBox(height: 40,),
          Center(
            child: ElevatedButton(
              
                style: ButtonStyle(
                     backgroundColor: MaterialStateProperty.all<Color>( Color(0xff15cb95),),
                     fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.9, 50)),
                    padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10),
                      
                    ))),
                onPressed: () {
                  _checkoutCart(widget.subcategories!);
                },
                child: Text(Translator.translate("checkout").toUpperCase(),
                    style: AppTheme.getTextStyle(
                        themeData!.textTheme.caption,
                        fontSize: 15,
                        fontWeight: 600,
                        letterSpacing: 0.5,
                        color: themeData!.colorScheme.onPrimary))),
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

class _CartProductDialog extends StatefulWidget {
  final ProductItem? productItem;
  final CustomAppTheme? customAppTheme;

  const _CartProductDialog(
      {Key? key, required this.productItem, required this.customAppTheme})
      : super(key: key);

  @override
  __CartProductDialogState createState() => __CartProductDialogState();
}

class __CartProductDialogState extends State<_CartProductDialog> {
  
  @override
  Widget build(BuildContext context) {
   
    ThemeData themeData = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: new BoxDecoration(
          color: themeData.backgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: ProductUtils.singleProductItemOption(
            widget.productItem!, themeData, widget.customAppTheme),
      ),
    );
  }
}
