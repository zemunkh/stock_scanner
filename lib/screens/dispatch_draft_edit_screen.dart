import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:retail_scanner/helper/file_manager.dart';
import 'package:retail_scanner/screens/dispatch_draft_screen.dart';
import 'package:retail_scanner/widgets/print_note.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


class DispatchDraftEditScreen extends StatefulWidget {
  static const routeName = '/draft_edit';
  @override
  DispatchDraftEditScreenState createState() => DispatchDraftEditScreenState();
}

class DispatchDraftEditScreenState extends State<DispatchDraftEditScreen> {

  List<TextEditingController> _masterControllers = new List();
  List<TextEditingController> _productControllers = new List();

  List<FocusNode> _masterFocusNodes = new List();
  List<FocusNode> _productFocusNodes = new List();

  final _dispatchNoController = TextEditingController();
  final _numberOfScanController = TextEditingController();

  final _dispatchNode = FocusNode();
  final _numberNode = FocusNode();

  List<String> _otherList = [];

  bool lockEn = true;
  bool _isButtonDisabled = true;
  List<bool> _isMasterEnabled = [];

  // final _mainFormKey = GlobalKey<FormState>();
  // final _scannerFormKey = GlobalKey<FormFieldState>();

  PrintNote printNote;

  String draftNameIndex = '';
  String createdDate = '';
  DateTime createdDateTime;
  // Widget _form;
  List<bool> keyEnableList = [];
  List<bool> matchList = [];
  List<int> counterList = [];

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
      if(masterCode == prodVal) {
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
    if(buffer.endsWith(r'$')){
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;
      _dispatchNode.unfocus();
      await Future.delayed(const Duration(milliseconds: 200), (){
        setState(() {
          _dispatchNoController.text = trueVal;
        });
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    }
  }

  List<String> _masterList = [];
  List<String> _productList = [];
  List<String> _counterList = [];

  Future<Null> _numberScanListener() async {

    buffer = _numberOfScanController.text;
    if(buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;

      _masterList =  await FileManager.readDraft('draft_master_$draftNameIndex');
      _productList = await FileManager.readDraft('draft_product_$draftNameIndex');
      _counterList = await FileManager.readDraft('draft_counter_$draftNameIndex');

      await Future.delayed(const Duration(milliseconds: 1000), (){
        _numberOfScanController.text = trueVal;
      }).then((value){

        // set the number of inputs will be built in the screen
        if(trueVal != '') {
          if(int.parse(trueVal) < 51) {

            print('Controller Length: ${_masterControllers.length}');

            if(_masterControllers.length < int.parse(trueVal) ) {
              int diff = int.parse(trueVal) - _masterControllers.length;
              setState(() {
                for(int i = 0; i < diff; i++) {
                  print('adding:');
                  _masterControllers.add(new TextEditingController());
                  _productControllers.add(new TextEditingController());

                  if(_masterList[i] == '') {
                    _isMasterEnabled[i] = true;
                  } else {
                    _isMasterEnabled[i] = false;
                  }

                  if(_productList[i] == 'Cancelled') {
                    keyEnableList[i] = false;
                  }

                  _masterControllers[i].text = _masterList[i];
                  _productControllers[i].text = _productList[i];
                  counterList[i] = int.parse(_counterList[i]);
                  if((counterList[i] > 0 || keyEnableList[i] == false) && _dispatchNoController.text != null) {
                    matchList[i] = true;

                    // at least counter > 0, that will add up 1/3
                    _isButtonDisabled = _isButtonDisabled || false;
                  } else {
                    _isButtonDisabled = _isButtonDisabled || true;
                  }
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

  Future<Null> _clearTextController(BuildContext context, TextEditingController _controller, FocusNode node) async {
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _controller.clear();
      });
      FocusScope.of(context).requestFocus(node);
    });
  }

  _controllerEventListener(int index, TextEditingController _controller, String _typeController) {
    int length = _masterControllers.length;
    print('Length of the controllers: $length, index: $index');
    if(_typeController == 'master') {
      buffer = _masterControllers[index].text;
    } else if(_typeController == 'product') {
      buffer = _productControllers[index].text;
    }

    if(buffer.endsWith(r'$')){
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;
      if(_typeController == 'master' && trueVal != '') {
        print('I am master!');
        _isMasterEnabled[index] = false;
      } else if(_typeController == 'product') {
        print('I am product!');
        Future.delayed(const Duration(milliseconds: 1000), (){
          _productControllers[index].text = trueVal;
        }).then((value){
          _compareData(trueVal, index);
          Future.delayed(const Duration(milliseconds: 500), (){
            _productControllers[index].clear();
          });
        });
      } else {
        print('Nothing to do');
      }

      Future.delayed(const Duration(milliseconds: 200), (){
        setState(() {
          _controller.text = trueVal;
        });
        if(length < 50) {
          if(_typeController == 'master') {
            FocusScope.of(context).requestFocus(_productFocusNodes[index]);
          } else if(_typeController == 'product') {
            if((length - 1) > index){
              FocusScope.of(context).requestFocus(_masterFocusNodes[index + 1]);
            } else {
              FocusScope.of(context).requestFocus(new FocusNode());
            }

          }
        }
      });
    }
  }

  Future<Null> _saveAndPrint(DateTime createdDateTime) async {

    String currentTime = DateFormat("yyyy/MM/dd HH:mm:ss").format(DateTime.now());
    String createdAt = DateFormat("yyyyMMdd").format(createdDateTime);
    List<String> valueList = [];
    int len = _masterControllers.length;

    int draftIndex = await FileManager.getSelectedIndex();

    String deviceName = await FileManager.readProfile('device_name');
    if(deviceName.isEmpty) {
      deviceName = 'Unknown';
    }
    String userName = await FileManager.readProfile('user_name');
    if(userName.isEmpty) {
      userName = 'Unknown';
    }
    String companyName = await FileManager.readProfile('company_name');
    if(companyName.isEmpty) {
      companyName = 'Unknown';
    }
    String remark1 = await FileManager.readProfile('remark1');
    if(remark1.isEmpty) {
      remark1 = 'Unknown';
    }
    String remark2 = await FileManager.readProfile('remark2');
    if(remark2.isEmpty) {
      remark2 = 'Unknown';
    }
    List<String> _masterList = [];
    List<String> _productList = [];
    List<String> _counterList = [];  // Matched Counter Value

    if(_dispatchNoController.text != null || _numberOfScanController.text != null) {
      for(int i = 0; i < len; i++) {
        String buff = '$createdAt, ${_dispatchNoController.text}, ${_numberOfScanController.text}, ${_masterControllers[i].text}, ${_productControllers[i].text}, ${counterList[i].toString()}, $currentTime, $deviceName, $userName\r\n';
        valueList.add(buff);
        _masterList.add(_masterControllers[i].text);
        _productList.add(_productControllers[i].text);
        _counterList.add(counterList[i].toString());
      }
    }
    print('List Data: $valueList');
    FileManager.saveDispatchData(createdAt, valueList);
    // prepare the passing value
    String draftIndexName = '${_dispatchNoController.text}_$createdAt';
    FileManager.removeDraft('draft_master_$draftIndexName');
    FileManager.removeDraft('draft_product_$draftIndexName');
    FileManager.removeDraft('draft_counter_$draftIndexName');
    FileManager.removeDraft('draft_other_$draftIndexName');
    FileManager.removeFromBank(draftIndex);
    FileManager.removeFromIndexBank(draftIndex);
    // start print operation
    printNote.sample(deviceName, userName, companyName, remark1, remark2, createdAt, _dispatchNoController.text, _numberOfScanController.text, _masterList, _productList, _counterList, currentTime);
    return null;
  }

  Future<Null> _saveTheDraft(DateTime createdDateTime) async {

    String draftedTime = DateFormat("yyyy/MM/dd HH:mm:ss").format(DateTime.now());
    String createdAt = DateFormat("yyyyMMdd").format(createdDateTime);
    int len = _masterControllers.length;

    int totalMatched = 0;
    int index = await FileManager.getSelectedIndex();

    List<String> _masterList = [];
    List<String> _productList = [];
    List<String> _enabledList = [];
    List<String> _counterList = [];  // Matched Counter Value

    List<String> _otherList = [];

    if(_dispatchNoController.text != null || _numberOfScanController.text != null) {
      for(int i = 0; i < len; i++) {
        _masterList.add(_masterControllers[i].text);
        _productList.add(_productControllers[i].text);
        _counterList.add(counterList[i].toString());
        _enabledList.add(keyEnableList[i].toString());
        if(counterList[i] > 0) {
          totalMatched++;
        }
      }
    }
    // _otherList.add(dtime);
    _otherList.add(createdDateTime.toString());
    _otherList.add(_dispatchNoController.text);
    _otherList.add(_numberOfScanController.text);
    _otherList.add(draftedTime);

    // To create Unique name for the draft list view
    String draftFrontName = '${_dispatchNoController.text}/$createdAt/${_numberOfScanController.text}/$totalMatched';
    String draftIndexName = '${_dispatchNoController.text}_$createdAt';
    // FileManager.removeFromIndexBank(index);
    FileManager.updateDraftList(index, 'draft_name_bank', draftFrontName);

    FileManager.saveDraft('draft_master_$draftIndexName', _masterList);
    FileManager.saveDraft('draft_product_$draftIndexName', _productList);
    FileManager.saveDraft('draft_enabled_$draftIndexName', _enabledList);
    FileManager.saveDraft('draft_counter_$draftIndexName', _counterList);
    FileManager.saveDraft('draft_other_$draftIndexName', _otherList);

  }

  void initDraftScreen() async {
 // Matched Counter Value
    List<String> draftIndexBank = await FileManager.getDraftIndexNameBank();
    int draftIndex = await FileManager.getSelectedIndex();
    draftNameIndex = draftIndexBank[draftIndex];
    print('Selected Draft Index: $draftIndex');
    _otherList = await FileManager.readDraft('draft_other_$draftNameIndex');
    _counterList = await FileManager.readDraft('draft_counter_$draftNameIndex');
    print('Other list: $_otherList');

    setState(() {
      createdDateTime = DateTime.parse(_otherList[0]);
      createdDate = DateFormat("yyyy/MM/dd HH:mm:ss").format(createdDateTime);
      _dispatchNoController.text = _otherList[1];
      _numberOfScanController.text = _otherList[2] + r'$';
    });

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
      _isMasterEnabled.add(true);
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
    initDraftScreen();
    _initValues();
  }

  @override
  Widget build(BuildContext context) {

    Widget _mainInput(String header, TextEditingController _mainController, FocusNode _mainNode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              '$header:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                height: 30,
                child: Center(
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
                        icon: Icon(EvaIcons.close,
                          color: Colors.blueAccent,
                          size: 24,
                        ),
                        onPressed: () {
                          _clearTextController(context, _mainController, _mainNode);
                        },
                      ),
                    ),
                    autofocus: true,
                    controller: _mainController,
                    focusNode: _mainNode,
                    onTap: () {
                      _focusNode(context, _mainNode);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _scannerInput(String typeController, TextEditingController _controller, FocusNode currentNode, int index) {
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
            enabled: typeController == 'master' ? _isMasterEnabled[index] : keyEnableList[index],
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
              // _focusNode(context, currentNode);
            },
            onChanged: (value){
              _controllerEventListener(index, _controller, typeController);
            },
          ),
        ),
      );
    }

    Widget statusBar(int index) {
      return Row(children: <Widget>[
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
              child: matchList[index] ? new Icon(
                FontAwesomeIcons.solidCircle,
                size: 28,
                color: Colors.green,
              ) : new Icon(
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
                  counterList[index].toString(),// counter.toString(),
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
          fontSize: 16,
          color: Colors.black,
        ),
      );
    }

    Widget _printAndOkButton(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: _isButtonDisabled ? null : () {
            print('You pressed Save and Print Button!');

            _saveAndPrint(createdDateTime).then((_){
              Alert(
                context: context,
                type: AlertType.success,
                title: "Dispatch note is saved successfully",
                desc: "Printing request has sent.",
                buttons: [
                  DialogButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => Navigator.of(context).pushReplacementNamed(DispatchDraftScreen.routeName),
                    width: 120,
                  )
                ],
              ).show();
            });
          },
          child: Text(
            'Save & Print',
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
          height: 30,
          minWidth: 100,
          elevation: 2,
        )
      );
    }

    Widget _saveDraftButton(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: MaterialButton(
          onPressed: () {
            print('You pressed Draft Button!');
            _saveTheDraft(createdDateTime).then((_){
              // Navigator.of(context).pushReplacementNamed(DispatchDraftScreen.routeName);
              Alert(
                context: context,
                type: AlertType.success,
                title: "Draft is saved successfully",
                desc: "You saved the draft again.",
                buttons: [
                  DialogButton(
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () => Navigator.of(context).pushReplacementNamed(DispatchDraftScreen.routeName),
                    width: 120,
                  )
                ],
              ).show();
            });

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
        )
      );
    }

    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Draft Edit Page'),
          leading: IconButton(
            icon: Icon(
              EvaIcons.arrowBack,
            ),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(DispatchDraftScreen.routeName);
            },
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            child: Column(
              children: <Widget>[
                dateTime(createdDate),

                _mainInput('Dispatch No',_dispatchNoController, _dispatchNode),
                _mainInput('Total Items',_numberOfScanController, _numberNode),
                SizedBox(height: 15,),
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
                                    _scannerInput('master', _masterControllers[index], _masterFocusNodes[index], index),
                                    _scannerInput('product', _productControllers[index], _productFocusNodes[index], index),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _saveDraftButton(context),
                    ),
                    Expanded(
                      child: _printAndOkButton(context),
                    ),
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
