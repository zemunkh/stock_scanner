import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/services.dart';

import '../helper/file_manager.dart';


class StockIn extends StatefulWidget {
  @override
  StockInState createState() => StockInState();
}

class StockInState extends State<StockIn> {
  final _masterController = TextEditingController();
  final _productController = TextEditingController();

  final FocusNode _masterNode = FocusNode();
  final FocusNode _productNode = FocusNode();

  // final _formKey = GlobalKey<FormFieldState>();

  bool matched = true;
  bool oneToMany = true;
  var counter = 0;

  String deviceName;
  String userName;

  Future<Null> _compareData() async {
    final masterCode = _masterController.text;
    final productCode = _productController.text;

    userName = await FileManager.readProfile('user_name');
    deviceName = await FileManager.readProfile('device_name');

    print('Comparison: $masterCode : $productCode');

    setState(() {
      if(masterCode == productCode) {
        matched = true;
        counter++;
      } else {
        matched = false;
      }
      FileManager.saveScanData(masterCode, productCode, counter, matched, DateTime.now(), userName, deviceName);
    });
  }

  Future<Null> _enableOneToMany(bool isOn) async {
    setState(() {
      oneToMany = isOn;
      isOn = !isOn;
      _masterController.clear();
      _productController.clear();
      counter = 0; 
    });
    print('Switch button value $oneToMany');
  }
  String buffer = '';
  String trueVal = '';

  Future<Null> masterListener() async {
    print('Current text: ${_masterController.text}');
    buffer = _masterController.text;
    if(buffer.endsWith(r'$')){
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;
      _masterNode.unfocus();
      await Future.delayed(const Duration(milliseconds: 200), (){
        setState(() {
          _masterController.text = trueVal;
        });
        FocusScope.of(context).requestFocus(_productNode);
      });
    }
  }

  Future<Null> productListener() async {
    buffer = _productController.text;
    if(buffer.endsWith(r'$')) {
      buffer = buffer.substring(0, buffer.length - 1);
      trueVal = buffer;


      await Future.delayed(const Duration(milliseconds: 1000), (){
        _productController.text = trueVal;
      }).then((value){
        _compareData();
        if(oneToMany) {
          Future.delayed(const Duration(milliseconds: 500), (){
            _productController.clear();
          });
        } else {
          _productNode.unfocus();
          FocusScope.of(context).requestFocus(new FocusNode());
        }
      });
    }
  }

  Future<Null> _focusNode(BuildContext context, FocusNode node) async {
    FocusScope.of(context).requestFocus(node);
  }

  Future<Null> _clearTextController(BuildContext context, TextEditingController _controller, FocusNode node) async {
    setState(() {
      _controller.clear();
      if(oneToMany || (_controller == _masterController)) {
        counter = 0;
      }
    });

    FocusScope.of(context).requestFocus(node);
  }

  @override
  void dispose() {
    super.dispose();
    _masterController.dispose();
    _productController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _masterController.addListener(masterListener);
    _productController.addListener(productListener);
    // for(int i = 0; i < 1; i++) {
    //   FileManager.removeFromBank(i);
    //   FileManager.removeFromIndexBank(i);
    // }

  }
  
  @override
  Widget build(BuildContext context) {
    // To hide keyboards on the restart.
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    Widget _titleWidget(String title) {
      return Text(
        title,
        style: TextStyle(
          color: Colors.black, 
          fontSize: 18,
          fontFamily: 'QuickSand',
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.start,       
      );
    }

    Widget _scannerInput(String hintext, TextEditingController _controller, FocusNode currentNode) {
      return Stack(
        alignment: const Alignment(1.0, 1.0),
        children: <Widget>[
          Container(
            child: TextFormField(
              style: TextStyle(
                fontSize: 22, 
                color: Color(0xFF004B83),
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: hintext,
                hintStyle: TextStyle(
                  color: Color(0xFF004B83), 
                  fontWeight: FontWeight.w200,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              // autofocus: false,
              controller: _controller,
              focusNode: currentNode,
              onTap: () {
                _focusNode(context, currentNode);
              },
            ),
          ),
          FlatButton(
            onPressed: () {
              _clearTextController(context, _controller, currentNode);
              if(_controller == _masterController) {
                _productController.clear();
              }
            },
            child: Container(padding: EdgeInsets.only(bottom: 16),child: Icon(EvaIcons.refresh, color: Color(0xFF004B83), size: 30,)),
          ),
        ],
      );
    }

    final switchButton = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Transform.scale(
              scale: 1.5,
              child: Switch(
                value: oneToMany,
                activeColor: Colors.blueAccent,
                onChanged: (isOn) {
                  _enableOneToMany(isOn);
                },
              ),
            ),
            Center(
              child: Text('One to Many'),
            ),
          ],
        ),
      ], 
    );

    final statusBar = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: matched ? new Icon(
            EvaIcons.checkmarkCircleOutline,
            size: 80,
            color: Colors.green,
          ) : new Icon(
            EvaIcons.closeCircleOutline,
            size: 80,
            color: Colors.red,
          ),
        ),

        Container(
          child: switchButton,
        ),
        
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(10),
              ),
              side: BorderSide(width: 1, color: Colors.black), 
            ),
          ),
          child: Center(
            child: Text(
              counter.toString(),
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ),
        ),
      ],
    );


    return new GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
            statusBar,

            _titleWidget('Barcode #1'),
            SizedBox(height: 10,),
            _scannerInput(
              'Master key',
              _masterController,
              _masterNode,
            ),

            _titleWidget('Barcode #2'),
            SizedBox(height: 10,),
            _scannerInput(
              'Product key',
              _productController,
              _productNode,
            ),        
          ],
      ),
    );
  } 
}
