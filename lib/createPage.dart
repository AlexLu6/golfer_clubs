//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:editable/editable.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charcode/charcode.dart';
import 'dataModel.dart';
import 'editable2.dart';
import 'locale/language.dart';

_NewGroupPage newGroupPage(int golferID) {
  return _NewGroupPage(golferID);
}

class _NewGroupPage extends MaterialPageRoute<bool> {
  _NewGroupPage(int golferID)
      : super(builder: (BuildContext context) {
          String _groupName = '', _region = '', _remarks = '';
          return Scaffold(
              appBar: AppBar(title: Text(Language.of(context).createNewGolfGroup), elevation: 1.0),
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  TextFormField(
                    showCursor: true,
                    onChanged: (String value) => setState(() => _groupName = value),
                    //keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: Language.of(context).groupName, icon: Icon(Icons.group), border: UnderlineInputBorder()),
                  ),
                  TextFormField(
                    showCursor: true,
                    onChanged: (String value) => setState(() => _region = value),
                    //keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: Language.of(context).groupActRegion, icon: Icon(Icons.place), border: UnderlineInputBorder()),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    showCursor: true,
                    onChanged: (String value) => setState(() => _remarks = value),
                    //keyboardType: TextInputType.name,
                    maxLines: 5,
                    decoration: InputDecoration(labelText: Language.of(context).groupRemarks, icon: Icon(Icons.edit_note), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                      child: Text(Language.of(context).create, style: TextStyle(fontSize: 24)),
                      onPressed: () {
                        int gID = uuidTime();
                        if (_groupName != '' && _region != '') {
                          FirebaseFirestore.instance.collection('GolferClubs').add({
                            "Name": _groupName,
                            "region": _region,
                            "Remarks": _remarks,
                            "managers": [golferID],
                            "members": [golferID],
                            "gid": gID
                          });
                          myGroups.add(gID);
                          storeMyGroup();
                          Navigator.of(context).pop(true);
                        }
                      })
                ]);
              }));
        });
}

_EditGroupPage editGroupPage(var groupDoc, int uID) {
  return _EditGroupPage(groupDoc, uID);
}

class _EditGroupPage extends MaterialPageRoute<bool> {
  _EditGroupPage(var groupDoc, int uID)
      : super(builder: (BuildContext context) {
          List<NameID> golfers = [];
          var _selectedGolfer;
          String _groupName = (groupDoc.data()! as Map)['Name'], _region = (groupDoc.data()! as Map)['region'], _remarks = (groupDoc.data()! as Map)['Remarks'];

          var blist = (groupDoc.data()! as Map)['members'] as List;

          if (golfers.isEmpty) {
            FirebaseFirestore.instance.collection('Golfers').where('uid', whereIn: blist).get().then((value) {
              value.docs.forEach((result) {
                var items = result.data();
                if (((groupDoc.data()! as Map)['managers'] as List).indexOf(items['uid'] as int) < 0)
                  golfers.add(NameID(items['name'] + '(' + items['phone'] + ')',
                      items['uid'] as int));
              });
            });
          }

          return Scaffold(
              appBar: AppBar(title: Text(Language.of(context).modify + ' ' + (groupDoc.data()! as Map)['Name']), elevation: 1.0),
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  TextFormField(
                    showCursor: true,
                    initialValue: (groupDoc.data()! as Map)['Name'],
                    onChanged: (String value) => setState(() => _groupName = value),
                    //keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: Language.of(context).groupName, icon: Icon(Icons.group), border: UnderlineInputBorder()),
                  ),
                  TextFormField(
                    showCursor: true,
                    initialValue: (groupDoc.data()! as Map)['region'],
                    onChanged: (String value) => setState(() => _region = value),
                    //keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: Language.of(context).groupActRegion, icon: Icon(Icons.place), border: UnderlineInputBorder()),
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    showCursor: true,
                    initialValue: (groupDoc.data()! as Map)['Remarks'],
                    onChanged: (String value) => setState(() => _remarks = value),
                    maxLines: 5,
                    decoration: InputDecoration(labelText: Language.of(context).groupRemarks, icon: Icon(Icons.edit_note), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12.0),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    const SizedBox(width: 5),
                    ElevatedButton(
                        child: Text(Language.of(context).modify, style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          if (_groupName != '' && _region != '') {
                            FirebaseFirestore.instance.collection('GolferClubs').doc(groupDoc.id).update({
                              "Name": _groupName,
                              "region": _region,
                              "Remarks": _remarks,
                            });
                            Navigator.of(context).pop(true);
                          }
                        }),
                    const SizedBox(width: 5),
                    ElevatedButton(
                        child: Text(Language.of(context).addManager, style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          showMaterialScrollPicker<NameID>(
                            context: context,
                            title: Language.of(context).selectManager,
                            items: golfers,
                            showDivider: false,
                            selectedItem: golfers[0],
                            onChanged: (value) => setState(() => _selectedGolfer = value),
                          ).then((value) {
                            if (_selectedGolfer != null) {
                              var mlist = (groupDoc.data()! as Map)['managers'] as List;
                              if (mlist.indexOf(_selectedGolfer.toID()) < 0) {
                                mlist.add(_selectedGolfer.toID());
                                FirebaseFirestore.instance.collection('GolferClubs').doc(groupDoc.id).update({
                                  'managers': mlist
                                });
                              }
                              Navigator.of(context).pop(true);
                            }
                          });
                        }),
                    const SizedBox(width: 5),
                    ElevatedButton(
                        child: Text(Language.of(context).kickMember, style: TextStyle(fontSize: 18)),
                        onPressed: () {
                          showMaterialScrollPicker<NameID>(
                            context: context,
                            title: Language.of(context).selectKickMember,
                            items: golfers,
                            showDivider: false,
                            selectedItem: golfers[0],
                            onChanged: (value) => setState(() => _selectedGolfer = value),
                          ).then((value) {
                            if (_selectedGolfer != null) {
                              var mlist = (groupDoc.data()! as Map)['managers'] as List;
                              if (mlist.indexOf(_selectedGolfer.toID()) < 0) {
                                blist.remove(_selectedGolfer.toID());
                                FirebaseFirestore.instance.collection('GolferClubs').doc(groupDoc.id).update({
                                  'members': blist
                                });
                              }
                              Navigator.of(context).pop(true);
                            }
                          });
                        }),
          //        ]),
                  const SizedBox(width: 5),
                  ((groupDoc.data()! as Map)['managers'] as List).length == 1
                      ? const SizedBox(width: 5)
                      : ElevatedButton(
                          child: Text(Language.of(context).quitManager, style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            var mlist = (groupDoc.data()! as Map)['managers'] as List;
                            mlist.remove(uID);
                            FirebaseFirestore.instance.collection('GolferClubs').doc(groupDoc.id).update({
                              'managers': mlist
                            });
                            Navigator.of(context).pop(true);
                          }),
                  ]),
                ]);
              }));
        });
}

