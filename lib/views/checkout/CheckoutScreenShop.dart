import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/AddressController.dart';
import 'package:EMallApp/controllers/OrderController.dart';
import 'package:EMallApp/models/Cart.dart';
import 'package:EMallApp/models/Coupon.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Order.dart';
import 'package:EMallApp/models/Product.dart';


import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/services/FirestoreServices.dart';
import 'package:EMallApp/utils/ColorUtils.dart';
import 'package:EMallApp/utils/DistanceUtils.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/ProductUtils.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/OrderScreen.dart';
import 'package:EMallApp/views/addresses/AddAddressScreen.dart';
import 'package:EMallApp/views/checkout/CouponScreen.dart';
import 'package:EMallApp/views/checkout/PaymentOptionsScreen.dart';
import 'package:EMallApp/views/payments/PaystackPaymentScreen.dart';
import 'package:EMallApp/views/payments/RazorpayPaymentScreen.dart';
import 'package:EMallApp/views/payments/StripePaymentScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';

import '../../models/Categories.dart' as ct;


class CheckoutShop extends StatefulWidget {

  final ct. SubCategory? subcategories;

  final ct.Category? category;
  final ct.Shop? shop;
  final int? quantity;

  const CheckoutShop({Key? key, this.subcategories, required this.category,required this.quantity,this.shop}) : super(key: key);
  @override
  _CheckoutShopState createState() => _CheckoutShopState();
}

class _CheckoutShopState extends State<CheckoutShop> {
  //ThemeData
  late ThemeData themeData;
  CustomAppTheme? customAppTheme;

  //Global Key
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey _addressSelectionKey = new GlobalKey();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;

  List<UserAddress>? userAddresses = [];
  Coupon? coupon;
  int selectedAddress = 0, selectedPaymentMethod = -1, selectedOrderType = 2;
  int? orderCost;
  ct.Shop? shop;

  bool validForDelivery = true;
  double distance=-1;
  String distanceInText = "";

  //Order cost
  double order = 0;
  int shopTax = 0;
  double tax = 0;
  double commision=0;
  double couponDiscount = 0;
  double deliveryFee = 0;
  double total = 0;
  String deliveryIds="";


  late FirestoreServices firestoreServices;
  bool isChecked = false;
 TextEditingController? datePicker;
  String dateString="";
  String  timeString = "";
  @override
  void initState() {
    firestoreServices = FirestoreServices();
    datePicker = TextEditingController();
    order = (widget.subcategories!.price + widget.category!.commesion) * widget.quantity!;
    log("order: "+order.toString());
    super.initState();

    _initData();

 
  }

  @override
  void dispose() {
    super.dispose();
  }

  getNearest()async{



      log(userAddresses![selectedAddress].latitude.toString());
      log(userAddresses![selectedAddress].longitude.toString());

  

    distance = firestoreServices.getDistanceBetweenTwoPoints(userAddresses![selectedAddress].latitude, userAddresses![selectedAddress].longitude, widget.shop!.latitude, widget.shop!.longitude);
    log("distance: ${distance}");
    if(distance==-1){
      showMessage(message:"no drivers right now");
      return;
    }

    log( "supposed distance:  " +distance.toString());
    log(widget.category!.deliveryFee.toString());
    deliveryFee  = double.parse ((widget.category!.deliveryFee).toStringAsFixed(2)) ;
    log("delivry_fees: " +deliveryFee.toString());
   

    total = order + deliveryFee;

    total = double.parse (total.toStringAsFixed(2));
    setState(() {
      
    });
  }

  void _calculateDistance() {
    if (userAddresses!.length != 0) {
      double distanceInMeter = DistanceUtils.calculateDistance(
          shop!.latitude,
          shop!.longitude,
          userAddresses![selectedAddress].latitude,
          userAddresses![selectedAddress].longitude);
      if (Order.isPickUpOrder(selectedOrderType)) {
        setState(() {
          validForDelivery = true;
          deliveryFee = 0;
        });
        return;
      }
      if (distanceInMeter <= shop!.deliveryRange) {
        setState(() {

        });
      } else {
        setState(() {
          validForDelivery = false;
          deliveryFee = 0;
          distanceInText = DistanceUtils.formatDistance(distanceInMeter);
        });
      }
    }
   // _createBillData();
  }

