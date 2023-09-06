import 'package:EMallApp/AppTheme.dart';
import 'package:EMallApp/AppThemeNotifier.dart';
import 'package:EMallApp/services/AppLocalizations.dart';
import 'package:EMallApp/utils/SizeConfig.dart';
import 'package:EMallApp/utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({Key? key}) : super(key: key);

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> with SingleTickerProviderStateMixin{
  //ThemeData
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // Dispose TabController when not needed to prevent memory leaks
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
        builder: (BuildContext context, AppThemeNotifier value, Widget? child){
          int themeType = value.themeMode();
          themeData = AppTheme.getThemeFromThemeMode(themeType);
          customAppTheme = AppTheme.getCustomAppTheme(themeType);
          return DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                elevation: 2,
                title: Center(child: Text(Translator.translate("Vouchers"),style: boldSecondry,)),
               
                ),

            body: Column(
                children: [
                  SizedBox(height: 30,),
                  Container(
                    padding: Spacing.all(10),
                    margin: Spacing.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: customAppTheme.bgLayer4, width: 1),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/images/copon.png"),
                        Column(
                          children: [
                            Text(Translator.translate("get_code"),style: boldSecondry,),
                            Text(Translator.translate("add_code"),style: basicSecondry,),
                          ],
                        )
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Active'),
                      Tab(text: 'Used'),
                      Tab(text: 'Expired'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Active Vouchers
                        Center(child: Text('Active Vouchers')),
                        // Tab 2: Used Vouchers
                        Center(child: Text('Used Vouchers')),
                        // Tab 3: Expired Vouchers
                        Center(child: Text('Expired Vouchers')),
                      ],
                    ),
                  ),

              ],
            ),



            ),
          );
        },

      );

  }
}