class NameID {
  const NameID(this.name, this.id);
  final String name;
  final int id;
  @override
  String toString() => name;
  int toID() => id;
}

List<NameID> coursesItems = [];

_NewActivityPage newActivityPage(bool isMan, int gid, int uid) {
  return _NewActivityPage(isMan, gid, uid);
}

class _NewActivityPage extends MaterialPageRoute<bool> {
  _NewActivityPage(bool isMan, int gid, int uid)
      : super(builder: (BuildContext context) {
          String _courseName = '', _remarks = '';
          var _selectedCourse;
          DateTime _selectedDate = DateTime.now();
          bool _includeMe = true;
          int _fee = 2500, _max = 4;
          var activity = FirebaseFirestore.instance.collection('ClubActivities');

          if (coursesItems.isEmpty)
            FirebaseFirestore.instance.collection('GolfCourses').orderBy('region').get().then((value) {
              value.docs.forEach((result) {
                var items = result.data();
                coursesItems.add(NameID(items['name'] as String, items['cid'] as int));
              });
            });

          return Scaffold(
              appBar: AppBar(title: Text(Language.of(context).createNewActivity), elevation: 1.0),
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  const SizedBox(height: 12.0),
                  Flexible(
                      child: Row(children: <Widget>[
                    ElevatedButton(
                        child: Text(Language.of(context).golfCourses),
                        onPressed: () {
                          showMaterialScrollPicker<NameID>(
                            context: context,
                            title: Language.of(context).selectCourse,
                            items: coursesItems,
                            showDivider: false,
                            selectedItem: coursesItems[0], //_selectedCourse,
                            onChanged: (value) => setState(() => _selectedCourse = value),
                          ).then((value) => setState(() => _courseName = value == null ? '' : value.toString()));
                        }),
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _courseName,
                      key: Key(_courseName),
                      showCursor: true,
                      onChanged: (String value) => setState(() => print(_courseName = value)),
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(labelText: Language.of(context).courseName, border: UnderlineInputBorder()),
                    )),
                    const SizedBox(width: 5)
                  ])),
                  const SizedBox(height: 12),
                  Flexible(
                      child: Row(children: <Widget>[
                    ElevatedButton(
                        child: Text(Language.of(context).teeOff),
                        onPressed: () {
                          showMaterialDatePicker(
                            context: context,
                            title: Language.of(context).pickDate,
                            selectedDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 180)),
                            //onChanged: (value) => setState(() => _selectedDate = value),
                          ).then((date) {
                            if (date != null) showMaterialTimePicker(context: context, title: Language.of(context).pickTime, selectedTime: TimeOfDay.now()).then((time) => setState(() => print(_selectedDate = DateTime(date.year, date.month, date.day, time!.hour, time.minute))));
                          });
                        }),
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _selectedDate.toString().substring(0, 16),
                      key: Key(_selectedDate.toString().substring(0, 16)),
                      showCursor: true,
                      onChanged: (String? value) => _selectedDate = DateTime.parse(value!),
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(labelText: Language.of(context).teeOffTime, border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: 5)
                  ])),
                  const SizedBox(height: 12),
                  Flexible(
                      child: Row(children: <Widget>[
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _max.toString(),
                      showCursor: true,
                      onChanged: (String value) => setState(() => _max = int.parse(value)),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: Language.of(context).max, icon: Icon(Icons.group), border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _fee.toString(),
                      showCursor: true,
                      onChanged: (String value) => setState(() => _fee = int.parse(value)),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: Language.of(context).fee, icon: Icon(Icons.money), border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: 5)
                  ])),
                  const SizedBox(height: 12),
                  TextFormField(
                    showCursor: true,
                    initialValue: _remarks,
                    onChanged: (String value) => setState(() => _remarks = value),
                    //keyboardType: TextInputType.name,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: Language.of(context).actRemarks, icon: Icon(Icons.edit_note), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                      child: Row(children: <Widget>[
                    const SizedBox(width: 5),
                    Checkbox(value: _includeMe, onChanged: (bool? value) => setState(() => _includeMe = value!)),
                    const SizedBox(width: 5),
                    const Text('Include myself')
                  ])),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      child: Text(Language.of(context).create, style: TextStyle(fontSize: 24)),
                      onPressed: () async {
                        var name = await golferName(uid);
                        if (_courseName != '') {
                          activity.add({
                            'gid': gid,
                            "cid": _selectedCourse.toID(),
                            "teeOff": Timestamp.fromDate(_selectedDate),
                            "max": _max,
                            "fee": _fee,
                            "remarks": _remarks,
                            'subgroups': [],
                            "golfers": _includeMe ? [{"uid": uid, "name": name, "scores": []}] : []
                          }).then((value) {
                            if (_includeMe) {
                              myActivities.add(value.id);
                              storeMyActivities();
                            }
                            Navigator.of(context).pop(true);
                          });
                        }
                      })
                ]);
              }));
        });
}

