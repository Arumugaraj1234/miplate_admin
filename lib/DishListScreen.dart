import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:http/http.dart' as http;
import 'package:miplate/model/Dishes.dart';
import 'package:miplate/model/base/ShowProgressDialogScreen.dart';
import 'model/Hotel.dart';
import 'model/base/Constants.dart';
import 'model/base/HexColor.dart';

class DishListScreen extends StatefulWidget {
  Hotel hotel;

  DishListScreen(this.hotel);

  @override
  DishListScreenState createState() => DishListScreenState(hotel);
}

class DishListScreenState extends State<DishListScreen> {
  SearchBar searchBar;

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: new Padding(
          padding: const EdgeInsets.only(right: 60.0),
          child: Center(
            child: Text('Dishes'),
          ),
        ),
        actions: [searchBar.getSearchAction(context)]);
  }

  DishListScreenState(this.hotel) {
    searchBar = new SearchBar(
        inBar: false,
        setState: setState,
        onSubmitted: print,
        onChanged: (String value) {
          setState(() {
            disheList = [];
          });
          if (value == '') {
            setState(() {
              disheList = _originalDishesList;
            });
          } else {
            for (Dishes d in _originalDishesList) {
              if (d.hintText.contains(value)) {
                disheList.add(d);
              }
            }
          }

          // Provider.of<DataServices>(context, listen: false)
          //     .filterProducts(value);
        },
        onCleared: () {
          // Provider.of<DataServices>(context, listen: false).filterProducts('');
        },
        buildDefaultAppBar: buildAppBar);
  }

  // AppBar(
  // leading: IconButton(
  // icon: Icon(Icons.arrow_back),
  // onPressed: () {
  // Navigator.pop(context);
  // }),
  // title: Padding(
  // padding: const EdgeInsets.only(right: 60.0),
  // child: Center(
  // child: Text('Dishes'),
  // ),
  // ),
  // )

  Hotel hotel;

  //DishListScreenState(this.hotel);

  List<Map> disheListMap = new List();
  List<Dishes> disheList = List();
  List<Dishes> _originalDishesList = List();
  List<Map> disheListSelected = List();

  bool selectAll = false;
  String selectText = "Select all";
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void onPageVisible() {}

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<List<Dishes>> fetchCategories() async {
    ///ShowProgressDialogScreen.showLoading("Loading", true, context);
    String url = Constants.BASE_URL + '/GetDishes';
    try {
      var response =
          await http.post(url, body: json.encode(_$disheToJson()), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      List<dynamic> disheListResponse = jsonData['Data'];
      for (var res in disheListResponse) {
        Dishes dishes = new Dishes();
        dishes.hotel_id = res['hotel_id'];
        dishes.name = res['name'];
        String dishName = res['name'];
        dishes.icon = res['icon'];
        dishes.flg = res['flg'];
        dishes.dish_id = res['dish_id'];
        dishes.ImageURL = res['ImageURL'];
        dishes.created_user_id = res['created_user_id'];
        dishes.created_date = res['created_date'];
        dishes.selected = false;
        String hintText =
            dishName.toLowerCase() + dishName.toUpperCase() + dishName;
        dishes.hintText = hintText;
        disheList.add(dishes);
      }
      // ShowProgressDialogScreen.showLoading("Loading", false, context);
      setState(() {
        disheList;
        _originalDishesList = disheList;
      });
      return disheList;
    } catch (error) {
      print(error);
      // ShowProgressDialogScreen.showLoading("Loading", false, context);

    }
  }

  Map<String, dynamic> _$disheToJson() => <String, dynamic>{
        "hotel_id": 1,
      };

  void ItemChange(bool val, int index) {
    setState(() {
      if (index == -1) {
        for (var i = 0; i < disheList.length; i++) {
          if (selectAll) {
            disheList[i].selected = true;
          } else {
            disheList[i].selected = false;
          }
        }
      } else {
        disheList[index].selected = val;
        if (val == true) {
          disheList[index].flg = 1;
        } else {
          disheList[index].flg = 0;
        }

        changeStatus(disheList[index]);
      }
    });
  }

  Future<Dishes> changeStatus(Dishes dishes) async {
    //  ShowProgressDialogScreen.showLoading("Loading", true, context);
    String url = Constants.BASE_URL + '/ChangeStatus';
    try {
      var response = await http.post(url,
          body: json.encode(_$DishesChangeStatusToJson(dishes)),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      //  ShowProgressDialogScreen.showLoading("Loading", false, context);
      _showSnackBar(jsonData['Message']);
    } catch (error) {
      print(error);
      // ShowProgressDialogScreen.showLoading("Loading", false, context);
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: Colors.green, content: new Text(text)));
  }

  Map<String, dynamic> _$DishesChangeStatusToJson(Dishes dishes) =>
      <String, dynamic>{
        "id": dishes.dish_id,
        "status": dishes.flg,
        "tablename": "dishes"
      };

  /* getGroupAnswerMappingList() {
    disheListSelected.clear();
    for (var hotel in disheList) {
      if (hotel.selected && !disheListSelected.contains(hotel)) {
        Map<String, dynamic> map = _$DishToJson(hotel);
        disheListSelected.add(map);
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    var listviewBuilder = ListView.builder(
        itemCount: disheList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.fromLTRB(10, 4, 10, 0),
            // color: HexColor("#f7f6f8"),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  /* new Expanded(
                      flex: 3,
                      child: new Container(
                          margin: EdgeInsets.only(bottom: 2),
                          alignment: Alignment.center,
                          child: disheList[index].ImageURL == null ||
                                  disheList[index].icon == null ||
                                  disheList[index].ImageURL.isEmpty ||
                                  disheList[index].icon.isEmpty
                              ? new Container(
                                  width: 40.0,
                                  height: 40.0,
                                  child: Image.asset(
                                    "assets/images/logo.png",
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                )
                              : new Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            disheList[index].ImageURL +
                                                disheList[index].icon),
                                        fit: BoxFit.cover),
                                  ),
                                ))),*/
                  SizedBox(
                    width: 10,
                  ),
                  new Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text(disheList[index].name,
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
                      )),
                  new Expanded(
                      flex: 3,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              height: 30,
                              child: new CustomSwitch(
                                  activeColor: Colors.deepOrangeAccent,
                                  value:
                                      disheList[index].flg == 0 ? false : true,
                                  onChanged: (bool value) {
                                    setState(() {
                                      ItemChange(value, index);
                                    });
                                  }),
                            )
                          ]))
                ],
              ),
            ),
          );
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
                      ))))),
    );

    return Scaffold(
        key: scaffoldKey,
        appBar: searchBar.build(context),
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
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                    child: Container(
                        height: 30,
                        width: double.infinity,
                        child: FlatButton(
                          color: HexColor('#00abf1'),
                          onPressed: () => {
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
