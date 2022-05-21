import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class CourseItem {
  const CourseItem(this.cid, this.name, this.photo, this.loc, this.zones, this.doc);
  final int cid;
  final String name;
  final String photo;
  final GeoPoint loc;
  final int zones;
  final Map doc;
  @override
  String toString() => name;
  int toID() => cid;
  double lat() => loc.latitude;
  double lon() => loc.longitude;
}

double square(double a, double b) => (a*a)+(b*b);
late Position _here;
bool granted = false;

Future<bool> locationGranted() {
  return Geolocator.requestPermission().then((value) {
    if (value == LocationPermission.whileInUse || value == LocationPermission.always) {
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) { 
          _here = position; 
          granted = true;          
        });
    }
    return granted;
  });
}

Future<List>? getOrderedCourse() {
  List<CourseItem> theList = []; 
//  _here = GeoPoint(24.8242056,120.9992925);
  return FirebaseFirestore.instance.collection('GolfCourses').get().then((value) {
    value.docs.forEach((result) {
      theList.add(CourseItem(
        result.data()['cid'], 
        result.data()['name'], 
        result.data()['photo'], 
        result.data()['location'], 
        result.data()['zones'].length,
        result.data()
      ));
    });
    if (!granted) _here = Position(longitude: 24.8242056, latitude: 120.9992925, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
    theList.sort((a, b) =>
        ((square(a.lat() - _here.latitude, a.lon() - _here.longitude) -
          square(b.lat() - _here.latitude, b.lon() - _here.longitude))*1000000).toInt());
    return theList;
  });
}