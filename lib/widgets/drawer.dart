/*
// ! Code Created By DZ-TM071 Free Open Source !
import 'dart:math';
import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/controllers/AuthController.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/views/SelectLanguageDialog.dart';
import 'package:EMallApp/views/addresses/AllAddressScreen.dart';
import 'package:EMallApp/views/auth/EditProfileScreen.dart';
import 'package:EMallApp/views/auth/LoginScreen.dart';
import 'package:EMallApp/views/contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';





class DrawerAnimated extends StatefulWidget {
  const DrawerAnimated({Key? key}) : super(key: key);

  @override
  _DrawerAnimatedState createState() => _DrawerAnimatedState();
}

class _DrawerAnimatedState extends State<DrawerAnimated> {
  double value = 0;
  @override
  Widget build(BuildContext context) {
    return Drawer(

      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => EditProfileScreen(),
                ),
              );
            },
            child: UserAccountsDrawerHeader(

              // currentAccountPicture: CircleAvatar(
              //   backgroundImage: NetworkImage(
              //       'https://images.unsplash.com/photo-1485290334039-a3c69043e517?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYyOTU3NDE0MQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=300'),
              // ),
              accountEmail: Text(email!),
              accountName: Text(
                name!,
                style: TextStyle(fontSize: 24.0),
              ),
              decoration: BoxDecoration(
                color: Color(0xff2AD376),
              ),
            ),
          ),
          new Directionality(textDirection: TextDirection.rtl,
            child: ListTile(
              title:  Text("العنوان",style: TextStyle(fontFamily: "boahmed"),),
              trailing:  Icon(Icons.location_on_outlined),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllAddressScreen()),
                );
              },
            ),
          ),
          Divider(),
          new Directionality(textDirection: TextDirection.rtl,
            child: ListTile(
              title:  Text("الاشتراكات",style: TextStyle(fontFamily: "boahmed")),
              trailing:  Icon(Icons.newspaper),
              onTap: ()  {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupscripScreen()),
                );
              },
            ),
          ),
          Divider(),
          // new Directionality(textDirection: TextDirection.rtl,
          //   child: ListTile(
          //     title:  Text("تواصل معنا",style: TextStyle(fontFamily: "boahmed")),
          //     trailing:  Icon(Icons.chat),
          //     onTap: ()  {
          //     Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => Contact()),
          //     );
          //     },
          //   ),
          // ),
          // Divider(),
          new Directionality(textDirection: TextDirection.rtl,
            child: ListTile(
              title:  Text("الشروط و الاحكام",style: TextStyle(fontFamily: "boahmed")),
              trailing:  Icon(Icons.sticky_note_2_sharp),
              onTap: ()  {
                final Uri toLaunch =
                Uri(scheme: 'https', host: 'Mymealz.co', path: 'terms/');
                _launchInWebViewWithoutJavaScript(toLaunch);
              },
            ),
          ),
          // Divider(),
          // new Directionality(textDirection: TextDirection.rtl,
          //   child: ListTile(
          //     title:  Text("سياسه الخصوصيه"),
          //     trailing:  Icon(Icons.local_police_outlined),
          //     onTap: ()  {
          //     Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => Terms()),
          //     );
          //     },
          //   ),
          // ),
          Container(
            margin: Spacing.top(16),
            child: Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:MaterialStateProperty.all<Color>(Color(0xff2AD376)) ,
                    padding: MaterialStateProperty.all(Spacing.xy(24, 12)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ))
                ),
                onPressed: () async {
                  await AuthController.logoutUser();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen(),
                    ),
                  );
                },

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.logoutVariant,
                        size: MySize.size20,
                        color: themeData!.colorScheme.onPrimary),
                    Container(
                      margin: Spacing.left(16),
                      child: Text(Translator.translate("logout").toUpperCase(),
                          style: TextStyle(
                            // themeData!.textTheme.caption,
                            // fontWeight: 600,
                              fontSize: 20,
                              fontFamily: "boahmed",
                              color: themeData!.colorScheme.onPrimary,
                              letterSpacing: 0.3)),
                    ),
                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}
*/