class _EditActivityPage extends MaterialPageRoute<bool> {
  _EditActivityPage(var actDoc, String _courseName)
      : super(builder: (BuildContext context) {
          String _remarks = (actDoc.data()! as Map)['remarks'];
          int _fee = (actDoc.data()! as Map)['fee'], _max = (actDoc.data()! as Map)['max'];
          DateTime _selectedDate = (actDoc.data()! as Map)['teeOff'].toDate();

          return Scaffold(
              appBar: AppBar(title: Text(Language.of(context).editActivity), elevation: 1.0),
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  const SizedBox(height: 12),
                  Text(Language.of(context).courseName + _courseName, style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 12),
                  Flexible(
                      child: Row(children: <Widget>[
                    ElevatedButton(
                        child: Text(Language.of(context).teeOff),
                        onPressed: () {
                          showMaterialDatePicker(
                            context: context,
                            title: Language.of(context).pickDate,
                            selectedDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 180)),
                            //onChanged: (value) => setState(() => _selectedDate = value),
                          ).then((date) {
                            if (date != null) showMaterialTimePicker(context: context, title: Language.of(context).pickTime, selectedTime: TimeOfDay.now()).then((time) => setState(() => print(_selectedDate = DateTime(date.year, date.month, date.day, time!.hour, time.minute))));
                          });
                        }),
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _selectedDate.toString().substring(0, 16),
                      key: Key(_selectedDate.toString().substring(0, 16)),
                      showCursor: true,
                      onChanged: (String? value) => _selectedDate = DateTime.parse(value!),
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(labelText: Language.of(context).teeOffTime, border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: 5)
                  ])),
                  const SizedBox(height: 12),
                  Flexible(
                      child: Row(children: <Widget>[
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _max.toString(),
                      showCursor: true,
                      onChanged: (String value) => _max = int.parse(value),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: Language.of(context).max, icon: Icon(Icons.group), border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: 5),
                    Flexible(
                        child: TextFormField(
                      initialValue: _fee.toString(),
                      showCursor: true,
                      onChanged: (String value) => _fee = int.parse(value),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: Language.of(context).fee, icon: Icon(Icons.money), border: OutlineInputBorder()),
                    )),
                    const SizedBox(width: 5)
                  ])),
                  const SizedBox(height: 12),
                  TextFormField(
                    showCursor: true,
                    initialValue: _remarks,
                    onChanged: (String value) => _remarks = value,
                    //keyboardType: TextInputType.name,
                    maxLines: 3,
                    decoration: InputDecoration(labelText: Language.of(context).actRemarks, icon: Icon(Icons.edit_note), border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                      child: Text(Language.of(context).modify, style: TextStyle(fontSize: 24)),
                      onPressed: () async {
                        FirebaseFirestore.instance.collection('ClubActivities').doc(actDoc.id).update({
                          "teeOff": Timestamp.fromDate(_selectedDate),
                          "max": _max,
                          "fee": _fee,
                          "remarks": _remarks,
                        }).then((value) {
                          Navigator.of(context).pop(true);
                        });
                      })
                ]);
              }));
        });
}

