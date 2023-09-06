/*
import 'dart:developer';

import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/currency_api.dart';
import 'package:EMallApp/controllers/ShopController.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';
import 'package:EMallApp/models/Shop.dart';
import 'package:EMallApp/models/SubCategory.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/Generator.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/UrlUtils.dart';
import 'package:EMallApp/views/CartScreen.dart';
import 'package:EMallApp/views/DateandTimeDelivey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/CategoryController.dart';
import 'LoadingScreens.dart';
import 'ProductScreen.dart';

class ShopScreen extends StatefulWidget {
  final int? shopId;

  const ShopScreen({Key? key, this.shopId}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  //ThemeData
  ThemeData? themeData;
  late CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  double findAspectRatio(double width) {
    //Logic for aspect ratio of grid view
    return (width / 2 - 24) / ((width / 2 - 24) + 60);
  }
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  //Other variables
  Shop? shop;
  bool isInProgress = false;
  int? supcatigo =1 ;
  List<SubCategory>? subcategories;
  List<Product>? products;
  bool _item1Selected=false;
  bool _item2Selected=false;
  @override
  void initState() {
    super.initState();
    _getShopData();
    _getSubcategories(widget.shopId!);


  }

  @override
  void dispose() {
    super.dispose();
  }



  _getProducts(int id) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Product>> myResponse =
    await ShopController.getSubCategoryProducts(id);
print(myResponse.success);
    if (myResponse.success) {
      print("subproducts done12");
      print(myResponse.data);
      products = myResponse.data;

    } else {
      print(myResponse.data);
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }


  _getSubcategories(int id) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<SubCategory>> myResponse =
    await ShopController.getShopSubCategory(id);

    if (myResponse.success) {
      print("sub done12");
      print(myResponse.data);
      shop!.sub_categories = myResponse.data;
      if(shop!.sub_categories!.isNotEmpty) {
        setState(() {
          supcatigo = shop!.sub_categories!.first.id;
          _getProducts(shop!.sub_categories!.first.id);
          _refresh();

        });
      }

    } else {
      print("sub er");
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }






  _getShopData() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Shop> myResponse =
    await ShopController.getSingleShop(widget.shopId);

    if (myResponse.success) {
      shop = myResponse.data;
      log(shop.toString());
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
    if (!isInProgress){
      _getShopData();
      _getSubcategories(widget.shopId!);

    }
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
              home: Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    backgroundColor: customAppTheme.bgLayer1,
                    elevation: 0,
                    leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(MdiIcons.chevronLeft),
                    ),
                    centerTitle: true,
                    title: Text(
                        shop != null ? shop!.name : Translator.translate("loading"),
                        style: AppTheme.getTextStyle(
                            themeData!.appBarTheme.textTheme!.headline6,
                            fontWeight: 600)),
                  ),
                  backgroundColor: customAppTheme.bgLayer1,
                  body: Container(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: Spacing.zero,
                            children: [
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
                              _buildBody(),

                            ],
                          ),
                        ),
                        _makeBottomBar(),
                      ],
                    ),
                  )));
        });
  }

  _buildBody() {
    if (shop != null) {
      return _buildShop();





    } else {
      return Container();
    }
  }




  _buildShop() {

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Container(
        margin:Spacing.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
      color: customAppTheme.bgLayer1,
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
        border: Border.all(color: customAppTheme.bgLayer4),
        boxShadow: [
          BoxShadow(
            color: customAppTheme.shadowColor,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: Spacing.all(16),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8!)),
            child: shop!.imageUrl.length != 0
                ? Image.network(
              shop!.imageUrl,
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
              height: MySize.size60,
              width: MySize.size60,
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
              height: MySize.size60,
              margin: Spacing.left(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          shop!.name,
                          style: AppTheme.getTextStyle(
                              themeData!.textTheme.subtitle2,
                              fontWeight: 600,
                              letterSpacing: 0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Generator.buildRatingStar(
                          rating: shop!.rating,
                          size: MySize.size16,
                          inactiveColor: themeData!.colorScheme.onBackground),
                      Container(
                        margin: Spacing.left(4),
                        child: Text( shop!.totalRating.toString(),
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
    ),
        shop!.salad==true?  Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            padding: Spacing.all(8),
            decoration: BoxDecoration(
                color: customAppTheme.bgLayer1,
                borderRadius: BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
            child: ListTile(
              title: Text('Salad'),
              trailing: shop!.price_salad==0? Text('Free'):Text("${shop!.price_salad.toString()  + CurrencyApi.CURRENCY_SIGN.toString()}"),
              selected: _item1Selected,
              onTap: () {
                setState(() {
                  _item1Selected =! _item1Selected;
                });
              },
            )

          ):Container(),


          shop!.snacks==true?  Container(
              margin: Spacing.fromLTRB(16, 16, 16, 0),
              padding: Spacing.all(8),
              decoration: BoxDecoration(
                  color: customAppTheme.bgLayer1,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: customAppTheme.bgLayer4, width: 1)),
              child: ListTile(
                title: Text('Snacks'),
                trailing: shop!.price_snacks==0? Text('Free'):Text("${shop!.price_snacks.toString()  + CurrencyApi.CURRENCY_SIGN.toString()}"),
                selected: _item2Selected,
                onTap: () {
                  setState(() {
                    _item2Selected =! _item2Selected;
                  });
                },
              )

          ):Container(),
         */
