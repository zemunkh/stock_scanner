import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrintNote {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

   sample(String dname, String username, String companyName, String remark1, String remark2, String createdAt, String _dispatchNo, String _totalNumber, List<String> _masterList, List<String> _productList, List<String> _counterList, String currentTime) async {

    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT
    bluetooth.isConnected.then((isConnected) {
      if (isConnected) {
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("Dispatch Note:",3,1);
        bluetooth.printCustom("Company: $companyName",0,1);
        bluetooth.printCustom("Remark 1: $remark1",0,1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Device ID: $dname",0,0);
        bluetooth.printCustom("Username: $username",0,0);
        bluetooth.printNewLine();
        // bluetooth.printImage(pathImage);   //path of your image/logo
        bluetooth.printNewLine();
        bluetooth.printLeftRight("CreatedAt: $createdAt", '',0);
        bluetooth.printLeftRight("DispatchNo: $_dispatchNo", '',0);
        bluetooth.printLeftRight("Total Items: $_totalNumber", '',0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        for(int i = 0; i < _masterList.length; i++) {
          bluetooth.printLeftRight("#${i+1} Master:", '${_masterList[i]}',0);
          bluetooth.printLeftRight("#${i+1} Product:", '${_productList[i]}',0);
          bluetooth.printCustom("#${i+1} Matched: ${_counterList[i]}",0,0);
          bluetooth.printNewLine();
        }
        bluetooth.printNewLine();
        bluetooth.printCustom("PrintedTime: $currentTime",0,1);
        // bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("$remark2",0,1);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }
}