_NewGolfCoursePage newGolfCoursePage() {
  return _NewGolfCoursePage();
}

class _NewGolfCoursePage extends MaterialPageRoute<bool> {
  _NewGolfCoursePage()
      : super(builder: (BuildContext context) {
          String _courseName = '', _region = '', _photoURL = '';
          double _lat = 0, _lon = 0;
          var _courseZones = [];
          //         List<AutocompletePrediction>? predictions = [];
//          GooglePlace googlePlace = GooglePlace('AIzaSyD26EyAImrDoOMn3o6FgmSQjlttxjqmS7U');

          saveZone(var row) {
            print(row);
            _courseZones.add({
              'name': row['zoName'],
              'holes': [row['h1'], row['h2'], row['h3'], row['h4'], row['h5'], row['h6'], row['h7'], row['h8'], row['h9']],
            });
          }

          return Scaffold(
            appBar: AppBar(title: Text(Language.of(context).createNewCourse), elevation: 1.0),
            body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
              return Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                TextFormField(
                  showCursor: true,
                  onChanged: (String value) => _courseName = value,
                  //keyboardType: TextInputType.name,
                  decoration: InputDecoration(labelText: Language.of(context).courseName, icon: Icon(Icons.golf_course), border: UnderlineInputBorder()),
                ),
                TextFormField(
                  showCursor: true,
                  onChanged: (String value) => _region = value,
                  decoration: InputDecoration(labelText: "Region:", icon: Icon(Icons.place), border: UnderlineInputBorder()),
                ),
                TextFormField(
                  showCursor: true,
                  onChanged: (String value) {
                    int i;
                    for (i = 0; value[i] != ','; i++) {}
                    _lat = double.parse(value.substring(0, i - 1));
                    _lon = double.parse(value.substring(i + 1));
                  },
                  decoration: InputDecoration(labelText: "Location:", icon: Icon(Icons.place), border: UnderlineInputBorder()),
                ),
                TextFormField(
                  showCursor: true,
                  onChanged: (String value) => _photoURL = value,
                  //keyboardType: TextInputType.name,
                  decoration: InputDecoration(labelText: "Photo URL:", icon: Icon(Icons.photo), border: UnderlineInputBorder()),
                ),
                SizedBox(height: 10),
                Flexible(
                    child: Editable(
                  borderColor: Colors.black,
                  tdStyle: TextStyle(fontSize: 16),
                  trHeight: 16,
                  tdAlignment: TextAlign.center,
                  thAlignment: TextAlign.center,
                  showSaveIcon: true,
                  saveIcon: Icons.save,
                  saveIconColor: Colors.blue,
                  onRowSaved: (row) => saveZone(row),
                  showCreateButton: true,
                  createButtonLabel: Text('Add zone'),
                  createButtonIcon: Icon(Icons.add),
                  createButtonColor: Colors.blue,
                  columnRatio: 0.15,
                  columns: [
                    {"title": "Zone", 'index': 1, 'key': 'zoName'},
                    {"title": "1", 'index': 2, 'key': 'h1'},
                    {"title": "2", 'index': 3, 'key': 'h2'},
                    {"title": "3", 'index': 4, 'key': 'h3'},
                    {"title": "4", 'index': 5, 'key': 'h4'},
                    {"title": "5", 'index': 6, 'key': 'h5'},
                    {"title": "6", 'index': 7, 'key': 'h6'},
                    {"title": "7", 'index': 8, 'key': 'h7'},
                    {"title": "8", 'index': 9, 'key': 'h8'},
                    {"title": "9", 'index': 10, 'key': 'h9'}
                  ],
                  rows: [
                    {'zoName': 'Ou',
                      'h1': '',
                      'h2': '',
                      'h3': '',
                      'h4': '',
                      'h5': '',
                      'h6': '',
                      'h7': '',
                      'h8': '',
                      'h9': ''
                    },
                    {'zoName': 'I',
                      'h1': '',
                      'h2': '',
                      'h3': '',
                      'h4': '',
                      'h5': '',
                      'h6': '',
                      'h7': '',
                      'h8': '',
                      'h9': ''
                    },
                  ],
                )),
                const SizedBox(height: 16.0),
                ElevatedButton(
                    child: Text(Language.of(context).create, style: TextStyle(fontSize: 24)),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('GolfCourses').add({
                        "cid": uuidTime(),
                        "name": _courseName,
                        "region": _region,
                        "photo": _photoURL,
                        "zones": _courseZones,
                        "location": GeoPoint(_lat, _lon),
                      });
                      Navigator.of(context).pop(true);
                    }),
              ]);
            }),
          );
        });
}

