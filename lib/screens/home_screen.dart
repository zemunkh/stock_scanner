import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/main_drawer.dart';
import '../block/bottom_block.dart';
import '../widgets/stock_check.dart';
import '../widgets/dispatch_note.dart';

import '../styles/theme.dart' as Style;


class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BottomNavBarBlock _bottomNavBarBlock;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    initNavBar();
  }

  initNavBar() async {
    _bottomNavBarBlock = BottomNavBarBlock();
    bool isStockPage = await _getNavBarItem();
    if(isStockPage) {
      print('Stock is enabled');
      _bottomNavBarBlock.pickItem(0);
    } else {
      _bottomNavBarBlock.pickItem(1); 
      print('Stock is disabled');
    }
  }

  @override
  void dispose() {
    _bottomNavBarBlock.close();
    super.dispose();
  }

  Future<bool> _backButtonPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit the Stock App?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () => SystemNavigator.pop(),
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        backgroundColor: Style.Colors.background,
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: AppBar(
            elevation: 2.0,
            backgroundColor: Colors.redAccent,
            leading: IconButton(
              icon: Icon(
                EvaIcons.menu2Outline,
              ),
              color: Colors.white,
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            title: new Text(
              'Mugs Stock Control',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  EvaIcons.infoOutline,
                ),
                color: Colors.white,
                onPressed: () {},
              )
            ],
          ),
        ),
        drawer: MainDrawer(),
        body: StreamBuilder<NavBarItem>(
          stream: _bottomNavBarBlock.itemStream,
          initialData: _bottomNavBarBlock.defaultItem,
          builder: (BuildContext context, AsyncSnapshot<NavBarItem> snapshot) {
            switch (snapshot.data) {
              case NavBarItem.STOCKIN:
                return StockIn();
                break;
              case NavBarItem.DISPATCHNOTE:
                return DispatchNote();
                break;
              default:
                return null;
            }
          },
        ),
      ),
    );
  }
}


_getNavBarItem() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'main_navbar_stock';
  bool val = prefs.getBool(key);
  print('NavBar Stock is enabled: $val');
  return val;
}
