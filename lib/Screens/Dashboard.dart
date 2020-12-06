import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:solutionschamp/Screens/Login.dart';
import 'package:solutionschamp/Screens/MapScreen.dart';
import 'package:solutionschamp/String_values.dart';
class Dashboard extends StatefulWidget {
  Dashboard({Key key,this.username});
  String username;
  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
{

  bool loading = false;
  void initState() {
Future.delayed(Duration(milliseconds: 1)).then((value) =>
        showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor:  String_values.base_color,
              title: Text("Welcome",style: TextStyle(color: Colors.white),),
              content: Text(widget.username,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
              actions: <Widget>[
                TextButton(
                  child: Text('OK',style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );}));

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      //backgroundColor: Colors.redAccent[100],
      body: Container(
        color:Colors.grey.shade200,
        padding: EdgeInsets.all(18),
        child: GridView.count(
          crossAxisCount: 3,
          children: <Widget>[
            Card(
              elevation: 5.0,
              // color: Colors.redAccent[100],
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MapScreen(username: widget.username,)));
                },
                splashColor: String_values.base_color,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.location_history,
                        size: 35.0,color: String_values.base_color,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "Location Details",
                        style: new TextStyle(fontSize: 10.0),
                      )
                    ],
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
appBar: AppBar(
  backgroundColor: Colors.grey.shade100,
  title: Image.asset("logo.png",width: width/3),
  centerTitle: true,
  iconTheme: IconThemeData(color: String_values.base_color),

),

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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}