class SubGroupPage extends MaterialPageRoute<bool> {
  SubGroupPage(var activity, int uId)
      : super(builder: (BuildContext context) {
          var subGroups = activity.data()!['subgroups'] as List;
          int max = ((activity.data()!['golfers'] as List).length + 3) >> 2;
          List<List<int>> subIntGroups = [
            []
          ];

          void storeAndLeave() {
            var newGroups = [];
            for (int i = 0; i < subIntGroups.length; i++) {
              Map subMap = {};
              for (int j = 0; j < subIntGroups[i].length; j++) subMap[j.toString()] = subIntGroups[i][j];
              newGroups.add(subMap);
              subMap.clear();
            }
            FirebaseFirestore.instance.collection('ClubActivities').doc(activity.id).update({
              'subgroups': newGroups
            });
            Navigator.of(context).pop(true);
          }

          int alreadyIn = -1;
          for (int i = 0; i < subGroups.length; i++) {
            for (int j = 0; j < (subGroups[i] as Map).length; j++) {
              subIntGroups[i].add((subGroups[i] as Map)[j.toString()]);
              if (subIntGroups[i][j] == uId) alreadyIn = i;
            }
          }
          if (subIntGroups[subIntGroups.length - 1].length > 0 && subIntGroups[subIntGroups.length - 1].length < max && alreadyIn < 0) subIntGroups.add([]);

          return Scaffold(
              appBar: AppBar(title: Text(Language.of(context).subGroup), elevation: 1.0),
              body: ListView.builder(
                  itemCount: subIntGroups.length,
                  padding: const EdgeInsets.all(10.0),
                  itemBuilder: (BuildContext context, int i) {
                    bool isfull = subIntGroups[i].length == 4;
                    return ListTile(
                      leading: CircleAvatar(
                          child: Text(String.fromCharCodes([
                        $A + i
                      ]))),
                      title: subIntGroups[i].length == 0
                          ? Text(Language.of(context).name)
                          : FutureBuilder(
                              future: golferNames(subIntGroups[i]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return const LinearProgressIndicator();
                                else
                                  return Text(Language.of(context).name + snapshot.data!.toString(), style: TextStyle(fontWeight: FontWeight.bold));
                              }),
                      trailing: (alreadyIn == i) ? Icon(Icons.remove, color: Colors.red,)
                              : (!isfull && alreadyIn < 0) ? Icon(Icons.add, color: Colors.blue,)
                              : Icon(Icons.stop, color: Colors.grey),
                      onTap: () {
                        if (alreadyIn == i) {
                          subIntGroups[i].remove(uId);
                          if (subIntGroups[i].length == 0) subIntGroups.removeAt(i);
                          storeAndLeave();
                        } else if (!isfull && alreadyIn < 0) {
                          subIntGroups[i].add(uId);
                          storeAndLeave();
                        }
                      },
                    );
                  }));
        });
}

ShowActivityPage showActivityPage(var activity, int uId, String title, bool editable, double handicap) {
  return ShowActivityPage(activity, uId, title, editable, handicap);
}

