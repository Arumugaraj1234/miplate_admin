import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:miplate/model/Category.dart';
import 'package:miplate/model/base/BaseNetworkResponse.dart';
import 'package:miplate/model/base/ShowProgressDialogScreen.dart';

import 'model/Hotel.dart';
import 'model/base/Constants.dart';
import 'model/base/HexColor.dart';

class CategoryListScreen extends StatefulWidget {
  Hotel hotel;

  CategoryListScreen(this.hotel);

  @override
  CategoryListScreenState createState() => CategoryListScreenState(hotel);
}

class CategoryListScreenState extends State<CategoryListScreen> {
  Hotel hotel;

  CategoryListScreenState(this.hotel);

  List<Map> categoryListMap = new List();
  List<Category> categoryList = List();
  List<Map> categoryListSelected = List();

  bool selectAll = false;
  String selectText = "Select all";
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void onPageVisible() {}

  @override
  void initState() {
    super.initState();
    //ShowProgressDialogScreen.showLoading("Loading", true, context);
    fetchCategories();
  }

  Future<List<Category>> fetchCategories() async {
    String url = Constants.BASE_URL + '/GetCategories';
    try {
      var response =
          await http.post(url, body: json.encode(_$categoryToJson()), headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      });

      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      List<dynamic> categoryListResponse = jsonData['Data'];
      for (var res in categoryListResponse) {
        Category category = new Category();
        category.hotel_id = res['hotel_id'];
        category.name = res['name'];
        category.icon = res['icon'];
        category.flg = res['flg'];
        category.category_id = res['category_id'];
        category.ImageURL = res['ImageURL'];
        category.created_user_id = res['created_user_id'];
        category.created_date = res['created_date'];
        category.selected = false;
        categoryList.add(category);
      }
      // ShowProgressDialogScreen.showLoading("Loading", false, context);

      setState(() {
        categoryList;
      });
      return categoryList;
    } catch (error) {
      print(error);
      // ShowProgressDialogScreen.showLoading("Loading", false, context);
    }
  }

  void ItemChange(bool val, int index) {
    setState(() {
      if (index == -1) {
        for (var i = 0; i < categoryList.length; i++) {
          if (selectAll) {
            categoryList[i].selected = true;
            categoryList[i].flg = 1;
          } else {
            categoryList[i].selected = false;
            categoryList[i].flg = 0;
          }
        }
      } else {
        categoryList[index].selected = val;
        if (val == true) {
          categoryList[index].flg = 1;
        } else {
          categoryList[index].flg = 0;
        }
        changeStatus(categoryList[index]);
      }
    });
  }

  Map<String, dynamic> _$categoryToJson() => <String, dynamic>{
        "hotel_id": 1,
      };

  /*getGroupAnswerMappingList() {
    categoryListSelected.clear();
    for (var hotel in categoryList) {
      if (hotel.selected && !categoryListSelected.contains(hotel)) {
        Map<String, dynamic> map = _$categoryToJson(hotel);
        categoryListSelected.add(map);
      }
    }
  }*/

  Future<Category> changeStatus(Category category) async {
    //ShowProgressDialogScreen.showLoading("Loading", true, context);

    String url = Constants.BASE_URL + '/ChangeStatus';
    try {
      var response = await http.post(url,
          body: json.encode(_$CategoryChangeStatusToJson(category)),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
          });

      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      // ShowProgressDialogScreen.showLoading("Loading", false, context);
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

  Map<String, dynamic> _$CategoryChangeStatusToJson(Category category) =>
      <String, dynamic>{
        "id": category.category_id,
        "status": category.flg,
        "tablename": "categories"
      };

  @override
  Widget build(BuildContext context) {
    var listviewBuilder = ListView.builder(
        itemCount: categoryList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.fromLTRB(10, 4, 10, 0),
              child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      /*new Expanded(
                          flex: 3,
                          child: new Container(
                              margin: EdgeInsets.only(bottom: 2),
                              alignment: Alignment.center,
                              child: categoryList[index].ImageURL == null ||
                                      categoryList[index].icon == null ||
                                      categoryList[index].ImageURL.isEmpty ||
                                      categoryList[index].icon.isEmpty
                                  ? new Container(
                                      width: 40.0,
                                      height: 40.0,
                                      child: Image.asset(
                                        "assets/images/logo.png",
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                      ),
                                    )
                                  : new Container(
                                      width: 40.0,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                categoryList[index].ImageURL +
                                                    categoryList[index].icon),
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
                                child: Text(categoryList[index].name,
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
                                      value: categoryList[index].flg == 0
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
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
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
              child: Text('Categories'),
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
                padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: Container(
                    height: 30,
                    width: double.infinity,
                    child: FlatButton(
                      color: HexColor('#00abf1'),
                      onPressed: () => {
                        //getGroupAnswerMappingList(),
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
