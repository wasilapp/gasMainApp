import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/CategoryController.dart';


import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';

import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:EMallApp/utils/navigator.dart';
import 'package:EMallApp/views/CartScreen.dart';
import 'package:EMallApp/views/CartScreenForShop.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/SearchScreen.dart';
import 'package:EMallApp/views/ShopScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../models/Categories.dart';
import '../utils/fonts.dart';
import 'ProductScreen.dart';

class CategoryShopScreen extends StatefulWidget {
  final Category? category;
  final  SubCategory? subcategories;

  const CategoryShopScreen({Key? key, this.category,this.subcategories}) : super(key: key);

  @override
  _CategoryShopScreenState createState() => _CategoryShopScreenState();
}

class _CategoryShopScreenState extends State<CategoryShopScreen> {
  //Theme Data
  ThemeData? themeData;
  late CustomAppTheme customAppTheme;

  

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<Shop>? shops;

  @override
  void initState() {
    super.initState();
    _getShop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getShop() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Shop>> myResponse =
        await CategoryController.getCategoryShops(widget.category!.id);

    if (myResponse.success) {
      print("love fp");
      shops = myResponse.data;

    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    if (!isInProgress) _getShop();
  }

  @override
  Widget build(BuildContext context) {
   
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
      themeData = AppTheme.getThemeFromThemeMode(value.themeMode());
      customAppTheme = AppTheme.getCustomAppTheme(value.themeMode());
      return MaterialApp(
          scaffoldMessengerKey: _scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: DefaultTabController(
            length: widget.category!.shops.length==0 ? 1: 2,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  // leading: InkWell(
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  //   child: Icon(MdiIcons.chevronLeft),
                  // ),
                  centerTitle: true,
                 /* title: Text(widget.category!.title,
                      style: AppTheme.getTextStyle(
                          themeData!.appBarTheme.textTheme!.headline6,
                          fontWeight: 600)),*/
                ),
                backgroundColor: themeData!.backgroundColor,
                body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData!.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Container(
                      child: Column(
                        mainAxisAlignment:  shops==null || shops!.length==0? MainAxisAlignment.center:MainAxisAlignment.start,
                        children: [
          
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
          
                   
                  Padding(padding: EdgeInsets.only(right:8,left: 8),child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.06 ,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Color(0xff15cb95),),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.subcategories!.title.toString() + " " + widget.category!.title.toString(),style:TextStyle(fontWeight: FontWeight.w600 ,color: Colors.white) ,),
          
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
                                child: Icon(Icons.arrow_back_ios_new,size: MediaQuery.of(context).size.width* 0.05 ,))),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),),
              SizedBox(height:20,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Theme(
                      data: ThemeData().copyWith(splashColor:Color(0xff15cb95),),
                      child: TabBar(
                        
                        labelColor: Color(0xff15cb95),
                        indicatorColor: Color(0xff15cb95),
                        dividerColor: Color(0xff15cb95),
                        
                        
                        
                                    tabs: widget.category!.shops.length==0? [
                                             Tab(icon: Row(
                                        children: [
                                          Icon(Icons.local_shipping_outlined,size: 50,),
                                          SizedBox(width: 2,),
                                          Text(Translator.translate("Order_from_your_nearest_delivery"),style: TextStyle(    fontWeight: FontWeight.w600),)
                                           ],
                                           ),),
                                    ] : [
                      Tab(icon: Row(
                        children: [
                          Icon(Icons.store,size: 50,),
                          SizedBox(width: 2,),
                          Text(Translator.translate("Order_from_your_favourite_store"),style: TextStyle(    fontWeight: FontWeight.w600),)
                        ],
                      ),),
                       Tab(icon: Row(
                        children: [
                          Icon(Icons.local_shipping_outlined,size: 50,),
                          SizedBox(width: 2,),
                          Text(Translator.translate("Order_from_your_nearest_delivery"),style: TextStyle(fontSize: 15),)
                        ],
                                           ),),
                                   
                                     
                                    ],
                                  ),
                    ),
                  ),

                  SizedBox(height: 10,),
                  Divider(),
                  InkWell(
                    onTap: () {
                      pushScreen(context, SearchScreen(category: widget.category,subcategories: widget.subcategories,));
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.search,size: MySize.size18,color: Colors.grey,),
                        SizedBox(width: 10,),
                         Text(Translator.translate("search_word"),style: TextStyle(color: Color.fromARGB(255, 126, 125, 125),fontSize:MySize.size18 ),),
                      ],),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: TabBarView(
                              children: widget.category!.shops.length==0? [
                                                               CartScreen(subcategories: widget.subcategories,category: widget.category,),
                              ]: [
                                _buildBody(),
                               CartScreen(subcategories: widget.subcategories,category: widget.category,),
                               
                              ],
                            ),
                  ),
          
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                              
                          //    InkWell(
                          //        onTap: (){
                          //          Navigator.push(
                          //            context,
                          //            MaterialPageRoute(
                          //              builder: (context) => CartScreen(subcategories: widget.subcategories,category: widget.category,),
                          //            ),
                          //          );
                          //        },
                          //        child: _button()),
          
                          //   ],
                          // ),
                //          SizedBox(height: 10,),
                //            shops==null || shops!.length==0? Container()  : Text(Translator.translate('OR'),style: TextStyle(color: customAppTheme.colorInfo,fontSize: 19),),
                //         shops==null || shops!.length==0? Container()  :  Text(Translator.translate("Order_from_your_favourite_store"),style: TextStyle(color: customAppTheme.colorSuccess,fontSize: 12),),
                //         shops==null || shops!.length==0? Container()  :    SizedBox(height: 10,),
                //  shops==null || shops!.length==0? Container()  :   Expanded(child: _buildBody()),
                ],
              ),
            ))),
          ));
    });
  }
  Widget searchBar() {
    return Padding(
        padding: Spacing.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                elevation: 4,
                child: TextFormField(
                  style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
                      letterSpacing: 0, fontWeight: 500),
                  decoration: InputDecoration(
                    hintText: Translator.translate("search"),
                    hintStyle: AppTheme.getTextStyle(
                        themeData!.textTheme.subtitle2,
                        letterSpacing: 0,
                        fontWeight: 500),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none),

                    prefixIcon: Icon(
                      MdiIcons.magnify,
                      size: 22,
                      color: themeData!.colorScheme.onBackground.withAlpha(200),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.only(right: 16),
                  ),
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchScreen(category: widget.category,subcategories: widget.subcategories,)));
                },

                ),
              ),
            ),
            InkWell(
              onTap: () {
                _scaffoldKey.currentState!.openEndDrawer();
              },
              child: Container(
                margin: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: customAppTheme!.colorSuccess,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: customAppTheme!.bgLayer4),
                  boxShadow: [
                    BoxShadow(
                      color: customAppTheme!.shadowColor,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                padding: Spacing.all(12),
                child: Icon(
                  MdiIcons.swapVertical,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ));
  }




  _buildBody() {
    if (shops != null) {
      if (shops!.length == 0) {
        return Center(
          child: Text(
              Translator.translate("there_is_no_product_with_this_category")),
        );
      }
      return _showShops(shops!);
    } else if (isInProgress) {
      return LoadingScreens.getSearchLoadingScreen(
          context, themeData!, customAppTheme);
    }
    else {
      return Center(
        child: Text(Translator.translate("something_wrong")),
      );
    }
  }

  Widget _showShops(List<Shop> shops,) {
    List<Widget> listWidgets = [];

    for (int i = 0; i < shops.length; i++) {
      // shops[i].mangerName!='aaa'?
      listWidgets.add(InkWell(
        onTap: () {
               Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) => CartScreenForShop(subcategories: widget.subcategories,category: widget.category,shop: shops[i],)));
        },
        child: Container(
          margin: Spacing.bottom(5),
          child: Column(
            children: [

              singleShop(shops[i]),
              Divider()
            ],
          ),
        ),
      ))
    //:print('shop not assign')
      ;

    }

    return Container(
      margin: Spacing.fromLTRB(16, 0, 16, 0),
      child: ListView(
        children: listWidgets,
      ),
    );
  }

  Widget singleShop(Shop shop) {
    return Container(

      padding: Spacing.all(9),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
            child: shop.imageUrl.length != 0
                ? Image.network(
          TextUtils.getImageUrl(shop.imageUrl)    ,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return LoadingScreens.getSimpleImageScreen(
                            context, themeData, customAppTheme,
                            width: MySize.size90, height: MySize.size90);
                      }
                    },
                    height: MySize.size120,
              width: MySize.size120,
              fit: BoxFit.cover,
            )
                : Image.asset(
              Shop.getPlaceholderImage(),
              height: MySize.size90,
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Container(
              height: MySize.size120,
              margin: Spacing.left(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name!,
                        style: AppTheme.getTextStyle(
                            themeData!.textTheme.subtitle2,
                            fontWeight: 600,
                            letterSpacing: 0),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        shop.address!,
                        style: AppTheme.getTextStyle(
                            themeData!.textTheme.bodySmall,
                            fontWeight: 300,
                            letterSpacing: 0),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Generator.buildRatingStar(
                          rating: double.parse(shop.rating.toString()) ,
                          size: MySize.size16,
                          inactiveColor: themeData!.colorScheme.onBackground),
                      Container(
                        margin: Spacing.left(4),
                        child: Text( shop.totalRating.toString(),
                            style: AppTheme.getTextStyle(
                                themeData!.textTheme.bodyText1,
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
    );
  }


  void showMessage({String message = "Something wrong", Duration? duration}) {
    if (duration == null) {
      duration = Duration(seconds: 1);
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

  Widget _button() {
    return Card(

      elevation: 4,
      color: Color(0xffF8F8F8),
      child: Container(
          height: 50,
          width: 250,
          child: Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(Translator.translate("Order_from_your_nearest_delivery"),style: TextStyle(color: customAppTheme.colorSuccess,fontSize: 12),),
          ))),
    );
  }



}
