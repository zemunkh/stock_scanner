import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/main_drawer.dart';
import '../widgets/dispatch_saved_file_item.dart';
import '../helper/file_manager.dart';


class DispatchSavedScreen extends StatefulWidget {
  static const routeName = '/dispatch_saved';

  @override
  _DispatchSavedScreenState createState() => _DispatchSavedScreenState();
}

class _DispatchSavedScreenState extends State<DispatchSavedScreen> {
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
    // final fileData = Provider.of<Files>(context);
    return WillPopScope(
      onWillPop: _backButtonPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dispatch Saved Page'),
        ),
        drawer: MainDrawer(),
        body: Container(
          child: Center(
            child: new FutureBuilder(
              future: FileManager.getDispatchFilesList(),
              builder: (context, snapshot){
                var myData = snapshot.data;
                if(snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                    itemCount: myData == null ? 0: myData.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        DispatchSavedFileItem(
                          myData[i],
                          i,
                        ),
                        Divider(),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        )
      ),
    );
  }
}

