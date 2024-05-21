import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:miplate/CategoryListScreen.dart';
import 'package:miplate/DishListScreen.dart';
import 'package:miplate/TimeListScreen.dart';
import 'package:miplate/model/Hotel.dart';
import 'package:miplate/screens/history_screen.dart';
import 'package:miplate/screens/order_type_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDrawer extends StatelessWidget {
  final Hotel hotel;
  final int switchValue;
  final Function onSwitchChanged;
  MainDrawer({this.hotel, this.switchValue, this.onSwitchChanged});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Container(
                    alignment: Alignment.center,
                    //margin: EdgeInsets.all(10),
                    child: Text("Gurkha Falmouth",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Avenir Next',
                            fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  /*  new Container(
                    alignment: Alignment.center,
                    //margin: EdgeInsets.all(10),
                    child: Text(hotel.address ?? '',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Avenir Next',
                            fontWeight: FontWeight.w500)),
                  ),*/
                  // CustomSwitch(
                  //     activeColor: Colors.pinkAccent,
                  //     value: switchValue == 0 ? false : true,
                  //     onChanged: onSwitchChanged),
                  new Container(
                    height: 25,
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform(
                          transform: new Matrix4.identity()..scale(1.2),
                          child: new CustomSwitch(
                              activeColor: Colors.black,
                              value: switchValue == 0 ? false : true,
                              onChanged: onSwitchChanged),
                        ),
                        // Container(
                        //   margin: EdgeInsets.all(5),
                        //   child: Text(switchValue == 0 ? 'Offline' : 'Online',
                        //       textAlign: TextAlign.left,
                        //       style: TextStyle(
                        //           color: Colors.white,
                        //           fontSize: 20,
                        //           fontFamily: 'Avenir Next',
                        //           fontWeight: FontWeight.w500)),
                        // )
                      ],
                    ),
                  ),
                ]),
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Current Orders'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.category),
                    title: Text('Categories'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return CategoryListScreen(hotel);
                        }),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.fastfood),
                    title: Text('Dishes'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return DishListScreen(hotel);
                        }),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Time'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return TimingsListScreen(hotel);
                        }),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.table_chart),
                    title: Text('Order Type'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return OrderTypeScreen();
                        }),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.library_books),
                    title: Text('History'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return HistoryScreen();
                        }),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.assignment_return_rounded),
                    title: Text('Logout'),
                    onTap: () async {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return WillPopScope(
                              onWillPop: () {},
                              child: new AlertDialog(
                                title: new Text('Logout!'),
                                content:
                                    new Text('Are you sure you want logout?'),
                                actions: <Widget>[
                                  new FlatButton(
                                    onPressed: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setInt('id', null);
                                      await prefs.setString('address', null);
                                      await prefs.setString('name', null);
                                      await prefs.setString('phone_no', null);
                                      await prefs.setInt('flg', null);
                                      await prefs.setString('icon', null);
                                      //Navigator.pop(context);
                                      Navigator.of(context).popUntil(
                                          ModalRoute.withName("Login"));
                                    },
                                    child: new Text('Yes'),
                                  ),
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: new Text('No'),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