/* Container(
            margin: Spacing.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
              shop!.salad == true?  Expanded(
                  child:shop!.price_salad == 0? Text("free"):Text("${shop!.price_salad}"),
                ):Expanded(
                child: Text("fbgdz"),
              ),
                SizedBox(
                  width: 16,
                ),
                shop!.snacks == true?  Expanded(
                  child:shop!.price_snacks == 0? Text("free"):Text("${shop!.price_snacks}"),
                ):Expanded(
                  child: Text("fdzgb"),
                ),
              ],
            ),
          ),*//*

          Container(
            margin: Spacing.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            */
/*    Text(
                  Translator.translate("products"),
                  style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                      color: themeData!.colorScheme.onBackground,
                      fontWeight: 600),
                ),*//*

                Row(
                  children: [
                    _buildScroll(shop!.sub_categories!),
                  ],
                ),

                buildProdSub(),
              ],
            ),
          ),



        ],
      ),
    );
  }
  _makeBottomBar() {
    return Container(

      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: customAppTheme!.shadowColor,
                blurRadius: MySize.size2!,
                offset: Offset(0, 0))
          ],
          border: Border.all(color: customAppTheme!.bgLayer4, width: 1),
          color: customAppTheme!.bgLayer1,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(MySize.size16!),
              topRight: Radius.circular(MySize.size16!))),
      padding: Spacing.symmetric(vertical: 16, horizontal: 16),
      child: Container(

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DateTimeDelivery(
                      shopId: widget.shopId!,
                      shopTimes:shop!.shop_times,
                      shop: shop! ,
                    )));
              },
              child: Container(
                width: 300,
                margin: Spacing.left(16),
                padding: Spacing.all(16),
                decoration: BoxDecoration(
                    color: themeData!.colorScheme.primary.withAlpha(40),
                    borderRadius:
                    BorderRadius.all(Radius.circular(MySize.size8!))),
                child: Center(
                  child: Text(
                    "Next",
                    style: AppTheme.getTextStyle(themeData!.textTheme.titleLarge,
                        fontWeight: 900, letterSpacing: 0),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget buildProdSub(){
    if (products != null) {
      if (products!.length == 0) {
        return Center(
          child: Text(
              Translator.translate("there_is_no_product_with_this_category")),
        );
      }
      return _showProducts(products!);
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

  _buildScroll(List<SubCategory> sub_categories){
    return Container(
      height: 80,
      width: 250,

      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sub_categories!.length,
          itemBuilder: (BuildContext context,int index){
            return GestureDetector(
                onTap: (){
                  print(sub_categories![index].id.toString());
                  setState(() {

                    supcatigo = sub_categories![index].id;
                    _getProducts(sub_categories![index].id);
                    _refresh();
                  });
                },
                child:sub_categories![index].id == supcatigo?Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.green
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                    // color: Colors.black,
                    child: Text(sub_categories![index].title,style: TextStyle(color: Colors.white,fontSize: 20),),
                  ),
                ): Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                    // color: Colors.black,
                    child: Text(sub_categories![index].title,style: TextStyle(color: Colors.green,fontSize: 20),),
                  ),
                )
            );
          }
      ),
    );

  }

  _showProducts(List<Product> products) {
    List<Widget> listWidgets = [];

  */
/*  for (int i = 0; i < products.length; i++) {
      listWidgets.add(InkWell(
        onTap: () async {
         // Product? newProduct = await Navigator.push(
         //      context,
         //      MaterialPageRoute(
         //          builder: (context) => ProductScreen(
         //                productId: products[i].id,
         //              )));

        },
        child: Container(
          margin: Spacing.bottom(16),
          child: _singleProduct(products[i]),
        ),
      ));
    }*//*


    return Container(
      height: 110,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: Spacing.right(16),
            child: _singleProduct(products[index]),
          ) ;
        },

      ),
    );
  }

  _singleProduct(Product product) {
    return Container(

      margin: Spacing.zero,
      decoration: BoxDecoration(
        color: customAppTheme.bgLayer1,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: customAppTheme.bgLayer4),
        boxShadow: [
          BoxShadow(
            color: customAppTheme.shadowColor,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: product.imageUrl.length != 0
            ? Image.network(
                product.imageUrl,
                loadingBuilder: (BuildContext ctx, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return LoadingScreens.getSimpleImageScreen(
                        context, themeData, customAppTheme,
                        width: 90, height: 90);
                  }
                },
                width: MediaQuery.of(context).size.width * 0.25,
                fit: BoxFit.cover,
              )
            : Image.asset(
                Product.getPlaceholderImage(),
                width: MediaQuery.of(context).size.width * 0.35,
                fit: BoxFit.fill,
              ),
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
*/
