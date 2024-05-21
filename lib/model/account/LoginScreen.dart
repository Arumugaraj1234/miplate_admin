import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miplate/model/Hotel.dart';
import 'package:miplate/model/base/Constants.dart';
import 'package:miplate/model/base/HexColor.dart';
import 'package:miplate/model/base/ShowProgressDialogScreen.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final Hotel hotel;
  @override
  LoginScreenState createState() => LoginScreenState();

  LoginScreen({this.hotel});
}

class LoginScreenState extends State<LoginScreen> {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  Hotel hotel = new Hotel();

  LoginScreenState();

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      if (widget.hotel != null &&
          widget.hotel.hotel_id != null &&
          widget.hotel.hotel_id > 0) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DashboardScreen(widget.hotel),
            ));

        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => DashboardScreen(hotel),
        //   ),
        // );
      }
    });
  }

  void _submitLogin() {
    hotel.phone_no = emailController.text;
    hotel.password = passwordController.text;
    if (isValid()) {
      FocusScope.of(context).requestFocus(new FocusNode());
      _makePostRequest();
    }
  }

  bool isValid() {
    if (hotel.phone_no == null || hotel.phone_no.isEmpty) {
      _showSnackBar("Please enter phone number", false);
      return false;
    } else if (hotel.password == null || hotel.password.isEmpty) {
      _showSnackBar("Please enter Password", false);
      return false;
    }
    return true;
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _makePostRequest() async {
    print('Hi Login called');
    //ShowProgressDialogScreen.showLoading("Loading", true, context);
    String url = Constants.BASE_URL + '/Login';
    var response =
        await http.post(url, body: json.encode(_$TeachersToJson()), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });

    if (response != null && response.body.isNotEmpty) {
      String responseData = response.body;
      var jsonData = jsonDecode(responseData);

      dynamic loginResponse = jsonData['Data'];
      if (loginResponse != null && loginResponse['hotel_id'] != null) {
        hotel.hotel_id = loginResponse['hotel_id'];
        hotel.address = loginResponse['address'];
        hotel.phone_no = loginResponse['phone_no'];
        hotel.flg = loginResponse['flg'];
        hotel.icon = loginResponse['icon'];
        hotel.name = 'Gurkha Falmouth';
        // ShowProgressDialogScreen.showLoading("Loading", false, context);
        _showSnackBar("Logged In Successfully...", true);
        _saveTeacher(hotel);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => DashboardScreen(widget.hotel),
            ));
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //      builder: (BuildContext context) => DashboardScreen(hotel)));
      } else {
        _showSnackBar("Log in failed , Error occured", false);
        //  ShowProgressDialogScreen.showLoading("Please wait...", false, context);
      }
    } else {
      _showSnackBar("Log in failed , Please check Email/Password", false);
      // ShowProgressDialogScreen.showLoading("Please wait...", false, context);
    }
  }

  _saveTeacher(Hotel hotel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', hotel.hotel_id);
    await prefs.setString('address', hotel.address);
    await prefs.setString('name', hotel.name);
    await prefs.setString('phone_no', hotel.phone_no);
    await prefs.setInt('flg', hotel.flg);
    await prefs.setString('icon', hotel.icon);
  }

  Map<String, dynamic> _$TeachersToJson() => <String, dynamic>{
        "phone_no": hotel.phone_no,
        "password": hotel.password,
      };

  void _showSnackBar(String text, bool isFailed) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: !isFailed ? Colors.red : Colors.green,
        content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    var loginForm = new Column(
      children: <Widget>[
        /*Text('Welcome to Gurkha Falmouth',
            softWrap: true,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: HexColor('#1a2f46'),
                fontSize: 20,
                fontFamily: 'Avenir Next',
                fontWeight: FontWeight.w700)),*/

        // Container(
        //     margin: const EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
        //     height: 30.0,
        //     width: 30.0,
        //     color: Colors.blue,
        //     child: Image.asset(
        //       'assets/images/logo.png',
        //       height: 30.0,
        //       width: 30.0,
        //       fit: BoxFit.cover,
        //     )),
        new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  controller: emailController,
                  decoration: new InputDecoration(
                      prefixIcon: Icon(Icons.email, color: HexColor("#a9b2c8")),
                      contentPadding: const EdgeInsets.all(10.0),
                      border: new OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor("#a9b2c8")),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      labelText: "Mobile No",
                      hintStyle: TextStyle(
                          fontFamily: 'Roboto Regular',
                          fontWeight: FontWeight.w400)),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: new InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: HexColor("#a9b2c8")),
                      contentPadding: const EdgeInsets.all(10.0),
                      border: new OutlineInputBorder(
                        borderSide: BorderSide(color: HexColor("#a9b2c8")),
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      labelText: "Password",
                      hintStyle: TextStyle(
                          fontFamily: 'Roboto Regular',
                          fontWeight: FontWeight.w400)),
                ),
              ),
              Container(
                  height: 50,
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0.0, 15.0, 0, 0),
                  child: FlatButton(
                    color: HexColor('#22b6f3'),
                    onPressed: _submitLogin,
                    child: new Text("Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Avenir Next',
                            fontWeight: FontWeight.w500)),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: HexColor('#22b6f3'),
                        )),
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(15, 20, 15, 15),
                  child: GestureDetector(
                    onTap: () {
                      print('Hi');
                      const url =
                          'http://64.15.141.244/Gurkha/Portal/Home/Forgot';
                      launchURL(url);
                    },
                    child: Text('Forgot Password?',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: HexColor('#1a2f46'),
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                            fontFamily: 'Avenir Next',
                            fontWeight: FontWeight.w600)),
                  )),
              /* Container(
                  height: 50,
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0.0, 15.0, 0, 0),
                  child: FlatButton(
                    color: HexColor('#ff7c51'),
                    onPressed: _submitLogin,
                    child: new Text("Login via OTP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Avenir Next',
                            fontWeight: FontWeight.w500)),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: HexColor('#ff7c51'),
                        )),
                  )),*/
            ],
          ),
        ),
        //_isLoading ? new CircularProgressIndicator() : loginBtn
      ],
    );

    return Scaffold(
        key: scaffoldKey,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.fromLTRB(40.0, 60.0, 40.0, 20.0),
                    child: new Image.asset(
                      'assets/images/logo.png',
                      height: 150.0,
                      width: 150.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  new Container(
                    child: loginForm,
                    width: 300.0,
                    decoration:
                        new BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  )
                ],
              ),
            )));
  }
}
