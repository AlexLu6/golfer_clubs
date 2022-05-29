import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter/foundation.dart'
  show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'dataModel.dart';

late StreamSubscription _purchaseUpdatedSubscription;
late StreamSubscription _purchaseErrorSubscription;
late StreamSubscription _conectionSubscription;
String? platformVersion = 'Unknown';
bool isConnected = false, isErr = false, isOK = false;
// Platform messages are asynchronous, so we initialize in an async method.
Future<void> initPlatformState() async {
//  String? platformVersion;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    platformVersion = await FlutterInappPurchase.instance.platformVersion;
  } on PlatformException {
    platformVersion = 'Failed to get platform version.';
  }
  //print('platformVersion: $platformVersion');
  // prepare
  var result = await FlutterInappPurchase.instance.initialize();
  //print('result: $result');

  // refresh items for android
  try {
    String msg = await FlutterInappPurchase.instance.consumeAll();
    //print('consumeAllItems: $msg');
  } catch (err) {
    //print('consumeAllItems error: $err');
  }

  _conectionSubscription =
      FlutterInappPurchase.connectionUpdated.listen((connected) {
        isConnected = connected.connected!;
        //print('connected: $connected');
  });

  _purchaseUpdatedSubscription =
      FlutterInappPurchase.purchaseUpdated.listen((productItem) {
        isOK = true;
    //print('purchase-updated: $productItem');
  });

  _purchaseErrorSubscription =
      FlutterInappPurchase.purchaseError.listen((purchaseError) {
        isErr = true;
    //print('purchase-error: $purchaseError');
  });
}

Future<void> closePlatformState() async {
  _purchaseUpdatedSubscription.cancel();
  _purchaseErrorSubscription.cancel();
  _conectionSubscription.cancel();
  await FlutterInappPurchase.instance.finalize();
}
/*
validateReceipt() async {
  var receiptBody = {
    'receipt-data': '', //purchased.transactionReceipt,
    'password': '******'
  };
  bool isTest = true;
  var result = await validateReceiptIos(receiptBody, isTest);
//  console.log(result);
}
*/
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
  //List<PurchasedItem> _purchases = [];
  return FutureBuilder(
    future: FlutterInappPurchase.instance.getProducts(_productLists),
    builder: (context, snapshot) {
      if (!snapshot.hasData)
        return const CircularProgressIndicator();
      else {
        _items = snapshot.data! as List<IAPItem>;
        return ListView.builder(
          itemCount: _items.length,
          itemBuilder: (BuildContext context2, int i) {
            return Card(child: ListTile(
              title: Text('${_items[i].title!.substring(0, 11)} :   ${_items[i].price} ${_items[i].currency}'),
              subtitle: Text('${_items[i].productId}'),
              trailing: Icon(Icons.payment),
              onTap: () async {
                await FlutterInappPurchase.instance.requestPurchase(_items[i].productId!).then((value) {
                  print(value);
                  // if paid valide, extend the expired date 1 month, season, or year more
                  if (isOK) {
                    DateTime expireDate = DateTime.now().add(Duration(days: i == 0 ? 30 : i == 1 ? 91 : 365));
                    Timestamp expire = Timestamp.fromDate(expireDate);
                    FirebaseFirestore.instance.collection('Golfers').doc(golferDoc).update({
                        "expired": expire
                    });
                    isExpired = false;
                    FlutterInappPurchase.instance.consumeAll();
                  }
                });
              },
            ));
          }
        );
        
      }
    });
}
