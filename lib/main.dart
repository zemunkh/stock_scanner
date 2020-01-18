import 'package:flutter/material.dart';
import 'package:retail_scanner/screens/activation_screen.dart';
import 'package:retail_scanner/screens/dispatch_draft_edit_screen.dart';
import 'package:retail_scanner/screens/printer_screen.dart';
import 'package:retail_scanner/screens/dispatch_saved_screen.dart';
import 'package:retail_scanner/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/dispatch_draft_screen.dart';
import './screens/stock_saved_screen.dart';
import './screens/home_screen.dart';

bool activated = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    activated = await _read();
     _setNavbarItem(true);
    runApp(MyApp());
  } catch(error) {
    print('Activation Status error: $error');
  }
}

class MyApp extends StatelessWidget {
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mugs Stock Control',
      theme: ThemeData(
        accentColor: Colors.amber,
        primarySwatch: Colors.blue,
        textTheme: ThemeData.light().textTheme.copyWith(
          title: TextStyle(
            fontFamily: 'HelveticaNeue',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          button: TextStyle(
            color: Colors.white,
          ),
        ),
        fontFamily: 'HelveticaNeue',
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
            title: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // home: HomeScreen(),
      routes: {
        '/': (ctx) => activated ? HomeScreen() : ActivationScreen(),
        '/main': (ctx) => HomeScreen(),
        DispatchDraftScreen.routeName: (ctx) => DispatchDraftScreen(),
        StockSavedScreen.routeName: (ctx) => StockSavedScreen(),
        DispatchSavedScreen.routeName: (ctx) => DispatchSavedScreen(),
        PrinterScreen.routeName: (ctx) => PrinterScreen(),
        SettingScreen.routeName: (ctx) => SettingScreen(),
        DispatchDraftEditScreen.routeName: (ctx) => DispatchDraftEditScreen(), 
      },
      onGenerateRoute: (settings) {
        print(settings.arguments);
        return MaterialPageRoute(
          builder: (ctx) => HomeScreen(),
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (ctx) => HomeScreen(),
        );
      },
    );
  }

}

_read() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'my_activation_status';
  final status = prefs.getBool(key) ?? false;
  print('Activation Status: $status');
  // activated = status;
  return status;
}

_setNavbarItem(bool val) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'main_navbar_stock';
  prefs.setBool(key, val);
  print('Main navbar Stock: $val');
}