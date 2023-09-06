// import 'package:EMallApp/AppTheme.dart';
// import 'package:EMallApp/AppThemeNotifier.dart';
// import 'package:EMallApp/api/api_util.dart';
// import 'package:EMallApp/controllers/FavoriteController.dart';
// import 'package:EMallApp/models/Favorite.dart';
// import 'package:EMallApp/models/MyResponse.dart';
// import 'package:EMallApp/models/Product.dart';
// import 'package:EMallApp/services/AppLocalizations.dart';
// import 'package:EMallApp/utils/SizeConfig.dart';
// import 'package:EMallApp/utils/TextUtils.dart';
// import 'package:EMallApp/views/ProductScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:provider/provider.dart';

// import 'LoadingScreens.dart';

// class FavoriteScreen extends StatefulWidget {
//   @override
//   _FavoriteScreenState createState() => _FavoriteScreenState();
// }

// class _FavoriteScreenState extends State<FavoriteScreen> {
//   //Theme Data
//   ThemeData? themeData;
//   CustomAppTheme? customAppTheme;

//   //Global Keys
//   final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
//       new GlobalKey<ScaffoldMessengerState>();

//   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//       new GlobalKey<RefreshIndicatorState>();

//   double findAspectRatio(double width) {
//     //Logic for aspect ratio of grid view
//     return (width / 2 - MySize.size24!) / ((width / 2 - MySize.size24!) + 60);
//   }

//   //Other Variables
//   bool isInProgress = false;
//   List<Favorite>? favorites = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadFavoriteProducts();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   _loadFavoriteProducts() async {
//     if (mounted) {
//       setState(() {
//         isInProgress = true;
//       });
//     }

//     MyResponse<List<Favorite>> myResponse =
//         await FavoriteController.getAllFavorite();

//     if (myResponse.success) {
//       favorites = myResponse.data;
//     } else {
//       ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
//       showMessage(message: myResponse.errorText);
//     }

//     if (mounted) {
//       setState(() {
//         isInProgress = false;
//       });
//     }
//   }


//   Future<void> _refresh() async{
//     _loadFavoriteProducts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppThemeNotifier>(
//       builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
//         int themeType = value.themeMode();
//         themeData = AppTheme.getThemeFromThemeMode(themeType);
//         customAppTheme = AppTheme.getCustomAppTheme(themeType);
//         return MaterialApp(
//             scaffoldMessengerKey: _scaffoldMessengerKey,
//             debugShowCheckedModeBanner: false,
//             theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
//             home: Scaffold(
//                 backgroundColor: customAppTheme!.bgLayer1,
//                 key: _scaffoldKey,
//                 appBar: AppBar(
//                   backgroundColor: customAppTheme!.bgLayer1,
//                   elevation: 0,
//                   centerTitle: true,
//                   title: Text(Translator.translate("favorites"),
//                       style: AppTheme.getTextStyle(
//                           themeData!.appBarTheme.textTheme!.headline6,
//                           fontWeight: 600)),
//                 ),
//                 body: RefreshIndicator(
//                   onRefresh: _refresh,
//                   backgroundColor: customAppTheme!.bgLayer1,
//                   color: themeData!.colorScheme.primary,
//                   key: _refreshIndicatorKey,
//                   child: ListView(
//                     padding: Spacing.zero,
//                     children: [
//                       Container(
//                         height: MySize.size3,
//                         child: isInProgress
//                             ? LinearProgressIndicator(
//                                 minHeight: MySize.size3,
//                               )
//                             : Container(
//                                 height: MySize.size3,
//                               ),
//                       ),
//                       _buildBody()
//                     ],
//                   ),
//                 )));
//       },
//     );
//   }

//   Widget _buildBody() {
//     if (favorites!.length != 0) {
//       return Container(child: _showProducts(favorites!));
//     } else if (isInProgress) {
//       return Container(
//           child: LoadingScreens.getFavouriteLoadingScreen(
//               context, themeData!, customAppTheme!,
//               itemCount: 5));
//     } else {
//       return Center(
//         child: Text(
//           Translator.translate("you_have_not_favorite_item_yet"),
//           style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
//               color: themeData!.colorScheme.onBackground, fontWeight: 500),
//         ),
//       );
//     }
//   }

//   _showProducts(List<Favorite> favorites) {
//     List<Widget> listWidgets = [];

