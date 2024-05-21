import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/account/LoginScreen.dart';
import 'package:miplate/screens/DashboardScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Hotel.dart';
import 'model/base/HexColor.dart';
import 'model/base/ShowProgressDialogScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DataServices>(
      create: (_) {
        return DataServices();
      },
      child: MaterialApp(
        title: 'Gurkha Falmouth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Hotel hotel = new Hotel();

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getHotel();
  }

  Future<Hotel> getHotel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hotel.hotel_id = prefs.getInt('id');
    hotel.address = prefs.getString('address');
    hotel.name = prefs.getString('name');
    Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen(
              hotel: hotel,
            );
          },
          settings: RouteSettings(name: 'Login'),
        ),
      );
    });

    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //       builder: (BuildContext context) => LoginScreen(
    //             hotel: hotel,
    //           ),
    //       settings: RouteSettings(name: 'Login')),
    // );

    // if (hotel != null && hotel.hotel_id != null && hotel.hotel_id > 0) {
    //    Timer(
    //       Duration(seconds: 3),
    //       () => Navigator.of(context).pushReplacement(MaterialPageRoute(
    //           builder: (BuildContext context) => DashboardScreen(hotel))));
    // } else {
    //   Timer(
    //       Duration(seconds: 3),
    //       () => Navigator.of(context).pushReplacement(MaterialPageRoute(
    //           builder: (BuildContext context) => LoginScreen())));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Image.asset(
                "assets/images/logo.png",
                height: 150.0,
                width: 150.0,
              ),
              new Text('Gurkha Falmouth',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                      color: HexColor("#1a2f46"),
                      fontSize: 20,
                      fontFamily: 'Avenir Next',
                      fontWeight: FontWeight.w700)),
              new Text('',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(
                      color: HexColor("#1a2f46"),
                      fontSize: 16,
                      fontFamily: 'Roboto Regular',
                      fontWeight: FontWeight.w500))
            ],
          ),
        ),
      ),
    );
  }
}
