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
  return FutureBuilder(
    future: FlutterInappPurchase.instance.getProducts(_productLists),
    builder: (context, snapshot) {
      if (!snapshot.hasData)
        return const CircularProgressIndicator();
      else {
        _items = snapshot.data! as List<IAPItem>;
        return Text(
          'platformVersion: $platformVersion \t items: ${_items.length}\n' +
          '${_items[0].title!.substring(0, 11)}  Price: ${_items[0].price} ${_items[0].currency}\n' +
          '${_items[1].title!.substring(0, 11)}  Price: ${_items[1].price} ${_items[0].currency}\n' +
          '${_items[2].title!.substring(0, 11)}  Price: ${_items[2].price} ${_items[0].currency}\n' +
          '${_items[0].description}'
        );
      }
    });
}
