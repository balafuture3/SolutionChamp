import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solutionschamp/Screens/Login.dart';
import 'package:solutionschamp/String_values.dart';

class MapScreen extends StatefulWidget {
  MapScreen({Key key, this.username});
  String username;
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

  Completer<GoogleMapController> _controller = Completer();
  var _kGooglePlex;
   Marker marker ;
  String imei;
  int cnt=0;
  Set<Marker> markers = Set();
  Position position;
  TextEditingController NameController = new TextEditingController();
  var loading=false;
 bool textcheck=false;
  Future<http.Response> postRequest() async {
    cnt++;
    setState(() {
      loading = true;
    });
    var url = String_values.base_url + 'icon_name_imei_add.php';
    Map data = {

      "query": "insert",
      "imei":cnt.toString(),
      "icon":"Bus",
      "username":widget.username
    };
    print("data: ${data}");
    print(url);
    //encode Map to JSON
    //   var body = json.encode(data);
    //   print("response: ${body}");
    var response = await http.post(url,
        headers: {
          //  "Content-Type": "application/json",
          //   'Authorization':
          //       'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1aWQiOiIxIiwidXR5cGUiOiJFTVAifQ.AhfTPvo5C_rCMIexbUd1u6SEoHkQCjt3I7DVDLwrzUs'
          //
        },
        body: data);
    if (response.statusCode == 200)
    {
      setState(() {
        loading = false;
      });

        showDialog(context: context,child: AlertDialog(
          backgroundColor:  String_values.base_color,
          content: Text(response.body.replaceAll('"',""),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
          actions: <Widget>[
            TextButton(
              child: Text('OK',style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));

    } else {
      setState(() {
        loading = false;
      });
      print("Retry");
    }
    print("response: ${response.statusCode}");
    print("response: ${response.body}");
    return response;
  }
  void initState() {
   // getimei().then((value) =>  getlocation());
    getlocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading?Center(child: CircularProgressIndicator()):Container(
          child: GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller)
            {
              _controller.complete(controller);
            },
            markers: markers,

          )),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Image.asset("logo.png",width: MediaQuery.of(context).size.width/3),
        centerTitle: true,
        iconTheme: IconThemeData(color: String_values.base_color),

      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(context: context,child: StatefulBuilder(builder: (context, StateSetter setState) {
         return AlertDialog(

              title: Text("Add/Edit Device"),
          content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.only(left:10.0,right:10),
            child: Text("Enter Device Name",style: TextStyle(color:String_values.base_color,fontWeight: FontWeight.w600),),
          ),
          Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0,top: 10),
          child: Container(
          child: new TextField(

          controller:NameController,
          onTap: (){
            setState(()
            {
              textcheck=false;
            });
          },
          decoration: InputDecoration(
          labelText: 'Device Name',
                        errorText: textcheck?"Device Name Cannot be Empty":null,
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if((NameController.text.length!=0))
                  {
                    setState(()
                    {
                      textcheck=false;
                    });
                    Navigator.of(context).pop();
                    postRequest();


                  }
                else
                  {
                    setState(()
                    {
                      textcheck=true;
                    });

                  }

              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );}));

      },child: Icon(Icons.add,size: 25,),),
      drawer: Drawer(


        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Welcome"),
              accountEmail: Text(widget.username),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(widget.username.substring(0,1),
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),

            ListTile(
              title: Text("Logout"),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('seen', false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),);
  }

  // Future<void> getimei() async {
  // //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // //   setState(() {
  // //     loading=true;
  // //   });
  // //   AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
  // // print(androidDeviceInfo);
  // }
  Future<void> getlocation() async {
    setState(() {
      loading=true;
    });
    imei = await ImeiPlugin.getImei();
    // List<String> multiImei = await ImeiPlugin.getImeiMulti(); //for double-triple SIM phones
    // String uuid = await ImeiPlugin.getId();
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    marker= Marker(
    markerId: MarkerId("fdg"),
    position: LatLng(position.latitude, position.longitude
    ),);

    setState(() {
      markers.add(marker);
      _kGooglePlex = CameraPosition( target: LatLng(position.latitude, position.longitude),zoom: 16);
     
     loading=false; //    print("Markers "+markers.length.toString());
    });
  }
}