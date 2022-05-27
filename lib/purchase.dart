import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter/foundation.dart'
  show defaultTargetPlatform, kIsWeb, TargetPlatform;

late StreamSubscription _purchaseUpdatedSubscription;
late StreamSubscription _purchaseErrorSubscription;
late StreamSubscription _conectionSubscription;
String? platformVersion = 'Unknown';

// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState() async {
//  String? platformVersion;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    platformVersion = await FlutterInappPurchase.instance.platformVersion;
  } on PlatformException {
    platformVersion = 'Failed to get platform version.';
  }
  print('platformVersion: $platformVersion');
  // prepare
  var result = await FlutterInappPurchase.instance.initConnection;
  print('result: $result');

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
//  if (!mounted) return;

//  setState(() {
//    _platformVersion = platformVersion!;
//  });

  // refresh items for android
  try {
    String msg = await FlutterInappPurchase.instance.consumeAllItems;
    print('consumeAllItems: $msg');
  } catch (err) {
    print('consumeAllItems error: $err');
  }

  _conectionSubscription =
      FlutterInappPurchase.connectionUpdated.listen((connected) {
    print('connected: $connected');
  });

  _purchaseUpdatedSubscription =
      FlutterInappPurchase.purchaseUpdated.listen((productItem) {
    print('purchase-updated: $productItem');
  });

  _purchaseErrorSubscription =
      FlutterInappPurchase.purchaseError.listen((purchaseError) {
    print('purchase-error: $purchaseError');
  });
}

Widget purchaseBody() {

  final List<String> _productLists = defaultTargetPlatform == TargetPlatform.android ||  kIsWeb // Platform.isAndroid
      ? [
          'golfer_1_month_fee',
          'golfer_1_season_fee',
          'golfer_1_year_fee'
        ]
       : [
          'golfer_consume_1_month', 
          'golfer_consume_1_season'
          'golfer_consume_1_year'
        ];

  List<IAPItem> _items = [];
  List<PurchasedItem> _purchases = [];
/*
  List<IAPItem> items = await FlutterInappPurchase.instance.getProducts(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      _items.add(item);
    }*/
  return Text('platformVersion: $platformVersion \n items: ${_items.length}');
}
