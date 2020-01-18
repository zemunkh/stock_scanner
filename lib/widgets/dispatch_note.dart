import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:retail_scanner/helper/file_manager.dart';
import 'package:retail_scanner/screens/home_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../widgets/print_note.dart';

class DispatchNote extends StatefulWidget {
  @override
  DispatchNoteState createState() => DispatchNoteState();
}

class DispatchNoteState extends State<DispatchNote> {
  List<TextEditingController> _masterControllers = new List();
  List<TextEditingController> _productControllers = new List();

  List<FocusNode> _masterFocusNodes = new List();
  List<FocusNode> _productFocusNodes = new List();

  final _dispatchNoController = TextEditingController();
  final _numberOfScanController = TextEditingController();

  final _dispatchNode = FocusNode();
  final _numberNode = FocusNode();

  bool _isButtonDisabled = true;
  bool _isFormEnabled = true;
  // final _mainFormKey = GlobalKey<FormState>();
  // final _scannerFormKey = GlobalKey<FormFieldState>();

  // Widget _form;
  List<bool> keyEnableList = [];
  List<bool> matchList = [];
  List<int> counterList = [];

  PrintNote printNote;

  Future<Null> _checkInputs() async {
    bool isEmpty = false;
    for (int i = 0; i < _masterControllers.length; i++) {
      if ((counterList[i] > 0 &&
          _dispatchNoController.text != null &&
          _numberOfScanController.text != null) ||
          keyEnableList[i] == false ) {
        isEmpty = isEmpty || false;
      } else {
        isEmpty = isEmpty || true;
      }
    }
    setState(() {
      _isButtonDisabled = isEmpty;
    });
    return null;
  }

  Future<Null> _compareData(String prodVal, int index) async {
    final masterCode = _masterControllers[index].text;
    print('Comparison: $masterCode : $prodVal');

    setState(() {
      if (masterCode == prodVal) {
        matchList[index] = true;
        counterList[index]++;
      } else {
        matchList[index] = false;
      }
    });
    _checkInputs();
  }

  String buffer = '';
  String trueVal = '';

