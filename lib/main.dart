//import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dataModel.dart';
import 'createPage.dart';
import 'firebase_options.dart';
import 'locale/language.dart';
import 'locale/app_localizations_delegate.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  prefs = await SharedPreferences.getInstance();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')
      ],
      onGenerateTitle: (context) => Language.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      title: 'Golfer Groups',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
//        accentColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final String maleGolfer = 'https://images.unsplash.com/photo-1494249120761-ea1225b46c05?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=713&q=80';
final String femaleGolfer = 'https://images.unsplash.com/photo-1622819219010-7721328f050b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=415&q=80';
final String drawerCourse = 'https://images.unsplash.com/photo-1622482594949-a2ea0c800edd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80';
final String groupPhoto = 'https://www.csu-emba.com/img/port/22/10.jpg';

String? _golferAvatar;

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;
  int _golferID = 0, _gID = 1;
  String _name = '', _phone = '', _expired = '', _locale ='';
  gendre _sex = gendre.Male;
  double _handicap = 14.2;
  bool isRegistered = false, isUpdate = false, isExpired = false;
  var _golferDoc;

  @override
  void initState() {
    _golferID = prefs!.getInt('golferID') ?? 0;
    _handicap = prefs!.getDouble('handicap') ?? 14.2;
    _expired = prefs!.getString('expired') ?? '';
    loadMyGroup();
    loadMyActivities();
    loadMyScores();
    FirebaseFirestore.instance.collection('Golfers').where('uid', isEqualTo: _golferID).get().then((value) {
      value.docs.forEach((result) {
        _golferDoc = result.id;
        var items = result.data();
        _name = items['name'];
        _phone = items['phone'];
        _locale = items['locale'];
        _sex = items['sex'] == 1 ? gendre.Male : gendre.Female;
        if (_expired == '') {
          _expired = items['expired'].toDate().toString();
          prefs!.setString('expired', _expired);
        }
        isExpired = items['expired'].compareTo(Timestamp.now()) < 0;
        setState(() => isRegistered = true);
        _currentPageIndex = myActivities.length > 0 ? 3 : myGroups.length > 0 ? 2 : 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> appTitle = [
      Language.of(context).golferInfo,
      Language.of(context).groups, //"Groups",
      Language.of(context).myGroup, // "My Groups"
      Language.of(context).activities, //"My Activities",
      Language.of(context).golfCourses, //"Golf courses",
      Language.of(context).myScores, //"My Scores",
      Language.of(context).usage //"Program Usage"
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle[_currentPageIndex]),
      ),
      body: Center(
          child: _currentPageIndex == 0 ? registerBody()
              : _currentPageIndex == 1 ? groupBody()
              : _currentPageIndex == 2 ? myGroupBody()
              : _currentPageIndex == 3  ? activityBody()
              : _currentPageIndex == 4  ? golfCourseBody()
              : _currentPageIndex == 5  ? myScoreBody()
              : usageBody()
      ),
      drawer: isRegistered ? golfDrawer() : null,
      floatingActionButton: (_currentPageIndex == 1)
          ? FloatingActionButton(
              onPressed: () => doBodyAdd(_currentPageIndex),
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Drawer golfDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_name),
            accountEmail: Text(_phone),
            currentAccountPicture: GestureDetector(
                onTap: () {
                  setState(() => isUpdate = true);
                  _currentPageIndex = 0;
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(backgroundImage: NetworkImage(_golferAvatar ?? maleGolfer))),
            decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill, image: NetworkImage(drawerCourse))),
            onDetailsPressed: () {
              setState(() => isUpdate = true);
              _currentPageIndex = 0;
              Navigator.of(context).pop();
            },
          ),
          ListTile(
              title: Text(Language.of(context).groups),
              leading: Icon(Icons.group),
              onTap: () {
                setState(() => _currentPageIndex = 1);
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text(Language.of(context).myGroup),
              leading: Icon(Icons.group),
              onTap: () {
                setState(() => _currentPageIndex = 2);
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text(Language.of(context).activities),
              leading: Icon(Icons.sports_golf),
              onTap: () {
                setState(() => _currentPageIndex = 3);
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text(Language.of(context).golfCourses),
              leading: Icon(Icons.golf_course),
              onTap: () {
                setState(() => _currentPageIndex = 4);
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text(Language.of(context).myScores),
              leading: Icon(Icons.format_list_numbered),
              onTap: () {
                setState(() => _currentPageIndex = 5);
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text(Language.of(context).logOut),
              leading: Icon(Icons.exit_to_app),
              onTap: () {
                setState(() {
                  isRegistered = isUpdate = false;
                  _name = '';
                  _phone = '';
                  _golferID = 0;
                  myGroups.clear();
                  myActivities.clear();
                  myScores.clear();
                });
                _currentPageIndex = 0;
                Navigator.of(context).pop();
              }),
          ListTile(
              title: Text(Language.of(context).usage),
              leading: Icon(Icons.help),
              onTap: () {
                setState(() => _currentPageIndex = 6);
                Navigator.of(context).pop();
              })
        ],
      ),
    );
  }

  Widget usageBody() {
    return FutureBuilder(
        future: FirebaseStorage.instance.ref().child(Language.of(context).helpImage).getDownloadURL(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const CircularProgressIndicator();
          else
            return  InteractiveViewer(
              //panEnabled: false,
                maxScale: 3,
                minScale: 0.8,
                child: Image.network(snapshot.data!.toString())
            );
        });
  }
  ListView registerBody() {
    final logo = Hero(
      tag: 'golfer',
      child: CircleAvatar(backgroundImage: NetworkImage(_golferAvatar ?? maleGolfer), radius: 140),
    );

    Locale myLocale = Localizations.localeOf(context);

    final golferName = TextFormField(
      initialValue: _name,
      showCursor: true,
      onChanged: (String value) => setState(() => _name = value),
      //keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: Language.of(context).name, hintText: Language.of(context).realName, icon: Icon(Icons.person), border: UnderlineInputBorder()),
    );

    final golferPhone = TextFormField(
      initialValue: _phone,
      onChanged: (String value) => setState(() => _phone = value),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(labelText: Language.of(context).mobile, icon: Icon(Icons.phone), border: UnderlineInputBorder()),
    );
    final golferSex = Row(children: <Widget>[
      Flexible(
          child: RadioListTile<gendre>(
              title: Text(Language.of(context).male),
              value: gendre.Male,
              groupValue: _sex,
              onChanged: (gendre? value) => setState(() {
                    _sex = value!;
                    _golferAvatar = maleGolfer;
                  }))),
      Flexible(
          child: RadioListTile<gendre>(
              title: Text(Language.of(context).female),
              value: gendre.Female,
              groupValue: _sex,
              onChanged: (gendre? value) => setState(() {
                    _sex = value!;
                    _golferAvatar = femaleGolfer;
                  }))),
    ], mainAxisAlignment: MainAxisAlignment.center);
    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
            minWidth: 200.0,
            height: 45.0,
            color: Colors.green,
            child: Text(
              isUpdate ? Language.of(context).modify : Language.of(context).register,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            onPressed: () {
              if (isUpdate) {
                if (_name != '' && _phone != '') {
                  FirebaseFirestore.instance.collection('Golfers').doc(_golferDoc).update({
                    "name": _name,
                    "phone": _phone,
                    "sex": _sex == gendre.Male ? 1 : 2,
                  });
                  _currentPageIndex = 1;
                  setState(() => isUpdate = false);
                }
              } else {
                _golferID = 0;
                if (_name != '' && _phone != '') {
                  FirebaseFirestore.instance.collection('Golfers').where('name', isEqualTo: _name).where('phone', isEqualTo: _phone).get().then((value) {
                    value.docs.forEach((result) {
                      var items = result.data();
                      _golferDoc = result.id;
                      _golferID = items['uid'];
                      _locale = items['locale'];
                      _expired = items['expired'].toDate().toString();
                      _sex = items['sex'] == 1 ? gendre.Male : gendre.Female;
                      print(_name + '(' + _phone + ') already registered! ($_golferID)');
                      storeMyGroup();
                      storeMyActivities();
                      storeMyScores();
                    });
                  }).whenComplete(() {
                    if (_golferID == 0) {
                      _golferID = uuidTime();
                      DateTime today = _expired == '' ? DateTime.now() : DateTime.parse(_expired);
                      //DateTime today = DateTime.now();
                      int leap = (today.month == 2 && today.day == 29) ? 1 : 0;
                      Timestamp expire = Timestamp.fromDate(DateTime(
                          _expired == '' ? today.year + 1 : today.year,
                          today.month, today.day - leap));
                      FirebaseFirestore.instance.collection('Golfers').add({
                        "name": _name,
                        "phone": _phone,
                        "sex": _sex == gendre.Male ? 1 : 2,
                        "uid": _golferID,
                        "expired": expire,
                        "locale": myLocale.toString()
                      }).whenComplete(() {
                        if (_expired == '') {
                          _expired = expire.toDate().toString();
                          prefs!.setString('expired', _expired);
                        }
                      });
                    }
                    _currentPageIndex = 1;
                    setState(() => isRegistered = true);
                    prefs!.setInt('golferID', _golferID);
                  });
                }
              }
            }),
      ),
    );
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: <Widget>[
        SizedBox(height: 8.0),
        logo,
        SizedBox(height: 24.0),
        golferName,
        SizedBox(),
        golferPhone,
        SizedBox(height: 8.0),
        golferSex,
        SizedBox(height: 8.0),
        Text(isRegistered ? Language.of(context).handicap + ": " + _handicap.toString().substring(0, min(_handicap.toString().length, 5)) : '', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10.0),
        loginButton
      ],
    );
  }

  Future<bool?> showApplyDialog(int applying) {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Language.of(context).hint),
            content: Text(applying == 1 ? Language.of(context).applyWaiting
                    : applying == 0 ? Language.of(context).applyFirst
                    : Language.of(context).applyRejected),
            actions: <Widget>[
              TextButton(child: Text(applying == 0 ? "Apply" : "OK"), onPressed: () => Navigator.of(context).pop(applying == 0)),
              TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop(false))
            ],
          );
        });
  }
  
  Widget? groupBody() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('GolferClubs').where('gid', whereNotIn: myGroups.length > 0 ? myGroups : [123]).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                if ((doc.data()! as Map)["Name"] == null) {
                  return const LinearProgressIndicator();
                } else {
                  _gID = (doc.data()! as Map)["gid"] as int;
                  if (((doc.data()! as Map)["members"] as List).indexOf(_golferID) >= 0) {
                    if (myGroups.indexOf(_gID) < 0) {
                      myGroups.add(_gID);
                      storeMyGroup();
                      FirebaseFirestore.instance.collection('ApplyQueue').where('uid', isEqualTo: _golferID).where('gid', isEqualTo: _gID).get().then((value) {
                        value.docs.forEach((result) => FirebaseFirestore.instance.collection('ApplyQueue').doc(result.id).delete());
                      });
                    } else if ((doc.data()! as Map)['locale'] != _locale)
                      return SizedBox(height: 1);
                  }
                  return Card(
                      child: ListTile(
                    title: Text((doc.data()! as Map)["Name"], style: TextStyle(fontSize: 20)),
                    subtitle: FutureBuilder(
                        future: golferNames((doc.data()! as Map)["managers"] as List),
                        builder: (context, snapshot2) {
                          if (!snapshot2.hasData)
                            return const LinearProgressIndicator();
                          else
                            return Text(Language.of(context).region + (doc.data()! as Map)["region"] + "\n" + Language.of(context).manager + snapshot2.data!.toString() + "\n" + Language.of(context).members + ((doc.data() as Map)["members"] as List<dynamic>).length.toString());
                        }),
                    leading: Image.network(groupPhoto),
                    /*Icon(Icons.group), */
                    trailing: myGroups.indexOf(_gID) >= 0 ? Icon(Icons.keyboard_arrow_right) : Icon(Icons.no_accounts),
                    onTap: () async {
                      _gID = (doc.data()! as Map)["gid"] as int;
                      if (myGroups.indexOf(_gID) >= 0) {
                        Navigator.push(context, groupActPage(doc, _golferID, _name, _sex, _handicap));
                      } else {
                        bool? apply = await showApplyDialog(await isApplying(_gID, _golferID));
                        if (apply!) {
                          // fill the apply waiting queue
                          FirebaseFirestore.instance.collection('ApplyQueue').add({
                            "uid": _golferID,
                            "gid": _gID,
                            "response": "waiting"
                          }).whenComplete(() => showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(Language.of(context).hint),
                                  content: Text(Language.of(context).applicationSent),
                                  actions: <Widget>[
                                    TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop(true)),
                                  ],
                                );
                              }
                          ));
                        }
                      }
                    },
                    onLongPress: () async {
                      showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(Language.of(context).groupRemarks),
                              content: Text((doc.data()! as Map)["Remarks"]),
                              actions: <Widget>[
                                TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop(true)),
                              ],
                            );
                          });
                    },
                  ));
                }
              }).toList(),
            );
          }
        });
  }

  Widget? myGroupBody() {
    return myGroups.isEmpty
        ? ListView()
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('GolferClubs').where('gid', whereIn: myGroups).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    if ((doc.data()! as Map)["Name"] == null) {
                      return const LinearProgressIndicator();
                    } else {
                      _gID = (doc.data()! as Map)["gid"] as int;
                      if (((doc.data()! as Map)["members"] as List).indexOf(_golferID) < 0) {
                        myGroups.remove(_gID);
                        storeMyGroup();
                        return const LinearProgressIndicator();
                      }
                      return Card(
                          child: ListTile(
                        title: Text((doc.data()! as Map)["Name"], style: TextStyle(fontSize: 20)),
                        subtitle: FutureBuilder(
                            future: golferNames((doc.data()! as Map)["managers"] as List),
                            builder: (context, snapshot2) {
                              if (!snapshot2.hasData)
                                return const LinearProgressIndicator();
                              else
                                return Text(Language.of(context).region + (doc.data()! as Map)["region"] + "\n" + Language.of(context).manager + snapshot2.data!.toString() + "\n" + Language.of(context).members + ((doc.data() as Map)["members"] as List<dynamic>).length.toString());
                            }),
                        leading: Image.network("https://www.csu-emba.com/img/port/22/10.jpg"),
                        /*Icon(Icons.group), */
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          _gID = (doc.data()! as Map)["gid"] as int;
                          Navigator.push(context, groupActPage(doc, _golferID, _name, _sex, _handicap));
                        },
                        onLongPress: () {
                          _gID = (doc.data()! as Map)["gid"] as int;
                          if (((doc.data()! as Map)["managers"] as List).indexOf(_golferID) >= 0) {
                            // modify group info
                            Navigator.push(context, editGroupPage(doc, _golferID));
                          } else {
                            showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text((doc.data()! as Map)["Name"]),
                                    content: Text(Language.of(context).quitGroup),
                                    actions: <Widget>[
                                      TextButton(child: Text("Yes"), onPressed: () => Navigator.of(context).pop(true)),
                                      TextButton(child: Text("No"), onPressed: () => Navigator.of(context).pop(false))
                                    ],
                                  );
                                }).then((value) {
                              if (value!) {
                                removeMember(_gID, _golferID);
                                myGroups.remove(_gID);
                                storeMyGroup();
                                setState(() {});
                              }
                            });
                          }
                        },
                      ));
                    }
                  }).toList(),
                );
              }
            });
  }

  Widget activityBody() {
    Timestamp deadline = Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
    var allActivities = [];
    return myActivities.isEmpty
        ? ListView()
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('ClubActivities').orderBy('teeOff').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else {
                return ListView(
                    children: snapshot.data!.docs.map((doc) {
                  if ((doc.data()! as Map)["teeOff"] == null) {
                    return LinearProgressIndicator();
                  } else if (myActivities.indexOf(doc.id) < 0) {
                    return SizedBox(height: 0.1,);
                  } else if ((doc.data()! as Map)["teeOff"].compareTo(deadline) < 0) {
                    myActivities.remove(doc.id);
                    storeMyActivities();
                    return LinearProgressIndicator();
                  } else {
                    allActivities.add(doc.id);
                    return Card(
                        child: ListTile(
                            title: FutureBuilder(
                                future: courseName((doc.data()! as Map)['cid'] as int),
                                builder: (context, snapshot2) {
                                  if (!snapshot2.hasData)
                                    return const LinearProgressIndicator();
                                  else
                                    return Text(snapshot2.data!.toString(), style: TextStyle(fontSize: 20));
                                }),
                            subtitle: Text(Language.of(context).teeOff + ((doc.data()! as Map)['teeOff']).toDate().toString().substring(0, 16) + '\n' + Language.of(context).max + (doc.data()! as Map)['max'].toString() + '\t' + Language.of(context).now + ((doc.data()! as Map)['golfers'] as List).length.toString() + "\t" + Language.of(context).fee + (doc.data()! as Map)['fee'].toString()),
                            leading: FutureBuilder(
                                future: coursePhoto((doc.data()! as Map)['cid'] as int),
                                builder: (context, snapshot3) {
                                  if (!snapshot3.hasData)
                                    return const CircularProgressIndicator();
                                  else
                                    return Image.network(snapshot3.data!.toString(), fit: BoxFit.fitHeight);
                                }),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () async {
                              Navigator.push(context, showActivityPage(doc, _golferID, await groupName((doc.data()! as Map)['gid'] as int)!, await isManager((doc.data()! as Map)['gid'] as int, _golferID), _handicap)).then((value) async {
                                var glist = doc.get('golfers');
                                if (value == -1) {
                                  myActivities.remove(doc.id);
                                  storeMyActivities();
                                  glist.removeWhere((item) => item['uid'] == _golferID);
                                  FirebaseFirestore.instance.collection('ClubActivities').doc(doc.id).update({
                                    'golfers': glist
                                  });
                                  setState(() {});
                                } else if ((value == 0) && (myActivities.length != allActivities.length)) {
                                  myActivities = allActivities;
                                  storeMyActivities();
                                }
                              });
                            }));
                  }
                }).toList());
              }
            });
  }

  Widget? golfCourseBody() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('GolfCourses').orderBy('region').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          } else {
            return ListView(
                children: snapshot.data!.docs.map((doc) {
              if ((doc.data()! as Map)["photo"] == null) {
                return LinearProgressIndicator();
              } else {
                return Card(
                    child: ListTile(
                  leading: Image.network((doc.data()! as Map)["photo"]),
                  title: Text((doc.data()! as Map)["region"] + ' ' + (doc.data()! as Map)["name"], style: TextStyle(fontSize: 18)),
                  subtitle: Text((((doc.data()! as Map)["zones"]).length * 9).toString() + ' Holes'),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    if (((doc.data()! as Map)["zones"]).length > 2) {
                      List zones = await selectZones(context, doc.data()! as Map);
                      if (zones.isNotEmpty) Navigator.push(context, newScorePage(doc.data()! as Map, _name, zone0: zones[0], zone1: zones[1]));
                    } else
                      Navigator.push(context, newScorePage(doc.data()! as Map, _name));
                  },
                ));
              }
            }).toList());
          }
        });
  }

  ListView myScoreBody() {
    int cnt = myScores.length > 10 ? 10 : myScores.length;
    _handicap = 0;

    return ListView.builder(
      itemCount: myScores.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int i) {
        if (i < cnt) _handicap += myScores[i]['handicap'];
        if ((i + 1) == cnt) {
          _handicap = (_handicap / cnt) * 0.9;
          prefs!.setDouble('handicap', _handicap);
        }
        return ListTile(
            leading: CircleAvatar(child: Text(myScores[i]['total'].toString())),
            title: Text(myScores[i]['date'] + ' ' + myScores[i]['course'], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(myScores[i]['pars'].toString() + '\n' + myScores[i]['scores'].toString())
        );
      },
    );
  }

  void doBodyAdd(int index) async {
    switch (index) {
      case 1:
        Navigator.push(context, newGroupPage(_golferID, _locale)).then((ret) {
          if (ret ?? false) setState(() => index = 1);
        });
        break;
      case 4:
        Navigator.push(context, newGolfCoursePage()).then((ret) {
          if (ret ?? false) setState(() => index = 4);
        });
        break;
    }
  }
}