  // _createBillData() {
  //   setState(() {
  //     deliveryFee = selectedOrderType == 1 ? 0 : deliveryFee;
  //     order = 0;

  //     // shopTax = shop!.tax;
  //     tax = 0;

  //     total = 0;

  //     tax = order * (shopTax) / 100;

  //     if (coupon != null) {
  //       couponDiscount = coupon!.getDiscountValue(order);
  //     }
  //     total = order + tax + deliveryFee - couponDiscount;
  //   });
  // }

  // _changeOrderType(int type) {
  //   setState(() {
  //     selectedOrderType = type;
  //   });
  //   _createBillData();
  // }

  _initData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<UserAddress>> myResponse =
        await AddressController.getMyAddresses();

    if (myResponse.success) {
      userAddresses = myResponse.data;
         getNearest();
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

   // _createBillData();

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _initData();
  }

  _makeOrder() async {
    int? addressId;

    if (selectedOrderType == 2) {
      if (userAddresses!.length != 0) {
        addressId = userAddresses![selectedAddress].id;
      } else {
        showMessage(message: Translator.translate("please_select_address"));
        return;
      }
    }

    if (selectedPaymentMethod == -1) {
      showMessage(
          message: Translator.translate("please_select_payment_method"));
      return;
    }

    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    if(distance==-1){
      showMessage(message:"no drivers right now");
      return;
    }

    log( "supposed distance:  " +distance.toString());
    log(widget.category!.deliveryFee.toString());
    deliveryFee  =  widget.category!.deliveryFee ;
    log("delivry_fees: " +deliveryFee.toString());
    commision = widget.category!.commesion;

    total = order + tax + deliveryFee - couponDiscount;
    //return;

    int status = selectedPaymentMethod == 1 ? 1 : 0;

    MyResponse<Order> myResponse = await OrderController.addOrderForShop(
        order,
        deliveryFee,
        total,
        widget.shop!.id.toString(),
        selectedPaymentMethod,
        status,
        selectedOrderType,
        widget.subcategories!.title == "New" ?0:1,
        widget.quantity!,
        addressId: addressId,
        orderDate: dateString,
        orderTime: timeString,
        
    );
      OrderController.getWalletsData();
   

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }

