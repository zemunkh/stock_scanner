import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

_saveFilename(String key, String fname) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> files = prefs.getStringList(key);
  if(files == null || files.isEmpty) {
    files = [fname];
    prefs.setStringList(key, files);
  } else {
    if(files[files.length - 1] != fname) {
      files.add(fname);
      prefs.setStringList(key, files);
    }
  }
  print('Stock Files are saved: $files');
}


class FileManager {
  static get context => null;

  static void saveDispatchData(String _createdAt, List<String> _valuesList) {

    writeToDispatchCsv('dispatch_$_createdAt', _valuesList).then((_){
      _saveFilename('dispatch_files', 'dispatch_$_createdAt.csv');
    });
  }

  static void saveScanData(String masterCode, String productCode, int counter, bool matched, DateTime currentDate, String userName, String deviceName) {
    String filename = '${DateFormat("yyyyMMdd").format(currentDate)}';
    String time = DateFormat("yyyy/MM/dd HH:mm:ss").format(currentDate);
    print('Time: $time');

    String matching = matched ? 'matched' : 'unmatched';

    writeToStockCsv('stock_$filename', time, masterCode, productCode, counter, matching, userName, deviceName).then((_){
      _saveFilename('stock_files', 'stock_$filename.csv');
    });
  }

  static Future<String> get _getLocalPath async {
    final directory  = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getCsvFile(String filename) async {
    final path = await _getLocalPath;
    print("$path/$filename.csv");

    File file = File("$path/$filename.csv");
    if(!await file.exists()) {
      print('Creating CSV file');
      file.createSync(recursive: true);
      return file;
    } else {
      print('Opening Existing CSV file');
      return file;
    }
  }

  static Future<Null> writeToStockCsv(String filename, String time, String key1, String key2, int counter, String matching, String userName, String deviceName) async {
    final file = await getCsvFile(filename);

    // String countedValue = await getCounter(filename, key);
    String newData = '$time, $key1, $key2, ${counter.toString()}, $matching, $userName, $deviceName \r\n';

    String content = file.readAsStringSync();
    file.writeAsStringSync(content + newData);
    print(content);
  }

  static Future<Null> writeToDispatchCsv(String createdAt, List<String> _valuesList) async {
    final file = await getCsvFile('$createdAt');
    String content = '';
    String newLine = '';
    for(int i = 0; i < _valuesList.length; i++){
      content = file.readAsStringSync();
      newLine = _valuesList[i];
      file.writeAsStringSync(content + newLine);
    }
    print(content);
  }

  static Future<Null> saveDraft(String key, List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, list);
  }


  static Future<List> readDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> draftedList = prefs.getStringList(key);

