import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';


import 'package:EMallApp/models/Filter.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/Product.dart';


import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:EMallApp/views/LoadingScreens.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../controllers/CategoryController.dart';
import '../models/Categories.dart';
import '../utils/Generator.dart';
import 'CartScreenForShop.dart';

class SearchScreen extends StatefulWidget {
    final Category? category;
  final  SubCategory? subcategories;

  const SearchScreen({Key? key,required this.category,required this.subcategories}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //Theme Data
  ThemeData? themeData;
  CustomAppTheme? customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<bool> _dataExpansionPanel = [true];
  List<Shop>? shops = [];
  //List<Category>? categories = [];
  double _minPrice = 0;
  double _maxPrice = 100;
  double findAspectRatio(double width) {
    //Logic for aspect ratio of grid view
    return (width / 2 - MySize.size24!) / ((width / 2 - MySize.size24!) + 60);
  }

  //Filter Variable
  Filter filter = Filter();

  @override
  void initState() {
    super.initState();
    if (mounted) {
 //  _filterShopData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Pull to refresh call this function
  Future<void> _refresh() async {
    _filterShopData("");
  }

  //Get all filter product data
  _filterShopData(search) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Shop>> myResponseShop =
      await CategoryController.getCategoryShopsSearch(widget.category!.id,search);
     print("shopsearch start");
    if (myResponseShop.success) {
      print("shop search done${myResponseShop.data}");
      setState(() {
        shops = myResponseShop.data;
      });

      print(myResponseShop.data);

    } else {
      if (mounted) {
        print(myResponseShop.responseCode);
        // ApiUtil.checkRedirectNavigation(
        //     context, myResponseShop.responseCode);
        showMessage(message: myResponseShop.errorText);
      }
    }


    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  _clearFilter() {
    setState(() {
      filter = Filter();
    });
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
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: SafeArea(
              child: Scaffold(
                  backgroundColor: customAppTheme!.bgLayer1,
                  resizeToAvoidBottomInset: false,
                 // endDrawer: _endDrawer(),
                  key: _scaffoldKey,
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme!.bgLayer1,
                    color: themeData!.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
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
                        Expanded(
                            child: Column(
                          children: [
                            searchBar(),
                            Expanded(child: _buildBody()),
                          ],
                        ))
                      ],
                    ),
                  )),
            ));
      },
    );
  }



  _buildBody() {
    if (shops != null) {
      if (shops!.length == 0) {
        return Center(
          child: Text(
              Translator.translate("search")),
        );
      }
      return _showShops(shops!);
    } else if (isInProgress) {
      return LoadingScreens.getSearchLoadingScreen(
          context, themeData!, customAppTheme!);
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
      ));
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
                            context, themeData, customAppTheme!,
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

  // Widget buildBody() {
  //   print("mero$shops");
  //   if (shops!.length != 0) {
  //     return Container(margin: Spacing.top(4), child: _showShops(shops!));
  //   } else if (isInProgress) {
  //     return Container(
  //         margin: Spacing.top(16),
  //         child: LoadingScreens.getSearchLoadingScreen(
  //             context, themeData!, customAppTheme!,
  //             itemCount: 5));
  //   } else {
  //     return Center(
  //         child: Container(
  //             margin: Spacing.top(16),
  //             child: Text(
  //               Translator.translate("search"),
  //             )));
  //   }
  // }


  _singleShop(Shop shop) {
    return Stack(
      children: [
        Container(
          padding: Spacing.all(16),
          margin: Spacing.zero,
          decoration: BoxDecoration(
            color: customAppTheme!.bgLayer1,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: customAppTheme!.bgLayer4),
            boxShadow: [
              BoxShadow(
                color: customAppTheme!.shadowColor,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: shop.imageUrl.length != 0
                    ? Image.network(
                       TextUtils.getImageUrl(shop.imageUrl)   ,
                        loadingBuilder: (BuildContext ctx, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return LoadingScreens.getSimpleImageScreen(
                                context, themeData, customAppTheme!,
                                width: 90, height: 90);
                          }
                        },
                        width: MediaQuery.of(context).size.width * 0.35,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        Product.getPlaceholderImage(),
                        width: MediaQuery.of(context).size.width * 0.35,
                        fit: BoxFit.fill,
                      ),
              ),
              Spacing.height(2),
              Text(
                shop.name!,
                style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                    fontWeight: 600, letterSpacing: 0),
                overflow: TextOverflow.ellipsis,
              ),
              Spacing.height(3),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      shop.imageUrl.length.toString() +
                          " " +
                          Translator.translate("options"),
                      style: AppTheme.getTextStyle(
                          themeData!.textTheme.bodyText2,
                          fontWeight: 500),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: themeData!.colorScheme.primary,
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                      padding: EdgeInsets.only(
                          left: 6,
                          right: 8,
                          top: 2,
                          bottom: MySize.getScaledSizeHeight(3.5)),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.star,
                            color: themeData!.colorScheme.onPrimary,
                            size: 12,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 4),
                            child: Text(shop.rating.toString(),
                                style: AppTheme.getTextStyle(
                                    themeData!.textTheme.caption,
                                    fontSize: 15,
                                    color: themeData!.colorScheme.onPrimary,
                                    fontWeight: 600)),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ],
          ),
        ),

      ],
    );
  }

  Widget searchBar() {
    return Padding(
        padding: Spacing.fromLTRB(16, 16, 16, 0),
        child: Row(
          children: <Widget>[
            Expanded(
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
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: themeData!.colorScheme.background,
                  prefixIcon: Icon(
                    MdiIcons.magnify,
                    size: 22,
                    color: themeData!.colorScheme.onBackground.withAlpha(200),
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.only(right: 16),
                ),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (value) {
                   filter.name = value;
                  _filterShopData(value);
                },
              ),
            ),
            // InkWell(
            //   onTap: () {
            //     _scaffoldKey.currentState!.openEndDrawer();
            //   },
            //   child: Container(
            //     margin: EdgeInsets.only(left: 16),
            //     decoration: BoxDecoration(
            //       color: customAppTheme!.bgLayer1,
            //       borderRadius: BorderRadius.all(Radius.circular(8)),
            //       border: Border.all(color: customAppTheme!.bgLayer4),
            //       boxShadow: [
            //         BoxShadow(
            //           color: customAppTheme!.shadowColor,
            //           blurRadius: 2,
            //           offset: Offset(0, 1),
            //         )
            //       ],
            //     ),
            //     padding: Spacing.all(12),
            //     child: Icon(
            //       MdiIcons.tune,
            //       color: themeData!.colorScheme.primary,
            //       size: 22,
            //     ),
            //   ),
            // ),
          ],
        ));
  }



  // _endDrawer() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.75,
  //     color: themeData!.backgroundColor,
  //     child: ListView(
  //       children: <Widget>[
  //         Container(
  //             padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
  //             alignment: Alignment.center,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   Translator.translate("filter").toUpperCase(),
  //                   style: AppTheme.getTextStyle(themeData!.textTheme.subtitle1,
  //                       fontWeight: 700, color: themeData!.colorScheme.primary),
  //                 ),
  //                 InkWell(
  //                   onTap: () {
  //                     _clearFilter();
  //                   },
  //                   child: Text(
  //                     Translator.translate("clear"),
  //                     style: AppTheme.getTextStyle(
  //                         themeData!.textTheme.bodyText2,
  //                         fontWeight: 500,
  //                         color: themeData!.colorScheme.onBackground),
  //                   ),
  //                 ),
  //               ],
  //             )),
  //   /*      Container(
  //           margin: Spacing.top(24),
  //           child: ExpansionPanelList(
  //             expandedHeaderPadding: Spacing.all(0) as EdgeInsets,
  //             dividerColor: Colors.transparent,
  //             expansionCallback: (int index, bool isExpanded) {
  //               setState(() {
  //                 _dataExpansionPanel[index] = !isExpanded;
  //               });
  //             },
  //             animationDuration: Duration(milliseconds: 500),
  //             children: <ExpansionPanel>[
  //               ExpansionPanel(
  //                   canTapOnHeader: true,
  //                   headerBuilder: (BuildContext context, bool isExpanded) {
  //                     return ListTile(
  //                       title: Text(Translator.translate("category"),
  //                           style: AppTheme.getTextStyle(
  //                               themeData!.textTheme.bodyText1,
  //                               color: isExpanded
  //                                   ? themeData!.colorScheme.primary
  //                                   : themeData!.colorScheme.onBackground,
  //                               fontWeight: isExpanded ? 700 : 600)),
  //                     );
  //                   },
  //                   body: Container(
  //                       padding: Spacing.fromLTRB(16, 0, 0, 0),
  //                       child: categoryFilterList()),
  //                   isExpanded: _dataExpansionPanel[0]),
  //             ],
  //           ),
  //         ),*/

  //         Container(
  //           padding: EdgeInsets.fromLTRB(5, 24, 24, 24),
  //           alignment: Alignment.center,
  //           child: Text("Choose the Range of price You want :",
  //               style: AppTheme.getTextStyle(
  //               themeData!.appBarTheme.textTheme!.headline6,
  //               fontWeight: 600)),
  //         ),

  //         RangeSlider(
  //           values: RangeValues(_minPrice, _maxPrice),
  //           min: 0,
  //           max: 100,
  //           divisions: 100,
  //           labels: RangeLabels(

  //             '\$ ${_minPrice.round()}',
  //             '\$ ${_maxPrice.round()}',
  //           ),
  //           onChanged: (RangeValues values) {
  //             setState(() {
  //               _minPrice = values.start;
  //               filter.min_price = values.start;
  //               _maxPrice = values.end;
  //               filter.max_price =values.end;
  //             });
  //           },
  //         ),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //             Container(
  //               margin: EdgeInsets.all(24),
  //               width: MediaQuery.of(context).size.width,
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.all(Radius.circular(4)),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: themeData!.colorScheme.primary.withAlpha(24),
  //                       blurRadius: 3,
  //                       offset: Offset(0, 2), // changes position of shadow
  //                     ),
  //                   ],
  //                 ),
  //                 child: ElevatedButton(
  //                   style: ButtonStyle(
  //                       padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
  //                       shape: MaterialStateProperty.all(RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(4),
  //                       ))),
  //                   onPressed: () {
  //                     _scaffoldKey.currentState!.openDrawer();
  //                     _filterShopData();
  //                   },
  //                   child: Text(
  //                     Translator.translate("apply").toUpperCase(),
  //                     style: AppTheme.getTextStyle(
  //                         themeData!.textTheme.bodyText2,
  //                         fontWeight: 600,
  //                         color: themeData!.colorScheme.onPrimary,
  //                         letterSpacing: 0.3),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

/*  Widget categoryFilterList() {
    List<Widget> list = [];
    for (Category category in categories!) {
      if (category.shops!.length != 0) {
        list.add(Container(
            margin: Spacing.left(4),
            child: Text(
              category.title,
              style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                  fontWeight: 600, muted: true),
            )));

        List<Widget> shopsWidget = [];
        for (Shop shop in category.shops!) {
          shopsWidget.add(Container(
            child: InkWell(
              onTap: () {
                setState(() {
                  filter.toggleShop(shop.id!);
                });
              },
              child: Row(
                children: <Widget>[
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: filter.shops.contains(shop.id),
                    activeColor: themeData!.colorScheme.primary,
                    onChanged: (bool? value) {
                      setState(() {
                        filter.toggleShop(shop.id!);
                      });
                    },
                  ),
                  Container(
                      margin: Spacing.left(4),
                      child: Text(
                        shop.name,
                        style: AppTheme.getTextStyle(
                          themeData!.textTheme.bodyText2,
                          fontWeight: 500,
                        ),
                      ))
                ],
              ),
            ),
          ));
        }

        list.add(Container(
          margin: Spacing.fromLTRB(16, 4, 0, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: shopsWidget,
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }*/
}
