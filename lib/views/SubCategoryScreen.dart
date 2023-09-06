// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:EMallApp/services/snakbar_service.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';


import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/api/api_util.dart';
import 'package:EMallApp/api/colors.dart';
import 'package:EMallApp/controllers/AddressController.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/controllers/CategoryController.dart';
import 'package:EMallApp/controllers/HomeController.dart';
import 'package:EMallApp/controllers/OrderController.dart';
import 'package:EMallApp/models/Account.dart';
import 'package:EMallApp/models/AdBanner.dart';
import 'package:EMallApp/models/Categories.dart';
import 'package:EMallApp/models/MyResponse.dart';
import 'package:EMallApp/models/UserAddress.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/services/FirestoreServices.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/TextUtils.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:EMallApp/utils/navigator.dart';
import 'package:EMallApp/views/CategoryShopScreen.dart';
import 'package:EMallApp/views/LoadingScreens.dart';
import 'package:EMallApp/views/OrderScreen.dart';
import 'package:EMallApp/views/SelectLanguageDialog.dart';
import 'package:EMallApp/views/addresses/AddAddressScreen.dart';
import 'package:EMallApp/views/addresses/AllAddressScreen.dart';
import 'package:EMallApp/views/auth/EditProfileScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:EMallApp/views/auth/SettingScreen.dart';
import 'package:EMallApp/views/checkout/CouponScreen.dart';
import 'package:EMallApp/views/voucher_screen.dart';
import 'package:EMallApp/views/wallet_screen.dart';
import 'package:EMallApp/widgets/drawer.dart';

class SubCategoryScreen extends StatefulWidget {
  final int? id;
  final Category category ;
  const SubCategoryScreen({
    Key? key,
    this.id,
    required this.category,
  }) : super(key: key);
  @override
  _SubCategoryScreenState createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  //ThemeData
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  final GlobalKey _addressSelectionKey = new GlobalKey();

  Category? curentCategory;

  double findAspectRatio(double width) {
    //Logic for aspect ratio of grid view
    return (width / 2 - 24) / ((width / 2 - 24) + 60);
  }
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Banner Variables
  int _numPages = 3;

  PageController? _pageController;
  int _currentPage = 0;
  Timer? timerAnimation;
  Account? account;

  //Other Variables
  bool isInProgress = false;
  List<Shop>? shops;
  List<UserAddress>? userAddresses;
  List<Category>? categories;
  List<AdBanner>? banners;
  String? name='';
  String? email='';
  String? avatar='';

  int? supcatigo =0 ;
  int? dayse =0 ;
  int? wighit =0 ;
  int? id = null;

  List<SubCategory>? subcategories;

  int selectedAddress = -1;

  late FirestoreServices firestoreServices;



  @override
  void initState() {
    super.initState();
    firestoreServices=FirestoreServices();

   _getSubCategories(widget.id!);
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    if (timerAnimation != null) timerAnimation!.cancel();
    if (_pageController != null) _pageController!.dispose();
  }
  _initData() async {
      
      
    Account cacheAccount = await AuthController.getAccount();
    
    if(cacheAccount.token !=null){
        account = cacheAccount;id= account!.id!;
      name = account!.name!;
      email =account!.email!;
      avatar=account!.avatarUrl;
      _loadAddresses();
      }

      setState(() {
        
      });

    

  }


   getUserWallet(){
    OrderController.getWalletsData();
  }

  _getSubCategories(int ?id) async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<SubCategory>> myResponse =
    await CategoryController.getCategorySubCategories(widget.id!);

    if (myResponse.success) {
      print("secondcategories done12");
      print(myResponse.data);
      subcategories = myResponse.data;


      setState(() {
        
      });
   
      /* if(secondcategories!.isNotEmpty) {
        _getSecondDays(secondcategories!.first.id!);
      }*/

    } else {
      print("secondcategories er");
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }





  _loadAddresses() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<UserAddress>> userAddressResponse =
        await AddressController.getMyAddresses();
    if (userAddressResponse.success) {
      print("adres donne");
      userAddresses = userAddressResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(
          context, userAddressResponse.responseCode);
      showMessage(message: userAddressResponse.errorText);
    }

