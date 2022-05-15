import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum gendre { Male, Female }
SharedPreferences? prefs;

int uuidTime() {
  return DateTime.now().millisecondsSinceEpoch - 1647000000000;
}

var myGroups = [];
void storeMyGroup() {
  prefs!.setString('golfGroups', jsonEncode(myGroups));
}

void loadMyGroup() {
  myGroups = jsonDecode(prefs!.getString('golfGroups') ?? '[]');
}

var myActivities = [];
void storeMyActivities() {
  prefs!.setString('golfActivities', jsonEncode(myActivities));
}

void loadMyActivities() {
  myActivities = jsonDecode(prefs!.getString('golfActivities') ?? '[]');
}

var myScores = [];
void storeMyScores() {
  while (myScores.length > 30) myScores.removeLast();
  prefs!.setString('golfScores', jsonEncode(myScores));
}

void loadMyScores() {
  myScores = jsonDecode(prefs!.getString('golfScores') ?? '[]');
}

Future<String>? groupName(int gid) {
  var res;
  return FirebaseFirestore.instance.collection('GolferClubs').where('gid', isEqualTo: gid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = items['Name'];
    });
    return res;
  });
}

Future<bool> isMember(int gid, int uid) {
  bool res = false;
  return FirebaseFirestore.instance.collection('GolferClubs').where('gid', isEqualTo: gid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = (items['members'] as List).indexOf(uid) >= 0 ? true : false;
    });
    return res;
  });
}

void addMember(int gid, int uid) {
  FirebaseFirestore.instance.collection('GolferClubs').where('gid', isEqualTo: gid).get().then((value) {
    value.docs.forEach((result) {
      var members = result.data()['members'] as List;
      members.add(uid);
      FirebaseFirestore.instance.collection('GolferClubs').doc(result.id).update({
        'members': members
      });
    });
  });
}

void removeMember(int gid, int uid) {
  FirebaseFirestore.instance.collection('GolferClubs').where('gid', isEqualTo: gid).get().then((value) {
    value.docs.forEach((result) {
      var members = result.data()['members'] as List;
      members.remove(uid);
      FirebaseFirestore.instance.collection('GolferClubs').doc(result.id).update({
        'members': members
      });
    });
  });
}

Future<bool> isManager(int gid, int uid) {
  bool res = false;
  return FirebaseFirestore.instance.collection('GolferClubs').where('gid', isEqualTo: gid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = (items['managers'] as List).indexOf(uid) >= 0 ? true : false;
    });
    return res;
  });
}

void addManager(int gid, int uid) {
  FirebaseFirestore.instance.collection('GolferClubs').where('gid', isEqualTo: gid).get().then((value) {
    value.docs.forEach((result) {
      result.data().update('managers', (value) => (value as List).add(uid));
    });
  });
}

Future<String>? golferName(int uid) {
  var res;
  return FirebaseFirestore.instance.collection('Golfers').where('uid', isEqualTo: uid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = items['name'];
    });
    return res;
  });
}

Future<String>? golferNames(List uids) async {
  String res = '';
  return await FirebaseFirestore.instance.collection('Golfers').where('uid', whereIn: uids).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = (res == '') ? items['name'] : res + ', ' + items['name'];
    });
    return res;
  });
}

Future<Map>? courseBody(int cid) {
  var res;
  return FirebaseFirestore.instance.collection('GolfCourses').where('cid', isEqualTo: cid).get().then((value) {
    value.docs.forEach((result) {
      res = result.data();
    });
    return res;
  });
}

Future<String>? courseName(int cid) {
  var res;
  return FirebaseFirestore.instance.collection('GolfCourses').where('cid', isEqualTo: cid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = items['region'] + ' ' + items['name'];
    });
    return res;
  });
}

Future<String>? coursePhoto(int cid) {
  var res;
  return FirebaseFirestore.instance.collection('GolfCourses').where('cid', isEqualTo: cid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      res = items['photo'];
    });
    return res;
  });
}

Future<int> isApplying(int gid, int uid) {
  int res = 0;
  return FirebaseFirestore.instance.collection('ApplyQueue').where('gid', isEqualTo: gid).where('uid', isEqualTo: uid).get().then((value) {
    value.docs.forEach((result) {
      var items = result.data();
      if (items['response'] == 'waiting')
        res = 1;
      else if (items['response'] == 'No') res = -1;
    });
    return res;
  });
}