class ShowActivityPage extends MaterialPageRoute<int> {
  ShowActivityPage(var activity, int uId, String title, bool editable, double handicap)
      : super(builder: (BuildContext context) {
          bool alreadyIn = false, scoreReady = false, scoreDone = false;
          String uName = '';
          int uIdx = 0;
          var rows = [];

          List buildRows() {
            var oneRow = {};
            int idx = 0;

            for (var e in activity.data()!['golfers']) {
              if (idx % 4 == 0) {
                oneRow = Map();
                if (idx >= (activity.data()!['max'] as int))
                  oneRow['row'] = Language.of(context).waiting;
                else
                  oneRow['row'] = (idx >> 2) + 1;
                oneRow['c1'] = e['name'];
                oneRow['c2'] = '';
                oneRow['c3'] = '';
                oneRow['c4'] = '';
              } else if (idx % 4 == 1)
                oneRow['c2'] = e['name'];
              else if (idx % 4 == 2)
                oneRow['c3'] = e['name'];
              else if (idx % 4 == 3) {
                oneRow['c4'] = e['name'];
                rows.add(oneRow);
              }
              if (e['uid'] as int == uId) {
                alreadyIn = true;
                uName = e['name'];
                uIdx = idx;
                if (myActivities.indexOf(activity.id) < 0) {
                  myActivities.add(activity.id);
                  storeMyActivities();
                }
              }
              if ((e['scores'] as List).length > 0)
                scoreReady = true;
              idx++;
              if (idx == (activity.data()!['max'] as int)) {
                if (idx % 4 != 0)
                  rows.add(oneRow);
                while (idx % 4 != 0) idx++;
              }
            }
            if ((idx % 4) != 0)
              rows.add(oneRow);
            else if (idx == 0) {
              oneRow['c1'] = oneRow['c2'] = oneRow['c3'] = oneRow['c4'] = '';
              rows.add(oneRow);
            }

            return rows;
          }

          List buildScoreRows() {
            var scoreRows = [];
            int idx = 1, i=0;

            for (var e in activity.data()!['golfers']) {

              if ((e['scores'] as List).length > 0) {
                if (uIdx == i) scoreDone = true;
                scoreRows.add({
                  'rank': idx,
                  'total': e['total'],
                  'name': e['name'],
                  'net': e['net']
                });
                idx++;
              }
              i++;
            }
            print(scoreRows);
            scoreRows.sort((a, b) => a['total'] - b['total']);
            // bubble sort rank
/*            for (int i = 0; i < scoreRows.length; i++)
              for (int j = i + 1; j < scoreRows.length; j++) {
                if ((scoreRows[i]['total'] > scoreRows[j]['total']) || (scoreRows[i]['total'] == scoreRows[j]['total'] && scoreRows[i]['net'] > scoreRows[j]['net'])) {
                  var tt = scoreRows[i]['total'];
                  var nn = scoreRows[i]['name'];
                  var ee = scoreRows[i]['net'];
                  scoreRows[i]['total'] = scoreRows[j]['total'];
                  scoreRows[i]['name'] = scoreRows[j]['name'];
                  scoreRows[i]['net'] = scoreRows[j]['net'];
                  scoreRows[j]['total'] = tt;
                  scoreRows[j]['name'] = nn;
                  scoreRows[j]['net'] = ee;
                }
              }*/
            return scoreRows;
          }

          bool teeOffPass = activity.data()!['teeOff'].compareTo(Timestamp.now()) < 0;
          Map course = {};
          void updateScore() {
            print('updateScore');
            FirebaseFirestore.instance.collection('ClubActivities').doc(activity.id).get().then((value) {
              var glist = value.get('golfers');
              glist[uIdx]['scores'] = myScores[0]['scores'];
              glist[uIdx]['total'] = myScores[0]['total'];
              glist[uIdx]['net'] = myScores[0]['total'] - handicap;
              FirebaseFirestore.instance.collection('ClubActivities').doc(activity.id).update({
                'golfers': glist
              });
            });
          }

          return Scaffold(
              appBar: AppBar(title: Text(title), elevation: 1.0),
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  const SizedBox(height: 16.0),
                  Text(Language.of(context).teeOff + activity.data()!['teeOff'].toDate().toString().substring(0, 16) + '\t' + Language.of(context).fee + activity.data()!['fee'].toString(), style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16.0),
                  FutureBuilder(
                      future: courseBody(activity.data()!['cid'] as int),
                      builder: (context, snapshot2) {
                        if (!snapshot2.hasData)
                          return const LinearProgressIndicator();
                        else {
                          course = snapshot2.data! as Map;
                          return Text(course['name'] + "\t" + Language.of(context).max + activity.data()!['max'].toString(), style: TextStyle(fontSize: 20));
                        }
                      }),
                  const SizedBox(height: 16.0),
                  Flexible(
                      child: Editable(
                    borderColor: Colors.black,
                    tdStyle: TextStyle(fontSize: 16),
                    trHeight: 16,
                    tdAlignment: TextAlign.center,
                    thAlignment: TextAlign.center,
                    columnRatio: 0.2,
                    columns: [
                      {"title": Language.of(context).tableGroup, 'index': 1, 'key': 'row', 'editable': false, 'widthFactor': 0.14},
                      {"title": "A", 'index': 2, 'key': 'c1', 'editable': false},
                      {"title": "B", 'index': 3, 'key': 'c2', 'editable': false},
                      {"title": "C", 'index': 4, 'key': 'c3', 'editable': false},
                      {"title": "D", 'index': 5, 'key': 'c4', 'editable': false}
                    ],
                    rows: buildRows(),
                  )),
                  ((activity.data()!['golfers'] as List).length < 5) || !alreadyIn || scoreReady
                      ? const SizedBox(height: 10.0)
                      : ElevatedButton(
                          child: Text(Language.of(context).subGroup),
                          onPressed: () {
                            Navigator.push(context, SubGroupPage(activity, uId)).then((value) {
                              if (value ?? false) Navigator.of(context).pop(0);
                            });
                          }),
                  const SizedBox(height: 16.0),
                  !scoreReady ? const SizedBox(height: 10.0)
                      : Flexible(
                          child: Editable(
                          borderColor: Colors.black,
                          tdStyle: TextStyle(fontSize: 16),
                          trHeight: 16,
                          tdAlignment: TextAlign.center,
                          thAlignment: TextAlign.center,
                          columnRatio: 0.14,
                          columns: [
                            {'title': Language.of(context).rank, 'index': 1, 'key': 'rank', 'editable': false},
                            {'title': Language.of(context).total, 'index': 2, 'key': 'total', 'editable': false},
                            {'title': Language.of(context).name, 'index': 3, 'key': 'name', 'editable': false, 'widthFactor': 0.25},
                            {'title': Language.of(context).net, 'index': 4, 'key': 'net', 'editable': false}
                          ],
                          rows: buildScoreRows(),
                        )),
                      (teeOffPass && !alreadyIn) || scoreDone ?
                      const SizedBox(height: 10.0)
                      : ElevatedButton(
                          child: Text(teeOffPass && alreadyIn && !scoreDone ? Language.of(context).enterScore
                                                  : alreadyIn ? Language.of(context).cancel : Language.of(context).apply),
                          onPressed: () async {
                            if (teeOffPass && alreadyIn) {
                              if ((course["zones"]).length > 2) {
                                List zones = await selectZones(context, course);
                                if (zones.isNotEmpty)
                                  Navigator.push(context, newScorePage(course, uName, zone0: zones[0], zone1: zones[1])).then((value) {
                                    if (value ?? false) updateScore();
                                  });
                              } else {
                                Navigator.push(context, newScorePage(course, uName)).then((value) {
                                  if (value ?? false) updateScore();
                                });
                              }
                            } else {
                              Navigator.of(context).pop(teeOffPass ? 0 : alreadyIn ? -1 : 1);
                            }
                          }),
                  const SizedBox(height: 16.0),
                  Text(Language.of(context).actRemarks + activity.data()!['remarks']),
                  const SizedBox(height: 16.0)
                ]));
              }),
              floatingActionButton: editable
                  ? FloatingActionButton(
                      onPressed: () {
                        // modify activity info
                        Navigator.push(context, _EditActivityPage(activity, course['name'])).then((value) {
                          if (value ?? false) Navigator.of(context).pop(0);
                        });
                      },
                      child: const Icon(Icons.edit),
                    )
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop);
        });
}