  Future<Null> _dipatchNoListener() async {
    print('Current text: ${_dispatchNoController.text}');
    buffer = _dispatchNoController.text;
    if (buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;
      _dispatchNode.unfocus();
      await Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _dispatchNoController.text = trueVal;
        });
        FocusScope.of(context).requestFocus(_numberNode);
      });
    }
  }

  Future<Null> _numberScanListener() async {
    buffer = _numberOfScanController.text;
    if (buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;

      await Future.delayed(const Duration(milliseconds: 1000), () {
        _numberOfScanController.text = trueVal;
      }).then((value) {
        // set the number of inputs will be built in the screen
        if (trueVal != '') {
          if (int.parse(trueVal) < 51) {
            print('Controller Length: ${_masterControllers.length}');

            if (_masterControllers.length < int.parse(trueVal)) {
              int diff = int.parse(trueVal) - _masterControllers.length;
              setState(() {
                for (int i = 0; i < diff; i++) {
                  print('adding:');
                  _masterControllers.add(new TextEditingController());
                  _productControllers.add(new TextEditingController());

                  _masterFocusNodes.add(new FocusNode());
                  _productFocusNodes.add(new FocusNode());
                }
              });
            } else {
              print('Wrong request!');
              // _onBasicAlertPressed(BuildContext context);
            }
          } else {
            print('Too many :(');

            Scaffold.of(context).showSnackBar(SnackBar(
                content: new Text(
                  "Too many. Total Items has to be under 50!",
                  textAlign: TextAlign.center,
                ),
                duration: const Duration(milliseconds: 2000)));
          }
        }

        _numberNode.unfocus();
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    }
  }

  Future<Null> _focusNode(BuildContext context, FocusNode node) async {
    FocusScope.of(context).requestFocus(node);
  }

  Future<Null> _clearTextController(BuildContext context,
      TextEditingController _controller, FocusNode node) async {
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _controller.clear();
      });
      FocusScope.of(context).requestFocus(node);
    });
  }

  _controllerEventListener(
      int index, TextEditingController _controller, String _typeController) {
    int length = _masterControllers.length;

    print('Length of the controllers: $length, index: $index');
    if (_typeController == 'master') {
      buffer = _masterControllers[index].text;
    } else if (_typeController == 'product') {
      buffer = _productControllers[index].text;
    }

    if (buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;
      if (_typeController == 'master') {
        print('I am master!');
        _masterFocusNodes[index].unfocus();
      } else if (_typeController == 'product') {
        print('I am product!');
        Future.delayed(const Duration(milliseconds: 1000), () {
          _productControllers[index].text = trueVal;
        }).then((value) {
          _compareData(trueVal, index);
          Future.delayed(const Duration(milliseconds: 500), () {
            _productControllers[index].clear();
          });
        });
        // ================================================ //
        // Auto Saving Draft Feature can be started in here //
        // ================================================ //
      }

      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          if (_typeController == 'master') {
            _controller.text = trueVal;
          }
        });
        if (length < 50) {
          if (_typeController == 'master') {
            if ((length - 1) > index) {
              FocusScope.of(context).requestFocus(_masterFocusNodes[index + 1]);
            } else {
              setState(() {
                _isFormEnabled = false;
              });
              FocusScope.of(context).requestFocus(_productFocusNodes[0]);
            }
          }
        }
      });
    }
  }

  Future<Null> _saveAndPrint(DateTime createdDate) async {
    String currentTime =
        DateFormat("yyyy/MM/dd HH:mm:ss").format(DateTime.now());
    String createdAt = DateFormat("yyyy/MM/dd HH:mm").format(createdDate);
    String filenameDate = DateFormat("yyyyMMdd").format(createdDate);

    String deviceName = await FileManager.readProfile('device_name');
    if (deviceName == null) {
      deviceName = 'Unknown';
    }
    String userName = await FileManager.readProfile('user_name');
    if (userName == null) {
      userName = 'Unknown';
    }
    String companyName = await FileManager.readProfile('company_name');
    if (companyName == null) {
      companyName = 'Unknown';
    }
    String remark1 = await FileManager.readProfile('remark1');
    if (remark1 == null) {
      remark1 = 'Unknown';
    }
    String remark2 = await FileManager.readProfile('remark2');
    if (remark2 == null) {
      remark2 = 'Unknown';
    }

    List<String> valueList = [];
    int len = _masterControllers.length;

    List<String> _masterList = [];
    List<String> _productList = [];
    List<String> _counterList = []; // Matched Counter Value

    if (_dispatchNoController.text != null ||
        _numberOfScanController.text != null) {
      for (int i = 0; i < len; i++) {
        String buff =
            '$createdAt, ${_dispatchNoController.text}, ${_numberOfScanController.text}, ${_masterControllers[i].text}, ${_productControllers[i].text}, ${counterList[i].toString()}, $currentTime, $deviceName, $userName\r\n';
        valueList.add(buff);
        _masterList.add(_masterControllers[i].text);
        _productList.add(_productControllers[i].text);
        _counterList.add(counterList[i].toString());
      }
    }
    print('List Data: $valueList');
    FileManager.saveDispatchData(filenameDate, valueList);
    // prepare the passing value

    // start print operation
    printNote.sample(
        deviceName,
        userName,
        companyName,
        remark1,
        remark2,
        createdAt,
        _dispatchNoController.text,
        _numberOfScanController.text,
        _masterList,
        _productList,
        _counterList,
        currentTime);
  }

  Future<Null> _saveTheDraft(DateTime createdDate) async {
    String draftedTime =
        DateFormat("yyyy/MM/dd HH:mm:ss").format(DateTime.now());
    String dtime = DateFormat("yyyyMMdd").format(DateTime.now());
    int len = _masterControllers.length;

    int totalMatched = 0;

    List<String> _masterList = [];
    List<String> _productList = [];
    List<String> _counterList = []; // Matched Counter Value
    List<String> _otherList = [];

    if (_dispatchNoController.text != null ||
        _numberOfScanController.text != null) {
      for (int i = 0; i < len; i++) {
        _masterList.add(_masterControllers[i].text);
        _productList.add(_productControllers[i].text);
        _counterList.add(counterList[i].toString());
        if (counterList[i] > 0) {
          totalMatched++;
        }
      }
    }
    // _otherList.add(dtime);
    _otherList.add(createdDate.toString());
    _otherList.add(_dispatchNoController.text);
    _otherList.add(_numberOfScanController.text);
    _otherList.add(draftedTime);

    // To create Unique name for the draft list view
    String draftName = '${_dispatchNoController.text}/$dtime/${_numberOfScanController.text}/$totalMatched';
    FileManager.addToDraftNameList(draftName);

    String draftIndexName = '${_dispatchNoController.text}_$dtime';
    FileManager.addDraftIndexNameBank(draftIndexName);

    FileManager.saveDraft('draft_master_$draftIndexName', _masterList);
    FileManager.saveDraft('draft_product_$draftIndexName', _productList);
    FileManager.saveDraft('draft_counter_$draftIndexName', _counterList);
    FileManager.saveDraft('draft_other_$draftIndexName', _otherList);

  }

  Future<Null> _disableInput(int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure to cancel #${index + 1}?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              print('Yes clicked');
              setState(() {
                keyEnableList[index] = false;
                _productControllers[index].text = 'Cancelled';
                _checkInputs();
              });
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              print('No clicked');
              Navigator.pop(context);
            },
          ),
        ],
      ));
  }

  Future<Null> _enableInput(int index) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure to enable #${index + 1}?"),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes'),
            onPressed: () {
              print('Yes clicked');
              setState(() {
                keyEnableList[index] = true;
                _productControllers[index].text = '';
                _checkInputs();
              });
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text('No'),
            onPressed: () {
              print('No clicked');
              Navigator.pop(context);
            },
          ),
        ],
      ));
  }

  Future<Null> _initValues() async {
    for (int i = 0; i < 50; i++) {
      keyEnableList.add(true);
      matchList.add(false);
      counterList.add(0);
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    _dispatchNoController.dispose();
    _numberOfScanController.dispose();
  }

  @override
  void initState() {
    super.initState();
    printNote = PrintNote();
    _dispatchNoController.addListener(_dipatchNoListener);
    _numberOfScanController.addListener(_numberScanListener);
    _initValues();
  }

  @override
  Widget build(BuildContext context) {
    DateTime createdDate = DateTime.now();

    Widget _mainInput(BuildContext context, String header,
        TextEditingController _mainController, FocusNode _mainNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Text(
                '$header',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF004B83),
                  fontWeight: FontWeight.bold,
                ),
              )),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 30,
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF004B83),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8.0),
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
                      icon: Icon(
                        EvaIcons.close,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                      onPressed: () {
                        _clearTextController(
                            context, _mainController, _mainNode);
                      },
                    ),
                  ),
                  autofocus: false,
                  controller: _mainController,
                  focusNode: _mainNode,
                  onTap: () {
                    _focusNode(context, _mainNode);
                  },
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _scannerInput(BuildContext context, String typeController,
        TextEditingController _controller, FocusNode currentNode, int index) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          height: 25,
          child: TextFormField(
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF004B83),
              fontWeight: FontWeight.bold,
            ),
            enabled: typeController == 'master' ? _isFormEnabled : keyEnableList[index],
            decoration: InputDecoration.collapsed(
              filled: true,
              fillColor: Colors.white,
              hintText: typeController,
              hintStyle: TextStyle(
                color: Color(0xFF004B83),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            autofocus: true,
            controller: _controller,
            focusNode: currentNode,
            onTap: () {
              _clearTextController(context, _controller, currentNode);
              if (typeController == 'master') {
                setState(() {
                  counterList[index] = 0;
                });
              }
            },
            onChanged: (value) {
              _controllerEventListener(index, _controller, typeController);
            },
          ),
        ),
      );
    }

    Widget statusBar(int index) {
      return Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: keyEnableList[index]
                ? IconButton(
                    icon: Icon(
                      EvaIcons.checkmarkOutline,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      _disableInput(index);
                    },
                  )
                : IconButton(
                    icon: Icon(
                      EvaIcons.closeCircleOutline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _enableInput(index);
                    },
                  ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: matchList[index]
                  ? new Icon(
                      FontAwesomeIcons.solidCircle,
                      size: 28,
                      color: Colors.green,
                    )
                  : new Icon(
                      FontAwesomeIcons.solidCircle,
                      size: 28,
                      color: Colors.red,
                    ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.all(2),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(3),
                  ),
                  side: BorderSide(width: 1, color: Colors.black),
                ),
              ),
              child: Center(
                child: Text(
                  counterList[index].toString(), // counter.toString(),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget dateTime(String time) {
      return Text(
        time,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'QuickSand',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      );
    }

    Widget _saveDraftButton(BuildContext context) {
      return Padding(
          padding: EdgeInsets.all(5),
          child: MaterialButton(
            onPressed: () {
              print('You pressed Draft Button!');
              _saveTheDraft(createdDate).then((_) {
                Alert(
                  context: context,
                  type: AlertType.success,
                  title: "Dispatch note is drafted successfully",
                  desc: "You can check it on Drafts Menu.",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
                        _setNavbarItem(false);
                      },
                      width: 120,
                    )
                  ],
                ).show();
              });
              // _setDraftValues(i, draftList);
            },
            child: Text(
              'Save as Draft',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'QuickSand',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            shape: StadiumBorder(),
            color: Colors.orange[800],
            splashColor: Colors.yellow[200],
            height: 30,
            minWidth: 120,
            elevation: 2,
          ));
    }

    Widget _printAndOkButton(BuildContext context) {
      return Padding(
          padding: EdgeInsets.all(10),
          child: MaterialButton(
            onPressed: _isButtonDisabled
                ? null
                : () {
                    print('You pressed Save and Print Button!');
                    _saveAndPrint(createdDate).then((_) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: new Text(
                            "Saved! Printing Request has sent",
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(milliseconds: 2000)));
                    });
                  },
            child: Text(
              'Print & Ok',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'QuickSand',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            shape: StadiumBorder(),
            color: Colors.teal[400],
            splashColor: Colors.blue[100],
            height: 30,
            minWidth: 120,
            elevation: 2,
          ));
    }

    // Widget buildContainer(Widget child) {
    //   return Container(

    //     child: child,
    //   );
    // }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        child: Column(
          children: <Widget>[
            dateTime(DateFormat("yyyy/MM/dd HH:mm:ss").format(createdDate)),
            _mainInput(
                context, 'Dispatch No:', _dispatchNoController, _dispatchNode),
            _mainInput(
                context, 'Total Items:', _numberOfScanController, _numberNode),
            SizedBox(
              height: 15,
            ),
            new Expanded(
              child: new ListView.builder(
                itemCount: _masterControllers?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Item: ${index + 1}'),
                              _scannerInput(
                                  context,
                                  'master',
                                  _masterControllers[index],
                                  _masterFocusNodes[index],
                                  index),
                              _scannerInput(
                                  context,
                                  'product',
                                  _productControllers[index],
                                  _productFocusNodes[index],
                                  index),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: statusBar(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: _saveDraftButton(context),
                ),
                Expanded(
                  child: _printAndOkButton(context),
                )
              ],
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
