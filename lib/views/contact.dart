import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/models/Account.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/services/general_services.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:EMallApp/views/OrderScreen.dart';
import 'package:EMallApp/views/SelectLanguageDialog.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:EMallApp/views/auth/SettingScreen.dart';
import 'package:EMallApp/views/voucher_screen.dart';
import 'package:EMallApp/views/wallet_screen.dart';
import 'package:flutter/material.dart';

import '../api/colors.dart';
import '../utils/navigator.dart';

class Contact extends StatefulWidget {
  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
    String? name='';
  String? email='';
  String? avatar='';
    Account? account;

  _initData() async {
    Account cacheAccount = await AuthController.getAccount();
    setState(() {
      account = cacheAccount;
      name = account!.name!;
      email =account!.email!;
      avatar=account!.avatarUrl;
    });
  }

  @override
  void initState() {
        _initData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
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
                                  GestureDetector(
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


                                  Divider(height: 23,thickness: 1.2,),
                                  SizedBox(height: 20,),
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
                                  ListTile(
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
                                        Icon(Icons.call,color: backgroundColor,),
                                        SizedBox(width: 10,),
                                        Text(Translator.translate("contact_us"),style: whitebasic,),
                                      ],
                                    ),
                                    onTap: () {
                                        pushScreen(context, Contact());
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

                              
                          Divider(height: 23,thickness: 1.2,),
                          ListTile(
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
          body: Stack(
            children: [
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      children: [
                         Column(
                           children: [
                             InkWell(
                              onTap: () {
                                callNumber("+962787720347");
                              },
                               child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                 Icon(  Icons.call ,color: Colors.greenAccent,size:35,),
                                 const SizedBox(width: 10),
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                   Translator.translate("mobile_number"),            
                                       textAlign: TextAlign.center,
                                         style: TextStyle(
                                             fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                             color: Colors.black),
                                       ),
                                      const SizedBox(height: 10),
                                        Text(
                                    "+962 78772 0347",            
                                       textAlign: TextAlign.center,
                                         style: TextStyle(
                                             fontSize: 13,
                                         
                                             color: Colors.black),
                                       ),
                                
                                   ],
                                 ),
                                ],),
                             ),
                              Divider(),
                               InkWell(
                                onTap: () {
                                   openUrl("Info@wasiljo.com");
                                },
                                 child: Row(
                                                             crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                 Icon(  Icons.email ,color: Colors.greenAccent,size:35,),
                                 const SizedBox(width: 10),
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                   Translator.translate("email"),            
                                       textAlign: TextAlign.center,
                                         style: TextStyle(
                                             fontSize: 16,
                                         fontWeight: FontWeight.bold,
                                             color: Colors.black),
                                       ),
                                      const SizedBox(height: 10),
                                        Text(
                                    "Info@wasiljo.com",            
                                       textAlign: TextAlign.center,
                                         style: TextStyle(
                                             fontSize: 13,
                                         
                                             color: Colors.black),
                                       ),
                                                             
                                   ],
                                 ),
                                                             ],),
                               ),
                           ],
                         ),
                      ]
                  )
              ),
                        Positioned(
            bottom: 0,
            child: Container(width: MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*0.08 ,color: Color(0xff15cb95),))
            ],
          )
      ),
    );
  }
}
