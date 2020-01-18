import 'package:flutter/material.dart';
import 'package:retail_scanner/helper/file_manager.dart';
import 'package:retail_scanner/screens/dispatch_draft_edit_screen.dart';
import 'package:retail_scanner/screens/dispatch_draft_screen.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';


class DispatchDraftItem extends StatelessWidget {
  final String draftName;
  final int index;

  DispatchDraftItem(this.draftName, this.index);

  Future<Null> _deleteItem(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure to delete #${index + 1}?",          
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Yes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004B83),),),
            onPressed: () async {
              List<String> draftIndexBank = await FileManager.getDraftIndexNameBank();
              FileManager.removeDraft('draft_master_${draftIndexBank[index]}');
              FileManager.removeDraft('draft_product_${draftIndexBank[index]}');
              FileManager.removeDraft('draft_counter_${draftIndexBank[index]}');
              FileManager.removeDraft('draft_other_${draftIndexBank[index]}');
              FileManager.removeFromIndexBank(index);
              FileManager.removeFromBank(index);
              print('Draft name: $draftName');
              Navigator.of(context).pushReplacementNamed(DispatchDraftScreen.routeName);
            },
          ),
          FlatButton(
            child: Text('No', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004B83),),),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold),),
      title: Text(draftName),
      trailing: Container(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(EvaIcons.trash2Outline),
              onPressed: () async {
                _deleteItem(context, index);
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
      onTap: (){
        print('Tapped, Move to next screen');
        print('Draft name: $draftName');
        FileManager.setSelectedIndex(index);

        Navigator.of(context).pushReplacementNamed(DispatchDraftEditScreen.routeName);
      },
    );
  }
}