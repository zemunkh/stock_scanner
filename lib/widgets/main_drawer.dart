import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:retail_scanner/screens/home_screen.dart';
import 'package:retail_scanner/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/printer_screen.dart';
import '../screens/dispatch_saved_screen.dart';
import '../screens/dispatch_draft_screen.dart';
import '../screens/stock_saved_screen.dart';

class MainDrawer extends StatelessWidget {

  Widget buildListTile(String title, IconData icon, Function tabHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tabHandler,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
              height: 80,
              width: double.infinity,
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomLeft,
              color: Theme.of(context).accentColor,
              child: Text(
                'Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 20,),
            buildListTile(
              'Stock Check', 
              EvaIcons.checkmarkCircleOutline,
              () {
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                _setNavbarItem(true);
              }
            ),
            buildListTile(
              'Dispatch Note', 
              EvaIcons.carOutline,
              () {
                Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                _setNavbarItem(false);
              }
            ),

            new Divider(height: 15.0,color: Colors.black87,),
            
            SizedBox(height:  20),
            buildListTile(
              'Stock Check Saved', 
              EvaIcons.checkmarkCircle,
              () {
                Navigator.of(context).pushReplacementNamed(StockSavedScreen.routeName);
              }
            ),
            buildListTile(
              'Dispatch Saved', 
              EvaIcons.carOutline,
              () {
                Navigator.of(context).pushReplacementNamed(DispatchSavedScreen.routeName);
              }
            ),          
            buildListTile(
              'Dispatch Drafts', 
              EvaIcons.clock,
              () {
                Navigator.of(context).pushReplacementNamed(DispatchDraftScreen.routeName);
              }
            ),

            buildListTile(
              'Printer', 
              EvaIcons.printer,
              () {
                Navigator.of(context).pushReplacementNamed(PrinterScreen.routeName);
              }
            ),
            buildListTile(
              'Settings', 
              EvaIcons.settings2Outline,
              () {
                Navigator.of(context).pushReplacementNamed(SettingScreen.routeName);
              }
            ),
          ],
        ),
      ),
    );
  }
}

_setNavbarItem(bool val) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'main_navbar_stock';
  prefs.setBool(key, val);
  print('Main navbar Stock: $val');
}