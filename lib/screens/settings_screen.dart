import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retail_scanner/helper/file_manager.dart';
import '../widgets/main_drawer.dart';


class SettingScreen extends StatefulWidget {
  static const routeName = '/settings';
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _deviceController = new TextEditingController();
  final _usernameController = new TextEditingController();
  final _companyController = new TextEditingController();
  final _remark1Controller = new TextEditingController();
  final _remark2Controller = new TextEditingController();
  
  FocusNode _deviceNode = new FocusNode();
  FocusNode _usernameNode = new FocusNode();
  FocusNode _companyNode = new FocusNode();
  FocusNode _remark1Node = new FocusNode();
  FocusNode _remark2Node = new FocusNode();

  List<String> _days = ['Not Selected', '3', '5', '7', '14', '21', '30'];
  bool lockEn = true;
  bool isDispatchNoteDefault = false;
  String dropdownValue = 'Not Selected';

  Future<Null> _focusNode(BuildContext context, FocusNode node) async {
    FocusScope.of(context).requestFocus(node);
  }

  Future<Null> _clearTextController(BuildContext context, TextEditingController _controller, FocusNode node) async {
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _controller.clear();
      });
      FocusScope.of(context).requestFocus(node);
    });
  }

  Future<Null> setInitialValue() async {
    _usernameController.text = await FileManager.readProfile('user_name');
    _deviceController.text = await FileManager.readProfile('device_name');
    _companyController.text = await FileManager.readProfile('company_name');
    _remark1Controller.text = await FileManager.readProfile('remark1');
    _remark2Controller.text = await FileManager.readProfile('remark2');
    final value = await FileManager.readProfile('expiry_day');
    setState(() {
      if(value != null) {
        dropdownValue = value;
      }
    });

  }

  @override
  void dispose() {
    super.dispose();
    _deviceController.dispose();
    _usernameController.dispose();
  }

  @override
  void initState() {
    super.initState();
    setInitialValue();
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

    Widget _dayMenu(BuildContext context, String header) {
      return Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              '$header',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(EvaIcons.arrowDownOutline),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.deepPurple,
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                    // Add some functions to handle change.
                  },
                  items: _days.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _mainInput(String header, TextEditingController _mainController, FocusNode _mainNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              '$header:',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 20, 
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          Expanded(
            flex: 6,
            child: Stack(
              alignment: Alignment(1.0, 1.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 16, 
                        color: Color(0xFF004B83),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: header,
                        hintStyle: TextStyle(
                          color: Color(0xFF004B83), 
                          fontWeight: FontWeight.w200,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        errorStyle: TextStyle(
                          color: Colors.yellowAccent,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(EvaIcons.close, 
                            color: Colors.blueAccent, 
                            size: 32,
                          ),
                          onPressed: () {
                            _clearTextController(context, _mainController, _mainNode);
                          },
                        ),
                      ),
                      keyboardType: header == 'Expiry Days' ? 
                          TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                      autofocus: false,
                      autocorrect: false,
                      controller: _mainController,
                      focusNode: _mainNode,
                      onTap: () {
                        _focusNode(context, _mainNode);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }


    Widget _saveButton(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: () {
            print('You pressed Save!');
            String dname = _deviceController.text;
            String uname = _usernameController.text;
            String company = _companyController.text;
            String remark1 = _remark1Controller.text;
            String remark2 = _remark2Controller.text;
            if(dname != '' && uname != '' && company != '' && remark1 != '' && remark2 != '' && dropdownValue != '') {
              FileManager.saveProfile('device_name', dname);
              FileManager.saveProfile('user_name',uname);
              FileManager.saveProfile('company_name',company);
              FileManager.saveProfile('remark1',remark1);
              FileManager.saveProfile('remark2',remark2);
              FileManager.saveProfile('expiry_day', dropdownValue);
              print('Saving now!');
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: new Text("User data is saved successfully!", textAlign: TextAlign.center,),
                duration: const Duration(milliseconds: 2000)
              ));
            }
            else {
              print('Dismissing it now!');
              // Input values are empty
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: new Text("Can't be saved!", textAlign: TextAlign.center,),
                duration: const Duration(milliseconds: 2000)
              ));
            }
            // save operation by shared preference
          },
          child: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          shape: StadiumBorder(),
          color: Colors.teal[400],
          splashColor: Colors.blue[100],
          height: 50,
          minWidth: 200,
          elevation: 2,
        )
      );
    }  
    
    
    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Settings'),
        ),
        drawer: MainDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                
                _mainInput('Device Name',_deviceController, _deviceNode),
                _mainInput('Username',_usernameController, _usernameNode),
                _mainInput('Company',_companyController, _companyNode),
                _mainInput('Remark 1',_remark1Controller, _remark1Node),
                _mainInput('Remark 2',_remark2Controller, _remark2Node),
                _dayMenu(context, 'Expiry Day:'),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _saveButton(context),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    
  }
}
