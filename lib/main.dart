import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MapApp(),
    );
  }
}

class MapApp extends StatefulWidget {
  @override
  _MapAppState createState() => new _MapAppState();
}

class _MapAppState extends State<MapApp> {

  LocationData locationData;
  Location location = new Location();
  // LatLng loc;

  @override
  void initState() {
    super.initState();
    preLoc();
    getLoc();
    // Future(() async {
    //   loc = await getLoc();
    // });
    }



  Future<void> preLoc() async {


    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
  Future<LatLng> getLoc() async{
    locationData = await location.getLocation();
    //todo:緯度経度を円の中心に設定するために非同期処理を使う。これを勉強　https://dart.dev/codelabs/async-await
    print("location is... ${locationData.latitude}");
    return LatLng(locationData.latitude, locationData.longitude);



  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
      future: getLoc(),
      builder: (context, AsyncSnapshot<LatLng> snapshot){
        if (snapshot.hasData) {

          return FlutterMap(
            options: MapOptions(
              center: snapshot.data,
              zoom: 13.0,
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']
              ),
              CircleLayerOptions(
                circles: [
                  CircleMarker(
                    color: Colors.yellow.withOpacity(0.7),
                    radius: 100,
                    borderColor: Colors.white.withOpacity(0.9),
                    borderStrokeWidth: 2,
                    //todo:LocationDataをLatlngに変換して円の中心に設定
                    point: snapshot.data,
                    // point: LatLng(51.5, -0.09),
                    useRadiusInMeter: true,
                  ),

                ],
              ),
            ],
          );
        }
        else {
          return CircularProgressIndicator();
        }
      }
    );



  }
}
