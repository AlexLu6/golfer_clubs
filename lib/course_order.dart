import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class CourseItem {
  const CourseItem(this.cid, this.name, this.photo, this.loc, this.zones);
  final int cid;
  final String name;
  final String photo;
  final GeoPoint loc;
  final int zones;
  @override
  String toString() => name;
  int toID() => cid;
  double lat() => loc.latitude;
  double lon() => loc.longitude;
}

double square(double a, double b) => (a*a)+(b*b);

Future<List>? getOrderedCourse() {
  List<CourseItem> theList = [];
/*  late Position _here;
  Geolocator.requestPermission().then((value) {
    if (value == LocationPermission.whileInUse || value == LocationPermission.always)
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
            _here = position;
            print(_here);
      });
  });*/ GeoPoint _here = GeoPoint(24.8242056,120.9992925);
  FirebaseFirestore.instance.collection('GolfCourses').get().then((value) {
    value.docs.forEach((result) {
      theList.add(CourseItem(
        result.data()['cid'], 
        result.data()['name'], 
        result.data()['photo'], 
        result.data()['location'], 
        result.data()['zones'].length
      ));
    });
  }).whenComplete(() {
    theList.sort((a, b) =>
      ((square(a.lat() - _here.latitude, a.lon() - _here.longitude) -
        square(b.lat() - _here.latitude, b.lon() - _here.longitude))*1000000).toInt()
    );
    print(theList);
    return theList;
  });
}