Future<List> selectZones(BuildContext context, Map course, {int zone0 = 0, int zone1 = 1}) {
  bool? _zone0 = true, _zone1 = true, _zone2 = false, _zone3 = false;
  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(Language.of(context).select2Courses),
            actions: [
              CheckboxListTile(
                  value: _zone0,
                  title: Text(course["zones"][0]['name']),
                  onChanged: (bool? value) {
                    setState(() => _zone0 = value);
                  }),
              CheckboxListTile(
                  value: _zone1,
                  title: Text(course["zones"][1]['name']),
                  onChanged: (bool? value) {
                    setState(() => _zone1 = value);
                  }),
              CheckboxListTile(
                  value: _zone2,
                  title: Text(course["zones"][2]['name']),
                  onChanged: (bool? value) {
                    setState(() => _zone2 = value);
                  }),
              (course["zones"]).length == 3
                  ? SizedBox(height: 6)
                  : CheckboxListTile(
                      value: _zone3,
                      title: Text(course["zones"][3]['name']),
                      onChanged: (bool? value) {
                        setState(() => _zone3 = value);
                      }),
              Row(children: [
                TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop(true)),
                TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop(false))
              ])
            ],
          );
        });
      }).then((value) {
    int zone0, zone1;
    zone0 = _zone0! ? 0 : _zone1! ? 1 : 2;
    zone1 = _zone3! ? 3 : _zone2! ? 2 : 1;
    if (value)
      return [zone0, zone1];
    return [];
  });
}

_NewScorePage newScorePage(Map course, String golfer, {int zone0 = 0, int zone1 = 1}) {
  return _NewScorePage(course, golfer, zone0, zone1);
}

