import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:solutionschamp/String_values.dart';
import 'package:solutionschamp/Screens/Dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() =>LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isHidden = true;
  bool loading=false;
  String   errortextemail;
  String   errortextpass;

  bool validateE=false;

  bool validateP =false;
  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
  Future<http.Response> postRequest() async {
    setState(() {
      loading = true;
    });
    var url = String_values.base_url + 'login.php';
    Map data = {

      "username": emailController.text,
      "password": passwordController.text
    };
    print("data: ${data}");
    print(String_values.base_url);
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
    if(response.body.replaceAll('"',"")!="failed")

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => Dashboard(username:response.body.replaceAll('"', ""))),
            (Route<dynamic> route) => false,
      );

    else
      showDialog(context: context,child: AlertDialog(
        backgroundColor:  String_values.base_color,
        title: Text("Incorrect Login Details ",style: TextStyle(color: Colors.white),),
        content: Text("Please check your username or email and password",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
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
  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  static TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(

      body: loading?Center(child: CircularProgressIndicator()):SingleChildScrollView(


        child: SafeArea(
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   color: Colors.white,
              //   height: height/20,
              //
              // ),
              new Container(
                //
                // padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration( boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ], color: Colors.white,borderRadius: BorderRadius.only(bottomRight: Radius.circular(80))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('logo.png',width: width/2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(child:SizedBox(width: width/3,),flex: 1,),
                        Flexible(
                          flex:1,
                          child: Padding(
                            padding: const EdgeInsets.only(top:25),
                            child: Text("Technologies Pvt Ltd",textAlign: TextAlign.end,style:TextStyle(color:String_values.base_color,fontWeight: FontWeight.w800,fontSize: 17) ,),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                width: width,
                height: height/3,

              ),

              SizedBox(
                height: height/15,
              ),
              buildTextField("Email"),
              SizedBox(
                height: height/50,
              ),
              buildTextField("Password"),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right:24.0),
                        child: InkWell(
                          child: Container(
                            padding:const EdgeInsets.all(16.0),
                            child: Text("Forgot Password?"),
                          ),
                          onTap: (){

                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height/30,),
              SizedBox(height: height/30,),

              ButtonContainer(),


              SizedBox(
                height: height/30,
              ),
              Container(
                child: Center(
                  child: InkWell(
                    onTap: (){

                    },
                    child: Container(
                      padding:const EdgeInsets.all(16.0),
                      child: Text("Create an Account",style: TextStyle(color: String_values.base_color,fontWeight: FontWeight.w600),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hintText)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: hintText=="Email"?emailController:passwordController,
        keyboardType: TextInputType.emailAddress,
        onTap: () {
          setState(() {
            hintText=="Email"?
            errortextemail = null:errortextpass=null;
          });
        },
        decoration: InputDecoration(
          errorText:  hintText=="Email"?validateE ? errortextemail : null:validateP ? errortextpass : null,
          prefixIcon: hintText=="Email"?Icon(Icons.email):Icon(Icons.lock),
          labelText: hintText=="Email"?hintText+" or Username":hintText,
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 16.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),

          suffixIcon: hintText == "Password"
              ? IconButton(
            onPressed: _toggleVisibility,
            icon: _isHidden
                ? Icon(Icons.visibility_off)
                : Icon(Icons.visibility),
          )
              : null,
        ),
        obscureText: hintText == "Password" ? _isHidden : false,
      ),
    );
  }

  Widget ButtonContainer() {
    return Container(
        width: MediaQuery.of(context).size.width/1.5,
        height: 50,
        child: FlatButton(
          child: Text('Login'),
          color: String_values.base_color,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomRight:Radius.circular(30),topLeft: Radius.circular(30) ),
          ),
          onPressed: () {
            setState(() {

              if (emailController.text.trim().isNotEmpty) {
                validateE = false;
              } else {
                validateE = true;
                errortextemail = "Email cannot be empty";
              }
              if (passwordController.text.isEmpty ||
                  passwordController.text.trim().length < 4) {
                if (passwordController.text.isEmpty)
                  errortextpass = "Password cannot be empty";
                else
                  errortextpass = "Password should be minimum of 4 characters";
                validateP = true;
              } else
                validateP = false;


              if (
              validateE == false &&
                  validateP == false)                check().then((value) {
                if(value)
                  postRequest();
                else
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("No Internet Connection"),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
              });
            });

          },
        ));
  }
}

