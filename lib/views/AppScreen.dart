import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/views/HomeScreen.dart';
import 'package:EMallApp/views/SearchScreen.dart';
import 'package:EMallApp/views/auth/SettingScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AppScreen extends StatefulWidget {
  final int selectedPage;

  const AppScreen({Key? key, this.selectedPage = 0}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {


    super.initState();
  }

  dispose() {
    super.dispose();
   
  }

  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeMode = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeMode);
        customAppTheme = AppTheme.getCustomAppTheme(themeMode);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
          home: Scaffold(
            backgroundColor: customAppTheme.bgLayer1,
            // bottomNavigationBar: BottomAppBar(
            //     elevation: 0,
            //     shape: CircularNotchedRectangle(),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: customAppTheme.bgLayer1,
            //         boxShadow: [
            //           BoxShadow(
            //             color: themeData.cardTheme.shadowColor!.withAlpha(40),
            //             blurRadius: 3,
            //             offset: Offset(0, -3),
            //           ),
            //         ],
            //       ),
            //       padding: Spacing.only(top: 12, bottom: 12),
            //       child: TabBar(
            //         controller: _tabController,
            //         indicator: BoxDecoration(),
            //         indicatorSize: TabBarIndicatorSize.tab,
            //         indicatorColor: themeData.colorScheme.primary,
            //         tabs: <Widget>[
            //           Container(
            //             child: (_currentIndex == 0)
            //                 ? Column(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: <Widget>[
            //                       Icon(
            //                         MdiIcons.store,
            //                         color: themeData.colorScheme.primary,
            //                       ),
            //                       Container(
            //                         margin: Spacing.top(4),
            //                         decoration: BoxDecoration(
            //                             color: themeData.primaryColor,
            //                             borderRadius: new BorderRadius.all(
            //                                 Radius.circular(2.5))),
            //                         height: 5,
            //                         width: 5,
            //                       )
            //                     ],
            //                   )
            //                 : Icon(
            //                     MdiIcons.storeOutline,
            //                     color: themeData.colorScheme.onBackground,
            //                   ),
            //           ),
            //           Container(
            //               margin: Spacing.right(24),
            //               child: (_currentIndex == 1)
            //                   ? Column(
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: <Widget>[
            //                         Icon(
            //                           MdiIcons.magnify,
            //                           color: themeData.colorScheme.primary,
            //                         ),
            //                         Container(
            //                           margin: Spacing.top(4),
            //                           decoration: BoxDecoration(
            //                               color: themeData.primaryColor,
            //                               borderRadius: new BorderRadius.all(
            //                                   Radius.circular(2.5))),
            //                           height: 5,
            //                           width: 5,
            //                         )
            //                       ],
            //                     )
            //                   : Icon(
            //                       MdiIcons.magnify,
            //                       color: themeData.colorScheme.onBackground,
            //                     )),
            //         /*  Container(
            //               margin: Spacing.left(24),
            //               child: (_currentIndex == 1)
            //                   ? Column(
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: <Widget>[
            //                         Icon(
            //                           MdiIcons.heart,
            //                           color: themeData.colorScheme.primary,
            //                         ),
            //                         Container(
            //                           margin: Spacing.top(4),
            //                           decoration: BoxDecoration(
            //                               color: themeData.primaryColor,
            //                               borderRadius: new BorderRadius.all(
            //                                   Radius.circular(2.5))),
            //                           height: 5,
            //                           width: 5,
            //                         )
            //                       ],
            //                     )
            //                   : Icon(
            //                       MdiIcons.heartOutline,
            //                       color: themeData.colorScheme.onBackground,
            //                     )),*/
            //           Container(
            //               child: (_currentIndex == 2)
            //                   ? Column(
            //                       mainAxisSize: MainAxisSize.min,
            //                       children: <Widget>[
            //                         Icon(
            //                           MdiIcons.account,
            //                           color: themeData.colorScheme.primary,
            //                         ),
            //                         Container(
            //                           margin: Spacing.top(4),
            //                           decoration: BoxDecoration(
            //                               color: themeData.primaryColor,
            //                               borderRadius: new BorderRadius.all(
            //                                   Radius.circular(2.5))),
            //                           height: 5,
            //                           width: 5,
            //                         )
            //                       ],
            //                     )
            //                   : Icon(
            //                       MdiIcons.accountOutline,
            //                       color: themeData.colorScheme.onBackground,
            //                     )),
            //         ],
            //       ),
            //     )),
          /*  floatingActionButton: FloatingActionButton(

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return CartScreen();
                  }),
                );

              },
              child: Icon(
                MdiIcons.cartOutline,
                color: themeData.colorScheme.primary,
              ),
              backgroundColor: customAppTheme.bgLayer1,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,*/
            body:         HomeScreen(),
          ),
        );
      },
    );
  }

}