    return draftedList;
  }

  static Future<Null> removeDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<Null> saveProfile(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<String> readProfile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String profile = prefs.getString(key);
    return profile;
  }

  static Future<Null> updateDraftList(int index, String key, String draftName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null || drafts.isEmpty) {
      drafts = [draftName];
      prefs.setStringList(key, drafts);
    } else {
      // drafts.add(draftName);
      drafts[index] = draftName;
      prefs.setStringList(key, drafts);
    }
    print('Draft Updated List: $drafts');
    return null;
  }

  static Future<List> getDraftList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null) {
      drafts = [];
    }
    print('Draft List: $drafts');
    return drafts;
  }

  static Future<Null> setSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('draft_selected', index);
    return null;
  }
  static Future<int> getSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('draft_selected');
    return index;
  }

  static Future<Null> addDraftIndexNameBank(String draftIndexName) async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'draft_index_name_bank';
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null || drafts.isEmpty) {
      drafts = [draftIndexName];
      prefs.setStringList(key, drafts);
    } else {
      if(drafts[drafts.length - 1] != draftIndexName) {
        drafts.add(draftIndexName);
        prefs.setStringList(key, drafts);
      }
    }
    print('Draft Bank List: $drafts');
    return null;
  }

  static Future<List> getDraftIndexNameBank() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_index_name_bank';
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null) {
      drafts = [];
    }
    print('Draft Index Name Bank: $drafts');
    return drafts;
  }

  static Future<Null> removeFromIndexBank(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_index_name_bank';
    List<String> drafts = prefs.getStringList(key);
    if(prefs != null) {
      drafts.removeAt(index);
      prefs.setStringList(key, drafts);
    }
    print('Draft Bank: $drafts');
  }

  static Future<Null> addToDraftNameList(String draftName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_name_bank';
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null || drafts.isEmpty) {
      drafts = [draftName];
      prefs.setStringList(key, drafts);
    } else {
      if(drafts[drafts.length - 1] != draftName) {
        drafts.add(draftName);
        prefs.setStringList(key, drafts);
      }
    }
    print('Draft List: $drafts');
    return null;
  }

  static Future<List> getDraftNameBank() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_name_bank';
    List<String> drafts = prefs.getStringList(key);
    if(drafts == null) {
      drafts = [];
    }
    print('Draft Bank: $drafts');
    return drafts;
  }

  static Future<Null> removeFromBank(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'draft_name_bank';
    List<String> drafts = prefs.getStringList(key);
    if(prefs != null) {
      drafts.removeAt(index);
      prefs.setStringList(key, drafts);
    }
    print('Draft Bank: $drafts');
  }

  static Future<List> getStockFilesList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> files = prefs.getStringList('stock_files');
    print('Files List: $files');
    final dateNow = DateTime.now();
    DateTime fileCreatedDate;
    int diff;
    String expiryDay = await readProfile('expiry_day');
    if(expiryDay == null) {
      expiryDay = '30';
    }

    if(files.isNotEmpty) {
      for(int i = 0; i < files.length; i++) {
        fileCreatedDate = _getCreatedDate(files[i]);
        diff = dateNow.difference(fileCreatedDate).inDays;
        if(diff > int.parse(expiryDay)) {
          print('${files[i]} is expired!. Now deleting');
          await deleteFile(files[i], i, 'stock_files');
        } else {
          print("Not expired: Remaining ${int.parse(expiryDay) - diff}");
        }
      }
      return files;
    }
    return null;
  }

  static Future<List> getDispatchFilesList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> files = prefs.getStringList('dispatch_files');
    print('Files List: $files');
    final dateNow = DateTime.now();
    DateTime fileCreatedDate;
    int diff;
    String expiryDay = await readProfile('expiry_day');
    if(expiryDay == null) {
      expiryDay = '30';
    }

    if(files.isNotEmpty) {
      for(int i = 0; i < files.length; i++) {
        fileCreatedDate = _getCreatedDate(files[i]);
        diff = dateNow.difference(fileCreatedDate).inDays;
        if(diff > int.parse(expiryDay)) {
          print('${files[i]} is expired!. Now deleting');
          await deleteFile(files[i], i, 'dispatch_files');
        } else {
          print("Not expired: Remaining ${int.parse(expiryDay) - diff}");
        }
      }
      return files;
    }
    return null;
  }

  static Future<Null> deleteFile(String filename, int index, String key) async {
    Directory dir = await getApplicationDocumentsDirectory();
    File currentFile = File("${dir.path}/$filename");
    final prefs = await SharedPreferences.getInstance();
    List<String> dispatchFiles = prefs.getStringList(key);
    if(prefs != null) {
      dispatchFiles.removeAt(index);
      prefs.setStringList(key, dispatchFiles);
      currentFile.deleteSync(recursive: true);
    }
    print('Files List: $dispatchFiles');
  }
}

  DateTime _getCreatedDate(String filename) {
    String date, year, month, day;
    date = filename.split('_')[1];
    date = date.split('.')[0];
    print('Date: $date');
    year = date[0] + date[1] + date[2] + date[3];
    month = date[4] + date[5];
    day = date[6] + date[7];
    print("Data: $year, $month, $day");
    return DateTime(int.parse(year), int.parse(month), int.parse(day));
  }