class _NewScorePage extends MaterialPageRoute<bool> {
  _NewScorePage(Map course, String golfer, int zone0, int zone1)
      : super(builder: (BuildContext context) {
          final _editableKey = GlobalKey<Editable2State>();
          var columns = [
            {'title': 'Out', 'index': 0, 'key': 'zone1', 'editable': false},
            {'title': "Par", 'index': 1, 'key': 'par1', 'editable': false},
            {'title': " ", 'index': 2, 'key': 'score1'},
            {'title': 'In', 'index': 3, 'key': 'zone2', 'editable': false},
            {'title': "Par", 'index': 4, 'key': 'par2', 'editable': false},
            {'title': " ", 'index': 5, 'key': 'score2'}
          ];
          var rows = [
            {'zone1': '1', 'par1': '4', 'score1': '', 'zone2': '10', 'par2': '4', 'score2': ''},
            {'zone1': '2', 'par1': '4', 'score1': '', 'zone2': '11', 'par2': '4', 'score2': ''},
            {'zone1': '3', 'par1': '4', 'score1': '', 'zone2': '12', 'par2': '4', 'score2': ''},
            {'zone1': '4', 'par1': '4', 'score1': '', 'zone2': '13', 'par2': '4', 'score2': ''},
            {'zone1': '5', 'par1': '4', 'score1': '', 'zone2': '14', 'par2': '4', 'score2': ''},
            {'zone1': '6', 'par1': '4', 'score1': '', 'zone2': '15', 'par2': '4', 'score2': ''},
            {'zone1': '7', 'par1': '4', 'score1': '', 'zone2': '16', 'par2': '4', 'score2': ''},
            {'zone1': '8', 'par1': '4', 'score1': '', 'zone2': '17', 'par2': '4', 'score2': ''},
            {'zone1': '9', 'par1': '4', 'score1': '', 'zone2': '18', 'par2': '4', 'score2': ''},
            {'zone1': 'Sum', 'par1': '', 'score1': '', 'zone2': 'Sum', 'par2': '4', 'score2': ''}
          ];
          List<int> pars = List.filled(18, 0), scores = List.filled(18, 0);
          int sum1 = 0, sum2 = 0;
          int tpars = 0;
          List buildColumns() {
            columns[0]['title'] = course['zones'][zone0]['name'];
            columns[3]['title'] = course['zones'][zone1]['name'];
            return columns;
          }

          List buildRows() {
            int idx = 0, sum = 0;
            tpars = 0;
            (course['zones'][zone0]['holes']).forEach((par) {
              rows[idx]['par1'] = par.toString();
              sum += int.parse(par);
              pars[idx] = int.parse(par);
              tpars += pars[idx];
              idx++;
            });
            rows[idx]['par1'] = sum.toString();
            idx = sum = 0;
            (course['zones'][zone1]['holes']).forEach((par) {
              rows[idx]['par2'] = par.toString();
              sum += int.parse(par);
              pars[idx + 9] = int.parse(par);
              tpars += pars[idx];
              idx++;
            });
            rows[idx]['par2'] = sum.toString();
            return rows;
          }

          return Scaffold(
              appBar: AppBar(title: Text(Language.of(context).enterScore), elevation: 1.0),
              body: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                return Container(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  const SizedBox(height: 16.0),
                  Text('Name: ' + golfer, style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16.0),
                  Text('Course: ' + course['region'] + ' ' + course['name'], style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16.0),
                  Flexible(
                      child: Editable2(
                          key: _editableKey,
                          borderColor: Colors.black,
                          tdStyle: TextStyle(fontSize: 16),
                          trHeight: 16,
                          tdAlignment: TextAlign.center,
                          thAlignment: TextAlign.center,
                          columnRatio: 0.16,
                          columns: buildColumns(),
                          rows: buildRows(),
                          onSubmitted: (value) {
                            sum1 = sum2 = 0;
                            _editableKey.currentState!.editedRows.forEach((element) {
                              if (element['row'] != 9) {
                                sum1 += int.parse(element['score1'] ?? '0');
                                sum2 += int.parse(element['score2'] ?? '0');
                                scores[element['row']] = int.parse(element['score1'] ?? '0');
                                scores[element['row'] + 9] = int.parse(element['score2'] ?? '0');
                              }
                            });
                            setState(() {});
                          })),
                      Text(Language.of(context).scoreNote, style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 6.0),
                  (sum1 + sum2) == 0 ? const SizedBox(height: 6.0) : Text(Language.of(context).total + ': ' + (sum1 + sum2).toString(), style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16.0),
                  Center(
                      child: ElevatedButton(
                          child: Text(Language.of(context).store, style: TextStyle(fontSize: 24)),
                          onPressed: () {
                            bool complete = scores.length > 0;
                            scores.forEach((element) {
                              if (element == 0) complete = false;
                            });
                            if (complete) {
                              myScores.insert(0, {
                                'date': DateTime.now().toString().substring(0, 16),
                                'course': course['name'] + (course['zones'].length > 2 ? '(${course['zones'][zone0]['name']}, ${course['zones'][zone1]['name']})' : ''),
                                'pars': pars,
                                'scores': scores,
                                'total': sum1 + sum2,
                                'handicap': (sum1 + sum2) - tpars > 0 ? (sum1 + sum2) - tpars : 0
                              });
                              storeMyScores();
                              Navigator.of(context).pop(true);
                            }
                          })),
                  const SizedBox(height: 6.0)
                ]));
              }));
        });
}