    if (myResponse.success) {
      if (Order.isPaymentByCOD(selectedPaymentMethod)) {
        log("i am here");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderScreen()));
      }else if (Order.isPaymentByWallet(selectedPaymentMethod)) {
        log("i am here");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OrderScreen()));
      }
      
      //  else if (Order.isPaymentByRazorpay(selectedPaymentMethod)) {
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //           builder: (BuildContext context) => RazorpayPaymentScreen(
      //             orderId: myResponse.data!.id,
      //               )));
      // } 
      
      // else if (Order.isPaymentByPaystack(selectedPaymentMethod)) {
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //           builder: (BuildContext context) => PaystackPaymentScreen(
      //             orderId: myResponse.data!.id,
      //               )));
      // } 
      // else if (Order.isPaymentByStripe(selectedPaymentMethod)) {
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //           builder: (BuildContext context) => StripePaymentScreen(
      //             orderId: myResponse.data!.id,
      //               )));
      // }
    } else {
      log("i am here on the error");
     // ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }
  }
  @override
  Widget build(BuildContext context) {
   // log(widget.shop!.id.toString());
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(themeType),
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: customAppTheme!.bgLayer2,
                // appBar: AppBar(
                //   elevation: 0,
                //   backgroundColor: customAppTheme!.bgLayer2,
                //   leading: InkWell(
                //     onTap: () {
                //       Navigator.of(context).pop();
                //     },
                //     child: Icon(
                //       MdiIcons.chevronLeft,
                //       color: themeData.colorScheme.onBackground,
                //     ),
                //   ),
                //   centerTitle: true,
                //   title: Text(Translator.translate("checkout"),
                //       style: AppTheme.getTextStyle(
                //           themeData.textTheme.subtitle1,
                //           fontWeight: 600)),
                // ),
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme!.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: ListView(
                      padding: Spacing.zero,
                      children: <Widget>[
                            SizedBox(height: 20,),
                          Stack(
                            children: [
                              Container(
                      width:MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height*0.4,
                       child: Image.asset(
                              "assets/images/img3.png",
                       
                              fit: BoxFit.fill,
                        ),
                     ),

                    //  Positioned(
                    //   top: 80,
                    //   right: 10,
                    //   child: Container(
                    //         width: 46,
                    //         height: 46,
                    //         decoration: BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             boxShadow: [
                    //                 BoxShadow(
                    //                     color: Color(0x7f15cb95),
                    //                     blurRadius: 4,
                    //                     offset: Offset(0, 4),
                    //                 ),
                    //             ],
                    //             color: Color(0xff15cb95),
                    //         ),
                    //         child: IconButton(onPressed:
                    //            () async{
                    //           DateTime? pickedDate = await showOmniDateTimePicker(context: context);
                    //           dateString = DateFormat('dd-MM-yyyy').format(pickedDate!);
                    //           timeString = DateFormat('HH:mm').format(pickedDate);
                    //           datePicker?.text = dateString + "-" + timeString;
                    //       },
                    //        icon: Icon(Icons.calendar_month)),
                    //     )),

                         Positioned(
                          top: 10,
                          left: 12,
                          right: 12,
                           child: Padding(padding: EdgeInsets.only(right:8,left: 8),child: Container(
                                             width: MediaQuery.of(context).size.width * 1,
                                             height: MediaQuery.of(context).size.height * 0.06 ,
                                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color(0xff15cb95),),
                                             child: Padding(
                                               padding: const EdgeInsets.all(8.0),
                                               child: Row(
                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                 children: [
                            Text(Translator.translate("pay"),style:TextStyle(fontWeight: FontWeight.w600 ,color: Colors.white),),
                                   
                            Row(
                              children: [
                                                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text(Translator.translate("back"),style:TextStyle( color: Colors.white) ,)),
                                IconButton(onPressed: (){
                                  Navigator.pop(context);
                                }, icon: Transform.rotate(
                                  
                                  angle: 3.12,
                                  child: Icon(Icons.arrow_back_ios_new,size:  MediaQuery.of(context).size.width* 0.05,))),
                              ],
                            )
                                                 ],
                                               ),
                                             ),
                                           ),),
                         ),
                            ],
                          ),
                            SizedBox(height: 20,),
                        Container(
                          height: 3,
                          child: isInProgress
                              ? LinearProgressIndicator(
                                  minHeight: 3,
                                )
                              : Container(
                                  height: 3,
                                ),
                        ),
                        Container(
                          margin: Spacing.fromLTRB(16, 0, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                                         Icon(Icons.add_location_alt,color: Colors.black,),
                              Text(
                                Translator.translate("delivery"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
                              ),
                            ],
                          ),
                        ),
                        _deliveryWidget(),
                        Container(
                          margin: Spacing.fromLTRB(16, 24, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.payments,color: Colors.black,),
                              Text(
                                Translator.translate("coupon_and_payment"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
                              ),
                            ],
                          ),
                        ),

            Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.06,
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      padding: Spacing.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: customAppTheme!.bgLayer4, width: 1),
        
      ),child:   InkWell(
             onTap: () async {
               int? paymentMethod ;
              showModalBottomSheet(context: context, builder:(context) {
                return PaymentOptionsScreen(total: total,isShop: true,type: widget.subcategories!.title =="New" ? 0 :1,quantity: widget.quantity,shopId: widget.shop!.id,);
              },).then((value) {
                log("value: "+value.toString());
               if(value!=null){
                paymentMethod = value;
              if (paymentMethod != null) {
                setState(() {
                  selectedPaymentMethod = paymentMethod!;
                });
              }
               }
              });
              // int? paymentMethod = await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) =>
              //             PaymentOptionsScreen()));

            },
            child: Container(
                margin: Spacing.top(4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      selectedPaymentMethod == -1
                          ? Text(
                              Translator.translate("select_payment"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            )
                          : Text(
                              Order.getPaymentTypeText(selectedPaymentMethod),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            ),
                      Text(
                        Translator.translate("change"),
                        style: TextStyle(color: Color(0xff15cb95),fontWeight: FontWeight.bold),
                      ),
                    ])),
          ),),

          SizedBox(height: 20,),

          Container(
                          margin: Spacing.fromLTRB(16, 0, 16, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                                         Icon(Icons.local_offer,color: Colors.black,),
                              Text(
                                Translator.translate("coupons"),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText1,
                                    fontWeight: 600),
                              ),
                            ],
                          ),
                        ),
           Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.06,
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      padding: Spacing.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: customAppTheme!.bgLayer4, width: 1),
        
      ),child:    InkWell(
            onTap: () async {

              Coupon? newCoupon ;
              showModalBottomSheet(context: context, builder:(context) {
                return CouponScreen(
                             order: order,
                             shopId: widget.shop!.id,
                           );
              },).then((value) {
                log("value: "+value.toString());
               if(value!=null){
                newCoupon = value;
              if (newCoupon != null) {
                setState(() {
                  coupon = newCoupon!;
                  if (coupon != null) {
                    couponDiscount = coupon!.getDiscountValue(order);
                  }
                  total = order + tax + deliveryFee - couponDiscount;
                });
              }
               }
              });

              
              // Coupon? newCoupon = await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => CouponScreen(
              //               order: order,
              //               shopId: widget.shop!.id,
              //             )));
              // if (newCoupon != null) {
              //   setState(() {
              //     coupon = newCoupon;
              //     if (coupon != null) {
              //       couponDiscount = coupon!.getDiscountValue(order);
              //     }
              //     total = order + tax + deliveryFee - couponDiscount;
                          
              //   });
              // }
            },
            child: Container(
              margin: Spacing.fromLTRB(0, 0, 0, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  coupon != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "#" + coupon!.code,
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            ),
                            Text(
                                "- " +
                                    coupon!.offer.toString() +
                                    "% " +
                                    Translator.translate("off").toUpperCase(),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontSize: 15,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500,
                                    letterSpacing: 0))
                          ],
                        )
                      : Container(
                          child: Text(
                          isInProgress
                              ? Translator.translate("please_wait")
                              : Translator.translate(
                                  "there_is_no_coupon_applied"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        )),
                  Text(
                    Translator.translate("change_coupon"),
                    style: TextStyle(color: Color(0xff15cb95),fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),),
                      //  _couponAndPayment(),

                        SizedBox(height: 5,),

                        Padding(
                       padding: const EdgeInsets.only(right:8.0,left: 8),
                          child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: isChecked, // a boolean value to control the state of the checkbox
                              onChanged: (bool? newValue) {
                                log(newValue.toString());
                                setState(() {
                                  isChecked = newValue!;
                                 if(isChecked==false){
                                  log("ia ma in");
                                  dateString="";
                                  timeString="";
                                  datePicker!.clear();
                                 } 
                                });
                              },
                            ),
                            Text(Translator.translate("onTime"),   style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),),
                          ],
                                              ),
                        ),

                         SizedBox(height: 5,),
                        isChecked ?   Padding(
                       padding: const EdgeInsets.only(right:50,left: 50),
                          child: TextField(controller: datePicker,readOnly: true,onTap: () async{
                            DateTime? pickedDate = await showOmniDateTimePicker(context: context);
                              dateString = DateFormat('dd-MM-yyyy').format(pickedDate!);
                              timeString = DateFormat('HH:mm').format(pickedDate);
                              datePicker?.text = dateString + "-" + timeString;
                          },),
                        ):Container(),

                        SizedBox(height: 5,),

                        Padding(
                          padding: const EdgeInsets.only(right:10,left: 10),
                          child: Container(
                            margin: Spacing.fromLTRB(5, 24, 16, 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                 Translator.translate("Order_Summery")  ,
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText1,
                                      fontWeight: 600),
                                ),
                        
                              ],
                            ),
                          ),
                        ),

                        _billWidget(),
                        // Container(
                        //   margin: Spacing.fromLTRB(16, 24, 16, 0),
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.end,
                        //     children: <Widget>[
                        //       Text(
                        //         Translator.translate("order"),
                        //         style: AppTheme.getTextStyle(
                        //             themeData.textTheme.bodyText1,
                        //             fontWeight: 600),
                        //       ),
                        //
                        //     ],
                        //   ),
                        // ),

                        Container(
                          margin: Spacing.fromLTRB(16, 24, 16, 16),
                          child: ElevatedButton(
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(Spacing.y(16)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ))),
                            onPressed: isInProgress || !validForDelivery
                                ? () {}
                                : () {
                                    _makeOrder();
                                  },
                            child: Text(
                              Order.isPaymentByCOD(selectedPaymentMethod)
                                  ? Translator.translate("place_order")
                                      .toUpperCase()

                                    
                                  : Translator.translate("proceed_to_payment")
                                      .toUpperCase(),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  letterSpacing: 0.6,
                                  fontWeight: 600,
                                  color: isInProgress || !validForDelivery
                                      ? customAppTheme!.onDisabled
                                      : themeData.colorScheme.onPrimary),
                            ),
                          ),
                        ),
                            SizedBox(height: 200,),
                      ],
                    ))));
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

  _deliveryWidget() {
    return Container(
      margin: Spacing.fromLTRB(16, 16, 16, 0),
      //padding: Spacing.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: customAppTheme!.bgLayer4, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // _selectOrderType(context);
            },
            child: Container(
                margin: Spacing.top(4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                        ],
                      ),

                    ])),
          ),
          (selectedOrderType == 2)
              ? Column(
            children: [
              // Divider(
              //   height: 24,
              // ),
              _addressWidget()
            ],
          )
              : Container(),
        ],
      ),
    );
  }

  _addressWidget() {
    if (userAddresses!.length == 0) {
      if (isInProgress) {
        return Container();
      } else {
        return GestureDetector(
          onTap: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddAddressScreen()));
            _refresh();
          },
          child: Row(
            children: <Widget>[
              // ClipRRect(
              //   borderRadius: BorderRadius.all(Radius.circular(4)),
              //   child: Image.asset(
              //     './assets/other/map-snap.png',
              //     height: 60.0,
              //     width: 86,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              Expanded(
                child: Container(
                  margin: Spacing.left(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        Translator.translate("no_saved_address"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.subtitle1,
                            color: themeData.colorScheme.onBackground,
                            fontWeight: 600),
                      ),
                      Text(
                        Translator.translate("click_to_add_one"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            color: themeData.colorScheme.onBackground
                                .withAlpha(150),
                            fontWeight: 500),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return GestureDetector(
        onTap: () {
          dynamic state = _addressSelectionKey.currentState;
          state.showButtonMenu();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                // ClipRRect(
                //   borderRadius: BorderRadius.all(Radius.circular(4)),
                //   child: Image.asset(
                //     './assets/other/map-snap.png',
                //     height: 60.0,
                //     width: 86,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                Expanded(
                  child: Container(
                    margin: Spacing.left(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          userAddresses![selectedAddress].address,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle1,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        ),
                        Text(
                          userAddresses![selectedAddress].city +
                              " - " +
                              userAddresses![selectedAddress]
                                  .pincode
                                  .toString(),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.caption,
                              color: themeData.colorScheme.onBackground
                                  .withAlpha(150),
                              fontWeight: 500),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  key: _addressSelectionKey,
                  icon: Icon(
                    Icons.add_location,
                   color: themeData.colorScheme.primary,
                    size: 25,
                  ),
                  onSelected: (dynamic value) async {
                    if (value == -1) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddAddressScreen()));
                      _refresh();
                    } else {
                      setState(() {
                        selectedAddress = value;
                      });
                      _calculateDistance();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    var list = <PopupMenuEntry<Object>>[];
                    for (int i = 0; i < userAddresses!.length; i++) {
                      list.add(PopupMenuItem(
                        value: i,
                        child: Container(
                          margin: Spacing.vertical(2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userAddresses![i].address,
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.subtitle2,
                                    fontWeight: 600,
                                    color: themeData.colorScheme.onBackground,
                                  )),
                              Container(
                                margin: Spacing.top(2),
                                child: Text(
                                    userAddresses![i].city +
                                        " - " +
                                        userAddresses![i].pincode.toString(),
                                    style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText2,
                                      color: themeData.colorScheme.onBackground,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ));
                      list.add(
                        PopupMenuDivider(
                          height: 10,
                        ),
                      );
                    }
                    list.add(PopupMenuItem(
                      value: -1,
                      child: Container(
                        margin: Spacing.vertical(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              MdiIcons.plus,
                              color: themeData.colorScheme.onBackground,
                              size: 20,
                            ),
                            Container(
                              margin: Spacing.left(4),
                              child: Text(
                                  Translator.translate("add_new_address"),
                                  style: AppTheme.getTextStyle(
                                    themeData.textTheme.bodyText2,
                                    color: themeData.colorScheme.onBackground,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ));
                    return list;
                  },
                  color: themeData.backgroundColor,
                ),
              ],
            ),
            validForDelivery
                ? Container()
                : Container(
                    margin: Spacing.top(4),
                    child: Text(
                      Translator.translate("you_are") +
                          " " +
                          distanceInText +
                          " " +
                          Translator.translate("far_from_shop") +
                          ". " +
                          Translator.translate(
                              "you_can_not_order_from_this_location"),
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          color: customAppTheme!.colorError, fontWeight: 600),
                    ))
          ],
        ),
      );
    }
  }



  _billWidget() {
    return Container(
         padding: const EdgeInsets.only(right:10,left: 10),
      margin: Spacing.fromLTRB(5, 2, 16, 0),
      child: Column(
        children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Translator.translate("item")),
                    SizedBox(height: 5,),
                Text(
                widget.subcategories!.title,
                style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyText1,
                    fontWeight: 600),
              ),

                  ],
                ),
                 Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(Translator.translate("amount")),
                     Text("${widget.quantity}",style: TextStyle(fontSize: 16),),

                   ],
                 ),
                  Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Translator.translate("price")),

                              Text(
                  CurrencyApi.getSign(afterSpace: true) +
                     (widget.subcategories!.price + widget.category!.commesion).toStringAsFixed(2),
                     
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      letterSpacing: 0,
                      muted: true,
                      fontWeight: 600)),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 10,),

                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                Translator.translate("delivery_fee"),
                style: AppTheme.getTextStyle(
                    themeData.textTheme.bodyText1,
                    fontWeight: 600),
              ),
              
              

                  ],
                ),
                 Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                   
                      width: 15, height: 2,  decoration: BoxDecoration(color: Colors.black,borderRadius: BorderRadius.circular(20)),),
                ),

                   ],
                 ),
                  Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                 

                                      Text(
                  CurrencyApi.getSign(afterSpace: true) +
                      deliveryFee.toStringAsFixed(2),
                  style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                      color: themeData.colorScheme.onBackground,
                      letterSpacing: 0,
                      muted: true,
                      fontWeight: 600)),
                    ],
                  ),
              ],
            ),
       
    




         Divider(thickness:1 ,),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(Translator.translate("total"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText1,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        fontWeight: 700)),
                     Text(
                    CurrencyApi.getSign(afterSpace: true) +
                        total.toStringAsFixed(3),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.onBackground,
                        letterSpacing: 0,
                        muted: true,
                        fontWeight: 600)),

              ],
            ),
          ),
        ],
      ),
    );
  }

  _couponAndPayment() {
    return Container(
        margin: Spacing.fromLTRB(16, 16, 16, 0),
        padding: Spacing.all(16),
        decoration: BoxDecoration(
            color: customAppTheme!.bgLayer1,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(color: customAppTheme!.bgLayer4, width: 1)),
        child: Column(children: <Widget>[

         
          InkWell(
            onTap: () async {

              Coupon? newCoupon ;
              showModalBottomSheet(context: context, builder:(context) {
                return CouponScreen(
                             order: order,
                             shopId: widget.shop!.id,
                           );
              },).then((value) {
                log("value: "+value.toString());
               if(value!=null){
                newCoupon = value;
              if (newCoupon != null) {
                setState(() {
                  coupon = newCoupon!;
                  if (coupon != null) {
                    couponDiscount = coupon!.getDiscountValue(order);
                  }
                  total = order + tax + deliveryFee - couponDiscount;
                });
              }
               }
              });

              
              // Coupon? newCoupon = await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) => CouponScreen(
              //               order: order,
              //               shopId: widget.shop!.id,
              //             )));
              // if (newCoupon != null) {
              //   setState(() {
              //     coupon = newCoupon;
              //     if (coupon != null) {
              //       couponDiscount = coupon!.getDiscountValue(order);
              //     }
              //     total = order + tax + deliveryFee - couponDiscount;
                          
              //   });
              // }
            },
            child: Container(
              margin: Spacing.fromLTRB(0, 0, 0, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  coupon != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "#" + coupon!.code,
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            ),
                            Text(
                                "- " +
                                    coupon!.offer.toString() +
                                    "% " +
                                    Translator.translate("off").toUpperCase(),
                                style: AppTheme.getTextStyle(
                                    themeData.textTheme.caption,
                                    fontSize: 15,
                                    color: themeData.colorScheme.onBackground,
                                    fontWeight: 500,
                                    letterSpacing: 0))
                          ],
                        )
                      : Container(
                          child: Text(
                          isInProgress
                              ? Translator.translate("please_wait")
                              : Translator.translate(
                                  "there_is_no_coupon_applied"),
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.bodyText2,
                              color: themeData.colorScheme.onBackground,
                              fontWeight: 600),
                        )),
                  Text(
                    Translator.translate("change_coupon"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        color: themeData.colorScheme.primary, fontWeight: 600),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          InkWell(
             onTap: () async {
              log("Hi iam pressing");
               int? paymentMethod ;
              showModalBottomSheet(context: context, builder:(context) {
                return PaymentOptionsScreen(total: total,);
              },).then((value) {
                log("value: "+value.toString());
               if(value!=null){
                paymentMethod = value;
              if (paymentMethod != null) {
                setState(() {
                  selectedPaymentMethod = paymentMethod!;
                });
              }
               }
              });
              // int? paymentMethod = await Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (BuildContext context) =>
              //             PaymentOptionsScreen()));

            },
            child: Container(
                margin: Spacing.top(4),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      selectedPaymentMethod == -1
                          ? Text(
                              Translator.translate("select_payment"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            )
                          : Text(
                              Order.getPaymentTypeText(selectedPaymentMethod),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.bodyText2,
                                  color: themeData.colorScheme.onBackground,
                                  fontWeight: 600),
                            ),
                      Text(
                        Translator.translate("change"),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.bodyText2,
                            color: themeData.colorScheme.primary,
                            fontWeight: 600),
                      ),
                    ])),
          )
        ]));
  }

  _selectOrderType(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                decoration: BoxDecoration(
                    color: themeData.backgroundColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16))),
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        Translator.translate("select_option").toUpperCase(),
                        style: AppTheme.getTextStyle(
                            themeData.textTheme.caption,
                            fontWeight: 600,
                            color: themeData.colorScheme.onBackground
                                .withAlpha(220)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                              //  _changeOrderType(1);
                                Navigator.pop(context);
                              },
                              child: Container(
                                  child: _optionWidget(
                                iconData: MdiIcons.storeOutline,
                                text: "Self Pickup",
                                isSelected: selectedOrderType == 1,
                              )),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          shop!.open==1
                              ? Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                    //  _changeOrderType(2);
                                      _calculateDistance();
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        child: _optionWidget(
                                      iconData: MdiIcons.mopedOutline,
                                      text: "Delivery",
                                      isSelected: selectedOrderType == 2,
                                    )),
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                      child: _optionWidget(
                                          iconData: MdiIcons.mopedOutline,
                                          text: "Delivery",
                                          isSelected: selectedOrderType == 2,
                                          isDisabled: true)),
                                ),
                        ],
                      ),
                    ),
                    shop!.open==1
                        ? Container()
                        : Container(
                            margin: Spacing.top(8),
                            child: Text(
                              Translator.translate(
                                  "this_shop_is_not_currently_available_for_delivery"),
                              style: AppTheme.getTextStyle(
                                  themeData.textTheme.caption,
                                  color: customAppTheme!.colorError,
                                  letterSpacing: 0),
                            ),
                          )
                  ],
                ),
              );
            },
          );
        });
  }

  _optionWidget(
      {IconData? iconData,
      required String text,
      bool? isSelected,
      bool isDisabled = false}) {
    return Container(
      decoration: BoxDecoration(
          color: isDisabled
              ? customAppTheme!.disabledColor
              : (isSelected!
                  ? themeData.colorScheme.primary
                  : themeData.backgroundColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(
              color: isDisabled
                  ? customAppTheme!.disabledColor
                  : (isSelected!
                      ? themeData.colorScheme.primary
                      : customAppTheme!.bgLayer4),
              width: 1)),
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Icon(
            iconData,
            color: isDisabled
                ? customAppTheme!.onDisabled
                : (isSelected!
                    ? themeData.colorScheme.onPrimary
                    : themeData.colorScheme.onBackground),
            size: 30,
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: AppTheme.getTextStyle(
                themeData.textTheme.caption,
                fontWeight: 600,
                color: isDisabled
                    ? customAppTheme!.onDisabled
                    : (isSelected!
                        ? themeData.colorScheme.onPrimary
                        : themeData.colorScheme.onBackground),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final Cart cart;
  final CustomAppTheme? customAppTheme;

  const _ProductDialog(
      {Key? key, required this.cart, required this.customAppTheme})
      : super(key: key);

  @override
  __ProductDialogState createState() => __ProductDialogState();
}

class __ProductDialogState extends State<_ProductDialog> {
  Product? product;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    product = widget.cart.product;
  }

  @override
  Widget build(BuildContext context) {


    ThemeData themeData = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: <Widget>[
             /*   ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: product!.imageUrl.length != 0
                      ? Image.network(
                          product!.imageUrl,
                          loadingBuilder: (BuildContext ctx, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return LoadingScreens.getSimpleImageScreen(
                                  context, themeData, widget.customAppTheme!,
                                  width: 90, height: 90);
                            }
                          },
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                    Product.getPlaceholderImage(),
                          height: 90,
                          fit: BoxFit.fill,
                        ),
                ),*/
                Expanded(
                  child: Container(
                    height: 90,
                    margin: EdgeInsets.only(left: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          product!.name!,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle2,
                              fontWeight: 600,
                              letterSpacing: 0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: <Widget>[
                            Generator.buildRatingStar(
                                rating: product!.rating,
                                activeColor: ColorUtils.getColorFromRating(
                                    product!.rating.ceil(),
                                    widget.customAppTheme,
                                    themeData),
                                size: 16,
                                inactiveColor:
                                    themeData.colorScheme.onBackground),
                            Container(
                              margin: EdgeInsets.only(left: 4),
                              child: Text(
                                  "(" + product!.totalRating.toString() + ")",
                                  style: AppTheme.getTextStyle(
                                      themeData.textTheme.bodyText1,
                                      fontWeight: 600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: Spacing.top(8),
              padding: Spacing.all(16),
              decoration: BoxDecoration(
                  color: widget.customAppTheme!.bgLayer1,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                      color: widget.customAppTheme!.bgLayer4, width: 1)),
              child: ProductUtils.singleProductItemOption(
                  widget.cart.productItem!, themeData, widget.customAppTheme),
            )
          ],
        ),
      ),
    );
  }
}
