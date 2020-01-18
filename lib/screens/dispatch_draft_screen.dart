import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/file_manager.dart';
import '../widgets/dispatch_draft_item.dart';
import '../widgets/main_drawer.dart';


class DispatchDraftScreen extends StatefulWidget {
  static const routeName = '/drafts';
  @override
  DispatchDraftScreenState createState() => DispatchDraftScreenState();
}

class DispatchDraftScreenState extends State<DispatchDraftScreen> {
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
          title: Text('Dispatch Draft List'),
        ),
        drawer: MainDrawer(),
        body: Container(
          child: new FutureBuilder(
            future: FileManager.getDraftNameBank(),
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done) {
                var myData = snapshot.data;
                return Container(
                  child: ListView.builder(
                    itemCount: myData == null ? 0: myData.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        DispatchDraftItem(
                          myData[i],
                          i,
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                );
              }
              else {
                return new Center(child:CircularProgressIndicator(),);
              }
            },
          ),
        ),
      ),
    );
  }
}
