import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miplate/model/Timings.dart';
import 'package:miplate/model/base/ShowProgressDialogScreen.dart';
import 'package:miplate/screens/update_timing_screen.dart';

import 'model/Hotel.dart';
import 'model/base/Constants.dart';
import 'model/base/HexColor.dart';

class TimingsListScreen extends StatefulWidget {
  Hotel hotel;

  TimingsListScreen(this.hotel);

  @override
  TimingsScreenState createState() => TimingsScreenState(hotel);
}

class TimingsScreenState extends State<TimingsListScreen> {
  Hotel hotel;

  TimingsScreenState(this.hotel);

  List<Map> questionsList = new List();
  List<Timings> timingsList = List();
  List<Map> categoryListSelected = List();

  bool selectAll = false;
  String selectText = "Select all";
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void onPageVisible() {}

  @override
  void initState() {
    super.initState();
    fetchTimings();
  }

  Future<List<Timings>> fetchTimings() async {
    // ShowProgressDialogScreen.showLoading("Loading", true, context);
    String url = Constants.BASE_URL + '/GetTimings';
    try {
      var response =
          await http.post(url, body: json.encode(_$categoryToJson()), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });
      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      List<dynamic> disheListResponse = jsonData['Data'];
      for (var res in disheListResponse) {
        Timings timings = new Timings();
        timings.hotel_id = res['hotel_id'];
        timings.name = res['name'];
        timings.flg = res['flg'];
        timings.meal_id = res['meal_id'];
        timings.created_user_id = res['created_user_id'];
        timings.created_date = res['created_date'];
        timings.selected = false;
        timings.start_time = res['start_time'];
        timings.end_time = res['end_time'];
        timingsList.add(timings);
      }
      //ShowProgressDialogScreen.showLoading("Loading", false, context);
      setState(() {
        timingsList;
      });

      return timingsList;
    } catch (error) {
      // ShowProgressDialogScreen.showLoading("Loading", false, context);
      print(error);
    }
  }

  void ItemChange(bool val, int index) {
    setState(() {
      if (index == -1) {
        for (var i = 0; i < timingsList.length; i++) {
          if (selectAll) {
            timingsList[i].selected = true;
          } else {
            timingsList[i].selected = false;
          }
        }
      } else {
        timingsList[index].selected = val;
        if (val == true) {
          timingsList[index].flg = 1;
        } else {
          timingsList[index].flg = 0;
        }

        changeStatus(timingsList[index]);
      }
    });
  }

  Map<String, dynamic> _$categoryToJson() => <String, dynamic>{
        "hotel_id": 1,
      };

  Future<Timings> changeStatus(Timings timings) async {
    // ShowProgressDialogScreen.showLoading("Loading", true, context);
    String url = Constants.BASE_URL + '/ChangeStatus';
    try {
      var response = await http.post(url,
          body: json.encode(_$TimingsChangeStatusToJson(timings)),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      // ShowProgressDialogScreen.showLoading("Loading", false, context);
      _showSnackBar(jsonData['Message']);
    } catch (error) {
      print(error);
      //ShowProgressDialogScreen.showLoading("Loading", false, context);
    }
  }

  void sendToUpdateTimeScreen(Timings timings) async {
    Timings tim = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return UpdateTimingScreen(
          timings: timings,
        );
      }),
    );
    if (tim != null) {
      int flg;
      for (var i = 0; i < timingsList.length; i++) {
        Timings t = timingsList[i];
        if (t.name == tim.name) {
          flg = i;
          break;
        }
      }
      if (flg != null) {
        setState(() {
          timingsList[flg] = tim;
        });
      }
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: Colors.green, content: new Text(text)));
  }

  Map<String, dynamic> _$TimingsChangeStatusToJson(Timings timings) =>
      <String, dynamic>{
        "id": timings.meal_id,
        "status": timings.flg,
        "tablename": "meals"
      };

  @override
  Widget build(BuildContext context) {
    var listviewBuilder = ListView.builder(
        itemCount: timingsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              // color: HexColor("#f7f6f8"),
              margin: EdgeInsets.fromLTRB(10, 5, 15, 0),
              child: Container(
                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                  decoration: BoxDecoration(
                    color: HexColor("#ffffff"),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      new Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              sendToUpdateTimeScreen(timingsList[index]);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) {
                              //     return UpdateTimingScreen(
                              //       timings: timingsList[index],
                              //     );
                              //   }),
                              // );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(timingsList[index].name,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: HexColor("#1a2f46"),
                                          fontFamily: 'Roboto Regular',
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          )),
                      new Expanded(
                          flex: 5,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                    height: 20,
                                    width: double.infinity,
                                    margin: EdgeInsets.fromLTRB(0.0, 2.0, 2, 2),
                                    child: FlatButton(
                                      color: Colors.black,
                                      onPressed: () {
                                        sendToUpdateTimeScreen(
                                            timingsList[index]);
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) {
                                        //     return UpdateTimingScreen(
                                        //       timings: timingsList[index],
                                        //     );
                                        //   }),
                                        // );
                                      },
                                      child: new Text(
                                          "Start Time : " +
                                              timingsList[index].start_time,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Avenir Next',
                                              fontWeight: FontWeight.w400)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(4.0),
                                      ),
                                    )),
                                Container(
                                    height: 20,
                                    width: double.infinity,
                                    margin: EdgeInsets.fromLTRB(0.0, 2.0, 2, 2),
                                    child: FlatButton(
                                      color: Colors.deepOrange,
                                      onPressed: () {
                                        sendToUpdateTimeScreen(
                                            timingsList[index]);
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) {
                                        //     return UpdateTimingScreen(
                                        //       timings: timingsList[index],
                                        //     );
                                        //   }),
                                        // );
                                      },
                                      child: new Text(
                                          "End Time : " +
                                              timingsList[index].end_time,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Avenir Next',
                                              fontWeight: FontWeight.w400)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(4.0),
                                      ),
                                    ))
                              ])),
                      SizedBox(
                        width: 10,
                      ),
                      new Expanded(
                          flex: 2,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  height: 30,
                                  child: new CustomSwitch(
                                      activeColor: Colors.deepOrangeAccent,
                                      value: timingsList[index].flg == 0
                                          ? false
                                          : true,
                                      onChanged: (bool value) {
                                        setState(() {
                                          ItemChange(value, index);
                                        });
                                      }),
                                )
                              ]))
                    ],
                  )));
        });

    var selectAllContainer = Container(
      alignment: Alignment.centerRight,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 5.0, 10.0, 5.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selectAll) {
                  selectAll = false;
                  selectText = "Select all";
                  ItemChange(true, -1);
                } else {
                  selectAll = true;
                  selectText = "Unselect all";
                  ItemChange(false, -1);
                }
              });
            },
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                child: Container(
                    height: 30,
                    // width: double.infinity,
                    child: FlatButton(
                      color: HexColor('#00abf1'),
                      onPressed: () => {
                        // getGroupAnswerMappingList(),
                      },
                      child: new Text(selectText,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Avenir Next',
                              fontWeight: FontWeight.w500)),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: HexColor('#00abf1'),
                          )),
                    ))),
          )),
    );

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Padding(
            padding: const EdgeInsets.only(right: 60.0),
            child: Center(
              child: Text('Time'),
            ),
          ),
        ),
        body: Container(
            color: Colors.grey,
            child: new Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //selectAllContainer,
                new Expanded(
                    child: MediaQuery.removePadding(
                        context: context,
                        child: listviewBuilder,
                        removeTop: true)),
                /*Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                    child: Container(
                        height: 40,
                        width: double.infinity,
                        child: FlatButton(
                          color: HexColor('#00abf1'),
                          onPressed: ()=>{
                           // getGroupAnswerMappingList(),
                          },
                          child: new Text("Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Avenir Next',
                                  fontWeight: FontWeight.w500)),
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(8.0),
                              side: BorderSide(
                                color: HexColor('#00abf1'),
                              )),
                        )))*/
              ],
            )));
  }
}

// "  " +
// (index + 1).toString() +
// ") " +
// " " +
