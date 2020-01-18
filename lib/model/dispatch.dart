import 'package:flutter/foundation.dart';

class DispatchNote {
  final String createdAt;
  final String dispatchNo;
  final String totalNo;
  final List<String> masterList;
  final List<String> productList;
  final List<String> counterList;
  final String currentTime;

  const DispatchNote ({
    @required this.createdAt,
    @required this.dispatchNo,
    @required this.totalNo,
    @required this.masterList,
    @required this.productList,
    @required this.counterList,
    @required this.currentTime,
  });
}