//     for (int i = 0; i < favorites.length; i++) {
//       listWidgets.add(InkWell(
//         onTap: () async {
//           Product? newProduct = await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => ProductScreen(
//                         productId: favorites[i].product!.id,
//                       )));
//           if (newProduct != null) {
//             setState(() {
//               favorites[i].product = newProduct;
//             });
//           }
//         },
//         child: Container(
//           margin: Spacing.bottom(16),
//           child: _singleProduct(favorites[i].product!),
//         ),
//       ));
//     }

//     return GridView.count(
//       padding: Spacing.fromLTRB(16, 16, 16, 0),
//       shrinkWrap: true,
//       physics: ClampingScrollPhysics(),
//       crossAxisCount: 2,
//       childAspectRatio: findAspectRatio(MediaQuery.of(context).size.width),
//       mainAxisSpacing: 0,
//       crossAxisSpacing: MySize.size16!,
//       children: listWidgets,
//     );
//   }

//   _singleProduct(Product product) {
//     return Stack(
//       children: [
//         Container(
//           padding: Spacing.all(16),
//           margin: Spacing.zero,
//           decoration: BoxDecoration(
//             color: customAppTheme!.bgLayer1,
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             border: Border.all(color: customAppTheme!.bgLayer4),
//             boxShadow: [
//               BoxShadow(
//                 color: customAppTheme!.shadowColor,
//                 blurRadius: 2,
//                 offset: Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(8)),
//                 child: product.imageUrl.length != 0
//                     ? Image.network(
//                         TextUtils.getImageUrl(product.imageUrl)  ,
//                         loadingBuilder: (BuildContext ctx, Widget child,
//                             ImageChunkEvent? loadingProgress) {
//                           if (loadingProgress == null) {
//                             return child;
//                           } else {
//                             return LoadingScreens.getSimpleImageScreen(
//                                 context, themeData, customAppTheme!,
//                                 width: 90, height: 90);
//                           }
//                         },
//                         width: MediaQuery.of(context).size.width * 0.35,
//                         fit: BoxFit.cover,
//                       )
//                     : Image.asset(
//                         Product.getPlaceholderImage(),
//                         width: MediaQuery.of(context).size.width * 0.35,
//                         fit: BoxFit.fill,
//                       ),
//               ),
//               Spacing.height(2),
//               Text(
//                 product.name!,
//                 style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
//                     fontWeight: 600, letterSpacing: 0),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Spacing.height(3),
//               Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Text(
//                       product.imageUrl.length.toString() +
//                           " " +
//                           Translator.translate("options"),
//                       style: AppTheme.getTextStyle(
//                           themeData!.textTheme.bodyText2,
//                           fontWeight: 500),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                           color: themeData!.colorScheme.primary,
//                           borderRadius: BorderRadius.all(Radius.circular(4))),
//                       padding: EdgeInsets.only(
//                           left: 6,
//                           right: 8,
//                           top: 2,
//                           bottom: MySize.getScaledSizeHeight(3.5)),
//                       child: Row(
//                         children: <Widget>[
//                           Icon(
//                             MdiIcons.star,
//                             color: themeData!.colorScheme.onPrimary,
//                             size: 12,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(left: 4),
//                             child: Text(product.rating.toString(),
//                                 style: AppTheme.getTextStyle(
//                                     themeData!.textTheme.caption,
//                                     fontSize: 11,
//                                     color: themeData!.colorScheme.onPrimary,
//                                     fontWeight: 600)),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ]),
//             ],
//           ),
//         ),
//         Positioned(
//           right: 12,
//           top: 12,
//           child: Icon(
//             product.isFavorite ? MdiIcons.heart : MdiIcons.heartOutline,
//             color: product.isFavorite
//                 ? themeData!.colorScheme.primary
//                 : themeData!.colorScheme.onBackground.withAlpha(100),
//             size: 22,
//           ),
//         )
//       ],
//     );
//   }

//   void showMessage({String message = "Something wrong", Duration? duration}) {
//     if (duration == null) {
//       duration = Duration(seconds: 3);
//     }
//     _scaffoldMessengerKey.currentState!.showSnackBar(
//       SnackBar(
//         duration: duration,
//         content: Text(message,
//             style: AppTheme.getTextStyle(themeData!.textTheme.subtitle2,
//                 letterSpacing: 0.4, color: themeData!.colorScheme.onPrimary)),
//         backgroundColor: themeData!.colorScheme.primary,
//         behavior: SnackBarBehavior.fixed,
//       ),
//     );
//   }
// }