    if (userAddresses == null || userAddresses?.length == 0) {
         Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddAddressScreen()));
      if (mounted) {
        setState(() {
          isInProgress = false;
        });
      }
    } else {
      if (selectedAddress == -1) {
        selectedAddress = 0;
        for (int i = 0; i < userAddresses!.length; i++) {
          if (userAddresses![i].isDefault) selectedAddress = i;
        }
      }
    
      _loadHomeData();
    }
  }

  _loadHomeData() async {
    if (selectedAddress == -1) return;
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<Map<String, dynamic>> myResponse =
        await HomeController.getHomeData(userAddresses![selectedAddress].id);
    if (myResponse.success) {
      print("res donne");
      //shops = myResponse.data![HomeController.shops];
      banners = myResponse.data![HomeController.banners];
     // categories = myResponse.data![HomeController.categories];
    } else {
      print("res failed");
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
    _loadHomeData();
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
                  drawer: Drawer(
                      width: 250,
                      backgroundColor: primaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                account==null ? Container():     GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => SettingScreen(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(avatar!),
                                        ),
                                        Text(name!,style: whitebasic,),
                                      ],
                                    ),
                                  ),


                                    account==null ? Container(): Divider(height: 23,thickness: 1.2,),
                                    account==null ? Container(): SizedBox(height: 20,),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Icon(Icons.home_filled,color: backgroundColor,),
                                        SizedBox(width: 10,),
                                        Text(Translator.translate("orders"),style: whitebasic,),
                                      ],
                                    ),
                                    onTap: () {
                                      pushScreen(context, OrderScreen());

                                    },
                                  ),
                                  SizedBox(height: 10,),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Icon(Icons.wallet,color: backgroundColor,),
                                        SizedBox(width: 10,),
                                        Text(Translator.translate("wallet"),style: whitebasic,),
                                      ],
                                    ),
                                    onTap: () {
                                      pushScreen(context, WalletScreen());

                                    },
                                  ),
                                  SizedBox(height: 10,),
                                  account==null ? Container():   ListTile(
                                    title: Row(
                                      children: [
                                        Icon(Icons.list_alt_outlined,color: backgroundColor,),
                                        SizedBox(width: 10,),
                                        Text(Translator.translate("Vouchers"),style: whitebasic,),
                                      ],
                                    ),
                                    onTap: () {
                                      pushScreen(context, VoucherScreen());

                                    },
                                  ),
                                  SizedBox(height: 10,),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Icon(Icons.language,color: backgroundColor,),
                                        SizedBox(width: 10,),
                                        Text(Translator.translate("select_language"),style: whitebasic,),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) => SelectLanguageDialog());

                                    },
                                  ),
                                  SizedBox(height: 10,),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Icon(Icons.share,color: backgroundColor,),
                                        SizedBox(width: 10,),
                                        Text(Translator.translate("share"),style: whitebasic,),
                                      ],
                                    ),
                                    onTap: () {
                                      //Navigator.pop(context);
                                    },
                                  ),

                                ],
                              ),
                            ),
                          ),
                             account==null ? Container():     ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.delete,color: Colors.red,),
                                SizedBox(width: 10,),
                                Text(Translator.translate("delete_account"),style: whitebasic,),
                              ],
                            ),
                            onTap: () async {
                                 
                         //     showMessage(message: Translator.translate("account_deleted_success"));
                             // return;
                             AuthController.deleteAccount().then((value){
                              if(value==true){
                               showDialog(
                                          context: context,
                                          builder: (BuildContext context) => Scaffold(
                                            body: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(Translator.translate("account_deleted_success"),style: TextStyle(fontSize: 20,color: Colors.black),),
                                                    SizedBox(height: 10,),
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
                   Navigator.pop(context);
                  },
                  child: Text("Ok",
                      style: AppTheme.getTextStyle(
                          themeData!.textTheme.bodyText2,
                          fontWeight: 600,
                          color: themeData!.colorScheme.onPrimary,
                          letterSpacing: 0.5))),
            )
                                                  ],
                                                )),),
                                          )).then((value) {
                                Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => LoginScreen(),
                                ),
                              );
                                          });
                             //   showMessage(message: Translator.translate("account_deleted_success"));
                                log("Success");
                              //   Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (BuildContext context) => LoginScreen(),
                              //   ),
                              // );
                              }
                             });
                              
                            },
                          ),
                             
                           account==null ? Container():   Divider(height: 23,thickness: 1.2,),
                           account==null ? Container():   ListTile(
                            title: Row(
                              children: [
                                Icon(Icons.logout,color: backgroundColor,),
                                SizedBox(width: 10,),
                                Text(Translator.translate("logout"),style: whitebasic,),
                              ],
                            ),
                            onTap: () async {
                              await AuthController.logoutUser();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      )),

                appBar: AppBar(
                  elevation: 0,
                  actions:[
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0,bottom: 10),
                      child: InkWell(
                          onTap: () {
                            pushScreen(context, OrderScreen());
                          },
                          child: Icon(Icons.shopping_bag)),
                    ) ,
                  ]
                  

                ),


                  key: _scaffoldKey,
                  backgroundColor: customAppTheme.bgLayer1,
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
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
                        Expanded(
                          child: _buildBody(),
                        )
                      ],
                    ),
                  )),
            ));
      },
    );
  }

  _buildBody() {
    if (!isInProgress &&
        (userAddresses == null || userAddresses?.length == 0) && account !=null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddAddressScreen()));
          },
          child: Text("Create an Address"),
        ),
      );
    }

    if ( banners != null || account ==null) {
      return Stack(
        children: [
          Container(
              child: ListView(
            children: [
              SizedBox(height: 10,),
              /*_welcome(),
              _addressWidget(),*/
               account==null ? Container():   Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(Translator.translate("delivery_address")),
                ),
           account==null ? Container():   _addressWidget(),
            //  _bannersWidget(),
                Categories(),

             // _categoriesWidget(categories!),
             //_shopsWidget(shops!),
            ],
          )),
                    Positioned(
            bottom: 0,
            child: Container(width: MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*0.08 ,color: Color(0xff15cb95),))
        ],
      );
    } else if (isInProgress) {
      return Container();
    } else {
      return Container();
    }
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


 



  _addressWidget() {
    return GestureDetector(
      onTap: () {
        dynamic state = _addressSelectionKey.currentState;
        state.showButtonMenu();
      },
      child: Container(
        padding: Spacing.x(8),
        margin: Spacing.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: customAppTheme.bgLayer4, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Row(
              children: <Widget>[

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
                              themeData.textTheme.bodyText2,
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
                              fontSize: 15,
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
                    MdiIcons.chevronDown,
                    color: themeData.colorScheme.onBackground,
                    size: 20,
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
                      _refresh();
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
                                    themeData.textTheme.bodyText2,
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
                                      themeData.textTheme.caption,
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
          ],
        ),
      ),
    );
  }

  _bannersWidget() {
    if (banners!.length == 0) return Container();

    if (_pageController == null) {
      _pageController = PageController(initialPage: 0);
      _numPages = banners!.length;
      int? x= 0;
      timerAnimation = Timer.periodic(Duration(seconds: 4), (Timer timer) {
        if (_currentPage < _numPages - 1 && x ==0) {
          _currentPage++;
        } else if (_currentPage > 0 ) {
          _currentPage--;
          x=_currentPage;
        }

        if (_pageController!.hasClients) {
          _pageController!.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      });
    }

    List<Widget> list = [];
    for (AdBanner banner in banners!) {
      list.add(
        Padding(
          padding: Spacing.all(15.0),
          child: Image.network(
            TextUtils.getImageUrl(banner.url),
            fit: BoxFit.cover,
            height: 40,
          ),
        ),
      );
    }

    return Container(
      height: 166,
      child: PageView(
        pageSnapping: true,
        physics: ClampingScrollPhysics(),
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: list,
      ),
    );
  }

  _welcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [


            Padding(
              padding: const EdgeInsets.only(left:8.0,top: 20),
              child: Text(Translator.translate("Welcome Honey, "),
                style:
                AppTheme.getTextStyle(
                    themeData.textTheme.bodyText2,
                    color: themeData.colorScheme.onBackground,
                    fontWeight: 600,
                    fontSize: 20),

              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget Categories(){
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
                children: [


                //  _buildScrollMain(categories!),
                  subcategories==null? Container(): buildCategorySubCategory(),

                ]
            ),
        )
    );
  }




  Widget buildCategorySubCategory(){
    if (subcategories != null) {
      if (subcategories!.length == 0) {
        return Center(
          child: Text(
              Translator.translate("there_is_no_subcategories_with_this_category")),
        );
      }
      return _showSubcategories(subcategories!);
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

  _buildScrollMain(List<Category> category){

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 200,
        width: double.infinity,

        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category!.length,
            itemBuilder: (BuildContext context,int index){
              return GestureDetector(
                  onTap: (){

                    print(category![index].id.toString());
                    print('*************');
                    print(category![index].title);
                    setState(() {
                      // _getMainCategories();

                      supcatigo = category![index].id;
                      _getSubCategories(category![index].id,);
                      _refresh();
                    });
                  },
                  child:category![index].id == supcatigo?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 150,

                      decoration: BoxDecoration(
                          border: Border.all(
                            color: customAppTheme!.bgLayer4,

                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: customAppTheme!.colorSuccess,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      // color: Colors.black,,
                      child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(MySize.getScaledSizeWidth(24))),
                              child: Image.network(
                               TextUtils.getImageUrl(category[index].imageUrl),
                                    width: 194.41,
                                   height: 140,

                              ),
                            ),
                          ),
                          Text(category![index].title,style: TextStyle(color: Colors.white,fontSize: 15),),
                        ],
                      ),
                    ),
                  ): Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                       boxShadow: [
                            BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                            ),
                        ],
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      // color: Colors.black,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(MySize.getScaledSizeWidth(24))),
                              child: Image.network(
                              TextUtils.getImageUrl(category[index].imageUrl),
                                   width: 194.41,
                                   height: 140,

                              ),
                            ),
                          ),
                          Text(category![index].title,style: TextStyle(color: Colors.black,fontSize: 15),),
                        ],
                      ),
                    ),
                  )
              );
            }
        ),
      ),
    );

  }



  _showSubcategories(List<SubCategory> seconds) {
    List<Widget> listWidgets = [];

    for (int i = 0; i < seconds.length; i++) {
      listWidgets.add(Container(
        padding: Spacing.all(10),
        margin: Spacing.bottom(16),
        child: _singleSecond(seconds[i]),
      ));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: findAspectRatio(MediaQuery.of(context).size.height/2),
      mainAxisSpacing: 0,
      crossAxisSpacing: 0.5,
      children: listWidgets,
    );
  }

  _singleSecond(SubCategory second, ) {

    return GestureDetector(
      onTap: (){
        print("*****");
        print(widget.category.type);
        print(widget.category.title);
          if(account==null){
             Navigator.push(context,
            MaterialPageRoute(builder: (context) => LoginScreen(
              
            )));
          }else{
  Navigator.push(context,
            MaterialPageRoute(builder: (context) => CategoryShopScreen(
              category: widget.category,
              subcategories:second,
            )));
          }
      

      },
      child:dayse == second.id? Container(

        padding: Spacing.all(10),
        margin: Spacing.zero,
        decoration: BoxDecoration(
          color: customAppTheme!.colorSuccess,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Spacing.height(2),
            Container(
               child: ClipRRect(
                 borderRadius: BorderRadius.all(
                     Radius.circular(MySize.getScaledSizeWidth(24))),
                 child: Image.network(
                   TextUtils.getImageUrl(second.image_url),
                   width: 194.41,
                   height: 140,

                 ),
               ),
             ),
             Text(
               second.title!,
               style: TextStyle(color: Colors.white,
                   fontWeight:FontWeight.bold , letterSpacing: 0),
               overflow: TextOverflow.ellipsis,
             ),

          ],
        ),
      ): Container(
      width: 200,
        padding: Spacing.all(10),
        margin: Spacing.zero,
        decoration: BoxDecoration(
          color: customAppTheme!.bgLayer1,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: customAppTheme.colorSuccess,),
          boxShadow: [
            BoxShadow(
              color: customAppTheme!.shadowColor,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(

          children: <Widget>[

            Spacing.height(2),
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(
                    Radius.circular(MySize.getScaledSizeWidth(24))),
                child: Image.network(
                  TextUtils.getImageUrl(second.image_url),
                  width: 194.41,
                  height:140,

                ),
              ),
            ),
            Text(
              second.title!,
              style: AppTheme.getTextStyle(themeData!.textTheme.bodyText2,
                  fontSize: 15,
                  color: customAppTheme.colorSuccess,
                  fontWeight: 600, letterSpacing: 0),
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),
    );
  }





}
