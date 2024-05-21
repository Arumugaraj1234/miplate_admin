import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:miplate/DishListScreen.dart';
import 'package:miplate/TimeListScreen.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/Hotel.dart';
import 'package:miplate/model/Orders.dart';
import 'package:miplate/model/base/Constants.dart';
import 'package:miplate/model/base/HexColor.dart';
import 'package:miplate/model/base/ShowProgressDialogScreen.dart';
import 'package:http/http.dart' as http;
import 'package:miplate/model/dish_detail_model.dart';
import 'package:miplate/model/order_details_model.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/network_services.dart';
import 'package:miplate/order_history_widget_one.dart';
import 'package:miplate/screens/bill_view_screen.dart';
import 'package:miplate/screens/main_drawer.dart';
import 'package:miplate/screens/order_info_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import '../CategoryListScreen.dart';
import '../order_history_widget.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

//import 'package:audioplayers/audioplayers.dart';
//import 'package:audioplayers/audio_cache.dart';

const kTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'Roboto Regular',
    fontWeight: FontWeight.w500);

const kTextStyleOne = TextStyle(
  color: Colors.black,
  fontSize: 16,
  fontFamily: 'Roboto Regular',
);

class OrderRegularLabel extends StatelessWidget {
  final String name;

  OrderRegularLabel({this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: kTextStyle,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  Hotel hotel;

  final drawerItems = [
    'Current Orders',
    'Categories',
    'Dishes',
    'Time',
    'History'
  ];
  DashboardScreen(this.hotel);
  @override
  DashboardScreenState createState() => DashboardScreenState(this.hotel);
}

class DashboardScreenState extends State<DashboardScreen> {
  Hotel hotel;
  Orders orders = new Orders();
  TextEditingController timingController = new TextEditingController();
  bool isGradeSubmited = false;
  bool isTimerToShow = false;
  int _deliveryTimeSelected = 10;

  DashboardScreenState(this.hotel);

  int _value = 0;
  String orderQty = "30";
  int qty = 30;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  Timer _timer;
  Timer _timerForNotification;

  // AudioCache audioCache = AudioCache();
  // AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;
  bool _isNewOrderAvailable = false;

  @override
  void initState() {
    super.initState();
    _getToggleStatusOfRestaurant();
    //_getOrderRequest();
    _getCurrentOrdersForFirstTime();
    const oneSec = const Duration(seconds: 30);
    //_timer = new Timer.periodic(oneSec, (Timer t) => _getOrderRequest());
    _timer = new Timer.periodic(oneSec, (Timer t) => getCurrentOrdersInLoop());
    const notificationSec = const Duration(seconds: 3);
    _timerForNotification =
        new Timer.periodic(notificationSec, (Timer t) => _playNotification());
    //playLocal();
  }

  // playLocal() async {
  //   int result =
  //       await advancedPlayer.play('assets/audio/neworder.mp3', isLocal: true);
  // }

  _playNotification() {
    List<OrderDetailsModel> currentOrders =
        Provider.of<DataServices>(context, listen: false).currentOrders;
    bool isSoundEligible = false;
    for (OrderDetailsModel o in currentOrders) {
      if (o.orderStatusDesc == 'Requested') {
        isSoundEligible = true;
        break;
      }
    }
    if (!_isSoundMute && isSoundEligible) {
      FlutterRingtonePlayer.playNotification();
      //audioCache.play('audio/neworder.mp3', isNotification: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _timerForNotification.cancel();
  }

  void _getToggleStatusOfRestaurant() async {
    ResponseModel response =
        await NetworkServices.shared.getToggleDetails(context: context);
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  void _getCurrentOrdersForFirstTime() async {
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    ResponseModel response = await NetworkServices.shared
        .getAllCurrentOrders(orderType: 1, context: context);
    dialog.hide();
    if (response.code == 1) {
      List<OrderDetailsModel> orders = response.data;
      bool isSoundEligible = false;
      setState(() {
        _isNewOrderAvailable = false;
      });
      for (OrderDetailsModel o in orders) {
        if (o.orderStatusDesc == 'Requested') {
          isSoundEligible = true;
          setState(() {
            _isNewOrderAvailable = true;
            print('New Order Availble');
          });

          break;
        }
      }
      if (!_isSoundMute && isSoundEligible) {
        FlutterRingtonePlayer.playNotification();
        //audioCache.play('audio/neworder.mp3', isNotification: true);
      }
    }
  }

  void getCurrentOrdersInLoop() async {
    ResponseModel response = await NetworkServices.shared
        .getAllCurrentOrders(orderType: 1, context: context);

    if (response.code == 1) {
      List<OrderDetailsModel> orders = response.data;
      bool isSoundEligible = false;
      setState(() {
        _isNewOrderAvailable = false;
      });
      for (OrderDetailsModel o in orders) {
        if (o.orderStatusDesc == 'Requested') {
          isSoundEligible = true;
          setState(() {
            _isNewOrderAvailable = true;
            print('New Order Availble');
          });
          break;
        }
      }
      if (!_isSoundMute && isSoundEligible) {
        FlutterRingtonePlayer.playNotification();
        //audioCache.play('audio/neworder.mp3', isNotification: true);
      }
    }
  }

  _getOrderRequest() async {
    // ShowProgressDialogScreen.showLoading("Loading", true, context);
    String url = Constants.BASE_URL + '/GetNewOrders';

    var response =
        await http.post(url, body: json.encode(_$GetOrdersToJson()), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });

    if (response != null && response.body.isNotEmpty) {
      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      int responseCode = jsonData['Code'];

      if (responseCode == 1) {
        var orderDetails = jsonData['Data']['order'];
        int orderId = orderDetails['order_id'];
        int hotelId = orderDetails['hotel_id'];
        int supplierId = orderDetails['supplier_id'];
        int tableId = orderDetails['table_id'];
        int orderType = orderDetails['order_type'];
        String deliveryAddress = orderDetails['delivery_address'];
        double deliveryLat = orderDetails['delivery_lat'];
        double deliveryLon = orderDetails['delivery_lon'];
        double baseAmount = orderDetails['amount'];
        double discount = orderDetails['discount'];
        double tax = orderDetails['tax'];
        double totalAmount = orderDetails['total'];
        int paymentType = orderDetails['payment_type'];
        int paymentStatus = orderDetails['payment_status'];
        int orderStatus = orderDetails['order_status'];
        String orderStatusDesc = jsonData['Data']['order_status'];
        String fromLocation = jsonData['Data']['hotel_name'];
        String kotPath = jsonData['Data']['kot_path'];
        String billPath = jsonData['Data']['bill_path'];
        Color orderStatusColorCode;
        bool isCancelBtnToShow = true;
        switch (orderStatus) {
          case 1:
            //orderStatusDesc = 'Requested';
            orderStatusColorCode = Colors.blue;
            isCancelBtnToShow = true;
            break;
          case 2:
            //orderStatusDesc = 'Created';
            orderStatusColorCode = Colors.blue;
            isCancelBtnToShow = true;
            break;
          case 3:
            //orderStatusDesc = 'In kitchen';
            orderStatusColorCode = Colors.yellow;
            isCancelBtnToShow = true;
            break;
          case 4:
            //orderStatusDesc = 'On the way';
            orderStatusColorCode = Colors.orange;
            isCancelBtnToShow = true;
            break;
          case 5:
            //orderStatusDesc = 'Delivered';
            orderStatusColorCode = Colors.teal;
            isCancelBtnToShow = false;
            break;
          case 6:
            //orderStatusDesc = 'Completed';
            orderStatusColorCode = Colors.green;
            isCancelBtnToShow = false;
            break;
          case 7:
            //orderStatusDesc = 'Cancelled';
            orderStatusColorCode = Colors.red;
            isCancelBtnToShow = false;
            break;
          default:
            //orderStatusDesc = '';
            orderStatusColorCode = Colors.blue;
            isCancelBtnToShow = false;
            break;
        }

        var serverDate = orderDetails['order_date'];
        print(serverDate);
        String orderDate = changeDateFormat(serverDate);
        var orderedItems = jsonData['Data']['items'];
        String orderTypeDesc = '';
        var dT = orderDetails['delivery_time'];

        String deliveryTime = changeDateFormatOne(dT);

        switch (orderType) {
          case 2:
            orderTypeDesc = 'Door Delivery';
            break;
          case 3:
            orderTypeDesc = 'Door Delivery';
            break;
          case 4:
            orderTypeDesc = 'Door Delivery';
            break;
          default:
            orderTypeDesc = '';
            break;
        }

        List<DishDetailModel> dishes = [];
        String dishesName = '';

        for (var item in orderedItems) {
          int dishId = item['dish_id'];
          String dishName = item['dish_name'];
          String dishIconLink = item['dish_icon'];
          double price = item['rate'];
          String description = item['description'];
          int dishTypeFlag = item['dish_type'];
          double qty = item['qty'];
          int quantity = qty.toInt();
          VegOrNonVeg dishType;
          if (dishTypeFlag == 1) {
            dishType = VegOrNonVeg.nonVeg;
          } else {
            dishType = VegOrNonVeg.veg;
          }
          String hint = dishName + dishName.toLowerCase();
          DishDetailModel dishModel = DishDetailModel(
              id: dishId,
              imageLink: dishIconLink,
              name: dishName,
              region: description,
              vegOrNonVegType: dishType,
              category: 'Category',
              price: price,
              count: quantity,
              dishSize: 'Half',
              isSelected: false,
              hintDetails: hint,
              isFavorite: false);

          dishes.add(dishModel);
          if (dishesName == '') {
            dishesName = dishName + ' x ' + quantity.toString();
          } else {
            dishesName =
                dishesName + ', ' + dishName + ' x ' + quantity.toString();
          }
        }

        OrderDetailsModel oM = OrderDetailsModel(
            orderId: orderId,
            hotelId: hotelId,
            supplierId: supplierId,
            tableId: tableId,
            orderType: orderType,
            deliveryAddress: deliveryAddress,
            deliveryLatitude: deliveryLat,
            deliveryLongitude: deliveryLon,
            amount: baseAmount,
            discount: discount,
            tax: tax,
            totalAmount: totalAmount,
            paymentType: paymentType,
            paymentStatus: paymentStatus,
            orderStatus: orderStatus,
            orderDate: orderDate,
            dishes: dishes,
            dishesName: dishesName,
            orderTypeDesc: orderTypeDesc,
            orderStatusColorCode: orderStatusColorCode,
            orderStatusDesc: orderStatusDesc,
            isCancelButtonToShow: isCancelBtnToShow,
            fromLocation: fromLocation,
            initialDeliveryTime: deliveryTime,
            modifiedDeliveryTime: deliveryTime,
            kotPath: kotPath,
            billPath: billPath);
        List<OrderDetailsModel> orders = [];
        orders.add(oM);
        Provider.of<DataServices>(context, listen: false)
            .setCurrentOrders(orders);
        setState(() {
          noOfMinutesAdded = 0;
        });

        if (!_isSoundMute) {
          FlutterRingtonePlayer.playNotification();
        }
      } else {}

//      if (loginResponse != null && !loginResponse['order_id'] != null) {
//        orders.order_id = loginResponse['order_id'];
//        orders.hotel_id = loginResponse['hotel_id'];
//        orders.customer_id = loginResponse['customer_id'];
//        orders.amount = loginResponse['amount'];
//        orders.discount = loginResponse['discount'];
//        orders.delivery_address = loginResponse['delivery_address'];
//        orders.order_date = loginResponse['order_date'];
//        orders.order_type = loginResponse['order_type'];
//        orders.supplier_id = loginResponse['supplier_id'];
//        orders.payment_type = loginResponse['payment_type'];
//        orders.txn_id = loginResponse['txn_id'];
//        orders.delivery_time = loginResponse['delivery_time'];
//        orders.tax = loginResponse['tax'];
//        orders.total = loginResponse['total'];
//        orders.table_id = loginResponse['table_id'];
//        _showBottomMenu(orders);
//        timingController.text = orderQty;
//        ;
//      }

      // ShowProgressDialogScreen.showLoading("Loading", false, context);
    } else {
      print('hi');
      // ShowProgressDialogScreen.showLoading("Please wait...", false, context);
    }
  }

  Map<String, dynamic> _$GetOrdersToJson() => <String, dynamic>{
        "hotel_id": hotel.hotel_id,
      };

  String changeDateFormat(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + 'T' + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req =
        formatDate(dateTime, [MM, dd, ', ', yyyy, ', ', hh, ':', nn, am]);
    return req;
  }

  String changeDateFormatOne(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + 'T' + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req = formatDate(dateTime, [yyyy, mm, dd, 'T', HH, nn, ss]);
    return req;
  }

  String getDateTime(String serverDate) {
    String reqDate = serverDate
        .replaceAll(RegExp('-'), '')
        .replaceAll(RegExp(':'), '')
        .replaceAll(RegExp('T'), '');
    String date = reqDate.split('.')[0];
    String dateWithT = date.substring(0, 8) + "T" + date.substring(8);
    DateTime dateTime = DateTime.parse(dateWithT);
    String req = formatDate(dateTime, [
      HH,
      ':',
      nn,
    ]);
    return req;
  }

  updateOrders(OrderDetailsModel orders, int type, int index) async {
    // ShowProgressDialogScreen.showLoading("Please wait...", true, context);
    String url = Constants.BASE_URL + '/AcceptRejectOrder';
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response = await http.post(url,
        body: json.encode(_$updateGradeLevelToJson(orders, type)),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        });
    dialog.hide();
    Map<String, dynamic> groupCourseAnswerMappingResponse =
        jsonDecode(response.body);
    if (groupCourseAnswerMappingResponse != null &&
        response.statusCode == 200) {
//      ShowProgressDialogScreen.showLoading(
//          "Please wait...", false, context);
      isGradeSubmited = true;
      setState(() {
        isTimerToShow = false;
      });

      print('Type: $type');
      //Navigator.of(context).pop(true);
      if (type == 1) {
        _getCurrentOrdersForFirstTime();
        _showSnackBar("Order accepted successfully");
      } else {
        Provider.of<DataServices>(context, listen: false)
            .removeOrderFromCurrentOrder(index);
        _showSnackBar("Order declined");
      }
    } else {
      isGradeSubmited = false;
//      ShowProgressDialogScreen.showLoading(
//          "Please wait...", false, context);
    }
  }

  Map<String, dynamic> _$updateGradeLevelToJson(
          OrderDetailsModel orders, int type) =>
      <String, dynamic>{
        "order_id": orders.orderId,
        "type": type,
        "delivery_time": orders.noOfTimesClicked * 5,
      };

  _showBottomMenu(Orders orders) {
    String errorMsg = "";

    return showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context, setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  height: 240,
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  decoration: BoxDecoration(
                    //scolor: HexColor("#f7f6f8"),
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0)),
                  ),
                  child: Container(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                        alignment: Alignment.centerLeft,
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(10.0),
                              topRight: const Radius.circular(10.0)),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            new Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(left: 15),
                                child: new Container(
                                  alignment: Alignment.centerLeft,
                                  height: 50,
                                  width: 50,
                                  child: Image.asset(
                                    "assets/images/logo.png",
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                )),
                            Container(
                                margin: EdgeInsets.fromLTRB(80, 0, 40, 0),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    new Container(
                                      alignment: Alignment.centerLeft,
                                      child: new Text("Set Poori with vada",
                                          softWrap: true,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontStyle: FontStyle.normal,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    new Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(bottom: 6),
                                      child: new Text(orders.delivery_address,
                                          softWrap: true,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontStyle: FontStyle.normal)),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                      new Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Divider(height: 0.5, color: HexColor("#929cb7")),
                            Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(errorMsg,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: HexColor("#ff7c51"),
                                        fontSize: 12,
                                        fontFamily: 'Roboto Regular',
                                        fontWeight: FontWeight.w500)))
                          ],
                        ),
                      ),
                      new Container(
                        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: new GestureDetector(
                                onTap: () => {
                                  setState(() {
                                    if (qty >= 0) {
                                      qty = (qty + 15);
                                      timingController.text = qty.toString();
                                    }
                                  })
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  margin: EdgeInsets.fromLTRB(0, 10, 15, 10),
                                  child: Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                              flex: 2,
                            ),
                            Flexible(
                              child: Container(
                                alignment: Alignment.topLeft,
                                height: 40,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: new TextFormField(
                                  readOnly: true,
                                  controller: timingController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  textAlign: TextAlign.center,
                                  //controller: maxController,
                                  decoration: new InputDecoration(
                                      border: new OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: HexColor("#a9b2c8")),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(6.0),
                                    ),
                                  )),
                                ),
                              ),
                              flex: 4,
                            ),
                            Flexible(
                              child: new GestureDetector(
                                onTap: () => {
                                  setState(() {
                                    setState(() {
                                      if (qty != 0) {
                                        qty = (qty - 15);
                                        timingController.text = qty.toString();
                                      }
                                    });
                                  })
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  margin: EdgeInsets.fromLTRB(0, 10, 15, 10),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                    size: 30.0,
                                  ),
                                ),
                              ),
                              flex: 2,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            child: FlatButton(
                                color: HexColor('#22b6f3'),
                                onPressed: () => {
                                      setState(() {
                                        if (timingController.text == null ||
                                            timingController.text.isEmpty) {
                                          errorMsg =
                                              "Timing should not be Empty";
                                        }
                                        if (timingController.text == null ||
                                            timingController.text == "0") {
                                          errorMsg =
                                              "Timing should not be less than or equal to 0";
                                        } else {
                                          orders.delivery_time =
                                              timingController.text;
                                          // updateOrders(orders);
                                          /* var finalGrade = double.parse(timingController.text);
                                              var max = double.parse(orders.amount.toString());
                                              var min = double.parse(orders.discount.toString());
                                              if (finalGrade < min) {
                                                errorMsg = "Timing should not be less than Minimum Grade";
                                              } else if (finalGrade > max) {
                                                errorMsg = "Timing should not be greater than Maximum Grade";
                                              }else{
                                                errorMsg = "";
                                                updateOrders(orders);
                                              }*/
                                        }
                                      })
                                    },
                                child: new Text("Accept Order",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Avenir Next',
                                        fontWeight: FontWeight.w500)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(8.0),
                                )),
                          ))
                    ],
                  ))),
            );
          });
        });
  }

  int _restaurantStateFlag = 0;
  bool _isSoundMute = false;
  int noOfMinutesAdded = 0;
  bool _orderCompletionViewVisibleStatus = false;
  int _selectedRadio = 1;
  int _orderIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
      return Scaffold(
        key: scaffoldKey,
        drawer: MainDrawer(
          hotel: hotel,
          switchValue: dataServices.restaurantToggle.status,
          onSwitchChanged: (bool value) async {
            ProgressDialog dialog = new ProgressDialog(context);
            dialog.style(message: 'Please wait...');
            await dialog.show();
            int v = value ? 1 : 0;
            ResponseModel response = await NetworkServices.shared
                .updateToggleStatus(type: 1, status: v);
            dialog.hide();
            _showSnackBar(response.message);
            if (response.code == 1) {
              dataServices.updateRestaurantToggleStatus(v);
            }
          },
        ),
        appBar: AppBar(
          title: Text("Gurkha Falmouth"),
          actions: [
            IconButton(
                icon: Icon(_isSoundMute
                    ? Icons.music_off_sharp
                    : Icons.music_note_sharp),
                onPressed: () {
                  setState(() {
                    _isSoundMute = !_isSoundMute;
                  });

                  //audioCache.play('audio/neworder.mp3', isNotification: true);
                })
          ],
          /*bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white70,
                //indicatorSize: TabBarIndicatorSize.label,
                labelStyle: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto Regular',
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
                //For Selected tab
                unselectedLabelStyle: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Roboto Regular',
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                //For Un-selected Tabs
                tabs: [
                  Tab(text: "Orders"),
                  Tab(text: "Categories"),
                  Tab(text: "Dishes"),
                  Tab(text: "Times"),
                ],
              ),
              automaticallyImplyLeading: true,
              backgroundColor: Colors.blue,*/
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                child: dataServices.currentOrders.length > 0
                    ? ListView(
                        children: List.generate(
                            dataServices.currentOrders.length, (int index) {
                        OrderDetailsModel order =
                            dataServices.currentOrders[index];
                        String orderNo =
                            order.orderId.toString().padLeft(4, '0');
                        return Container(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 125,
                                              child: Text(
                                                'Order No: G$orderNo',
                                                style: kTextStyleOne,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              width: 125,
                                              child: Text(
                                                  'Amount: ${String.fromCharCodes(new Runes('\u00A3'))}${order.totalAmount.toStringAsFixed(2)}',
                                                  style: kTextStyleOne),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              width: 80,
                                              child: Text(order.orderTypeDesc,
                                                  style: kTextStyleOne),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (order.orderStatusDesc ==
                                                    "Requested") {
                                                  if (dataServices
                                                          .currentOrders[index]
                                                          .noOfTimesClicked >
                                                      12) {
                                                    dataServices
                                                        .decreaseCount(index);
                                                  }

                                                  // if (noOfMinutesAdded > 0) {
                                                  //   setState(() {
                                                  //     noOfMinutesAdded--;
                                                  //   });
                                                  // }

                                                  //print(noOfMinutesAdded);
                                                  print(order.noOfTimesClicked);
                                                  if (dataServices
                                                              .currentOrders[
                                                                  index]
                                                              .noOfTimesClicked >
                                                          0 &&
                                                      dataServices
                                                              .currentOrders[
                                                                  index]
                                                              .noOfTimesClicked <
                                                          13) {
                                                    DateTime dateTime =
                                                        DateTime.parse(order
                                                            .modifiedDeliveryTime);
                                                    DateTime t = dateTime
                                                        .subtract(Duration(
                                                            minutes: 5));
                                                    String req = formatDate(t, [
                                                      yyyy,
                                                      mm,
                                                      dd,
                                                      'T',
                                                      HH,
                                                      nn,
                                                      ss
                                                    ]);
                                                    dataServices
                                                        .modifyDeliveryTime(
                                                            index: index,
                                                            time: req);
                                                    dataServices
                                                        .decreaseCount(index);
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                Icons.remove,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              order.timeOnly(),
                                              style: kTextStyleOne.copyWith(
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // setState(() {
                                                //   noOfMinutesAdded++;
                                                // });
                                                //print(noOfMinutesAdded);

                                                if (order.orderStatusDesc ==
                                                    "Requested") {
                                                  dataServices
                                                      .increaseCount(index);
                                                  print(order.noOfTimesClicked);
                                                  if (dataServices
                                                          .currentOrders[index]
                                                          .noOfTimesClicked <
                                                      13) {
                                                    print('Hi');
                                                    DateTime dateTime =
                                                        DateTime.parse(order
                                                            .modifiedDeliveryTime);
                                                    DateTime t = dateTime.add(
                                                        Duration(minutes: 5));
                                                    String req = formatDate(t, [
                                                      yyyy,
                                                      mm,
                                                      dd,
                                                      'T',
                                                      HH,
                                                      nn,
                                                      ss
                                                    ]);
                                                    dataServices
                                                        .modifyDeliveryTime(
                                                            index: index,
                                                            time: req);
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                            ),
                                            Visibility(
                                              visible: _isNewOrderAvailable,
                                              child: SizedBox(
                                                width: 5,
                                              ),
                                            ),
                                            Visibility(
                                              visible: _isNewOrderAvailable,
                                              child: Container(
                                                width: 75,
                                                child: Visibility(
                                                  visible:
                                                      order.orderStatusDesc ==
                                                              "Requested"
                                                          ? true
                                                          : false,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      updateOrders(
                                                          order, 1, index);
                                                    },
                                                    child: Container(
                                                      height: 25,
                                                      width: 75,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                        color: Colors.green,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'ACCEPT',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: _isNewOrderAvailable,
                                              child: SizedBox(
                                                width: 5,
                                              ),
                                            ),
                                            Visibility(
                                              visible: _isNewOrderAvailable,
                                              child: Container(
                                                width: 75,
                                                child: Visibility(
                                                  visible:
                                                      order.orderStatusDesc ==
                                                              "Requested"
                                                          ? true
                                                          : false,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      updateOrders(
                                                          order, 2, index);
                                                    },
                                                    child: Container(
                                                      height: 25,
                                                      width: 75,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(5),
                                                        ),
                                                        color: Colors.red,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'DECLINE',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return BillViewScreen(
                                                    order: order,
                                                    flag: 2,
                                                  );
                                                }));
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                  color: Colors.black,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'KOT',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return BillViewScreen(
                                                    order: order,
                                                    flag: 1,
                                                  );
                                                }));
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                  color: Colors.grey,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'BILL',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _orderCompletionViewVisibleStatus =
                                                      true;
                                                  _orderIndex = index;
                                                });
                                              },
                                              child: Container(
                                                height: 25,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(5),
                                                  ),
                                                  color:
                                                      Colors.deepOrangeAccent,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'COMPLETE',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }))
                    : Center(
                        child: Text('No orders available to show',
                            style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 20,
                                fontFamily: 'Avenir Next',
                                fontWeight: FontWeight.bold)),
                      ),
              ),
            ),
            Visibility(
              visible: isTimerToShow,
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      height: 150.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Delivery Time In Minutes',
                              style: kTextStyle,
                            ),
                            Expanded(
                              child: Container(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          if (_deliveryTimeSelected > 10) {
                                            setState(() {
                                              _deliveryTimeSelected =
                                                  _deliveryTimeSelected - 5;
                                            });
                                          }
                                        },
                                        child: Center(
                                          child: Text(
                                            '-',
                                            style: kTextStyle.copyWith(
                                                fontSize: 30.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Container(
                                      child: Center(
                                        child: Text(
                                          '$_deliveryTimeSelected',
                                          style: kTextStyle.copyWith(
                                              fontSize: 25.0),
                                        ),
                                      ),
                                    )),
                                    Expanded(
                                      child: MaterialButton(
                                        onPressed: () {
                                          if (_deliveryTimeSelected < 60) {
                                            setState(() {
                                              _deliveryTimeSelected =
                                                  _deliveryTimeSelected + 5;
                                            });
                                          }
                                        },
                                        child: Center(
                                          child: Text(
                                            '+',
                                            style: kTextStyle.copyWith(
                                                fontSize: 30.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 50,
                              child: Center(
                                child: Container(
                                  height: 40.0,
                                  width: 250.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 100.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {
                                            // updateOrders(
                                            //     dataServices.currentOrders[0],
                                            //     1, index);
                                          },
                                          child: Text(
                                            'OK',
                                            style: kTextStyle.copyWith(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100.0,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {
                                            setState(() {
                                              isTimerToShow = false;
                                            });
                                          },
                                          child: Text(
                                            'CANCEL',
                                            style: kTextStyle.copyWith(
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: _orderCompletionViewVisibleStatus,
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width - 40,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: _selectedRadio,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedRadio = val;
                                    });
                                    print(val);
                                  },
                                  activeColor: Colors.deepOrange,
                                ),
                                Text(
                                  'Cash',
                                  style: kTextStyleOne,
                                )
                              ],
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 2,
                                  groupValue: _selectedRadio,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedRadio = val;
                                    });
                                    print(val);
                                  },
                                  activeColor: Colors.deepOrange,
                                ),
                                Text(
                                  'Creditcard/Debitcard',
                                  style: kTextStyleOne,
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _orderCompletionViewVisibleStatus = false;
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  color: Colors.grey,
                                ),
                                child: Center(
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                ProgressDialog dialog =
                                    new ProgressDialog(context);
                                dialog.style(message: 'Please wait...');
                                await dialog.show();
                                ResponseModel response =
                                    await NetworkServices.shared.completeOrder(
                                        orderId: dataServices
                                            .currentOrders[_orderIndex].orderId,
                                        paymentType: _selectedRadio,
                                        index: _orderIndex,
                                        context: context);
                                dialog.hide();
                                if (response.code == 1) {
                                  setState(() {
                                    _orderCompletionViewVisibleStatus = false;
                                  });
                                }
                                _showSnackBar(response.message);
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  color: Colors.deepOrangeAccent,
                                ),
                                child: Center(
                                  child: Text(
                                    'COMPLETE',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}

/*DefaultTabController(
length: 4,
child: Scaffold(
key: scaffoldKey,
drawer: Drawer(
child: ListView(
// Important: Remove any padding from the ListView.
padding: EdgeInsets.zero,
children: <Widget>[
DrawerHeader(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: <Widget>[
new Container(
alignment: Alignment.center,
//margin: EdgeInsets.all(10),
child: Text(
hotel.name != null ? hotel.name : "Hotel Name",
textAlign: TextAlign.left,
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontFamily: 'Avenir Next',
fontWeight: FontWeight.w500)),
),
new Container(
alignment: Alignment.center,
//margin: EdgeInsets.all(10),
child: Text(hotel.address,
textAlign: TextAlign.left,
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontFamily: 'Avenir Next',
fontWeight: FontWeight.w500)),
),
new Container(
alignment: Alignment.center,
margin: EdgeInsets.all(10),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Transform(
transform: new Matrix4.identity()..scale(1.2),
child: new Switch(
activeColor: Colors.white,
value: _value == 0 ? false : true,
onChanged: (bool value) {
setState(() {
//ItemChange(value, index);
});
}),
),
Container(
margin: EdgeInsets.all(5),
child: Text('Online',
textAlign: TextAlign.left,
style: TextStyle(
color: Colors.white,
fontSize: 20,
fontFamily: 'Avenir Next',
fontWeight: FontWeight.w500)),
)
],
),
),
]),
decoration: BoxDecoration(
color: Colors.blue,
),
),
ListTile(
title: Padding(
padding:
const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
child: Container(
height: 30,
// width: double.infinity,
child: FlatButton(
color: HexColor('#00abf1'),
onPressed: () => {
// getGroupAnswerMappingList(),
},
child: new Text("Home",
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
onTap: () {
Navigator.pop(context);
},
),
ListTile(
title: Padding(
padding:
const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
child: Container(
height: 30,
// width: double.infinity,
child: FlatButton(
color: HexColor('#00abf1'),
onPressed: () => {
// getGroupAnswerMappingList(),
},
child: new Text("Support",
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
onTap: () {
Navigator.pop(context);
},
)
],
),
),
appBar: AppBar(
title: Text("MiPlate"),
bottom: TabBar(
labelColor: Colors.white,
unselectedLabelColor: Colors.white70,
indicatorColor: Colors.white70,
//indicatorSize: TabBarIndicatorSize.label,
labelStyle: TextStyle(
fontSize: 16.0,
fontFamily: 'Roboto Regular',
fontWeight: FontWeight.w700,
color: Colors.black),
//For Selected tab
unselectedLabelStyle: TextStyle(
fontSize: 16.0,
fontFamily: 'Roboto Regular',
fontWeight: FontWeight.w700,
color: Colors.white),
//For Un-selected Tabs
tabs: [
Tab(text: "Orders"),
Tab(text: "Categories"),
Tab(text: "Dishes"),
Tab(text: "Times"),
],
),
automaticallyImplyLeading: true,
backgroundColor: Colors.blue),
body: TabBarView(
children: [
Container(
color: Colors.white,
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 10.0, horizontal: 20.0),
child: ListView(
children: List.generate(
dataServices.currentOrders.length, (int index) {
OrderDetailsModel order =
dataServices.currentOrders[index];
return OrderHistoryWidget(
orderDetails: order,
onCancelBtnPressed: () {},
onTrackBtnPressed: () {},
onOrderAgainPressed: () async {},
onRateFoodBtnPressed: () {},
onItemSelected: () async {
Navigator.push(context,
MaterialPageRoute(builder: (context) {
return OrderInfoScreen(orderDetails: order);
}));
},
);
})),
)),
CategoryListScreen(hotel),
DishListScreen(hotel),
TimingsListScreen(hotel),
],
),
),
)

TabBarView(
                  children: [
                    Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: ListView(
                              children: List.generate(
                                  dataServices.currentOrders.length,
                                  (int index) {
                            OrderDetailsModel order =
                                dataServices.currentOrders[index];
                            return OrderHistoryWidget(
                              orderDetails: order,
                              onCancelBtnPressed: () {},
                              onTrackBtnPressed: () {},
                              onOrderAgainPressed: () {
                                setState(() {
                                  isTimerToShow = true;
                                });
                              },
                              onRateFoodBtnPressed: () {
                                updateOrders(dataServices.currentOrders[0], 2);
                              },
                              onItemSelected: () async {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return OrderInfoScreen(orderDetails: order);
                                }));
                              },
                            );
                          })),
                        ),),
                    CategoryListScreen(hotel),
                    DishListScreen(hotel),
                    TimingsListScreen(hotel),
                  ],
                )
 */

/*OrderHistoryWidgetOne(
orderDetails: order,
onCancelBtnPressed: () {},
onTrackBtnPressed: () {},
onOrderAgainPressed: () {
setState(() {
isTimerToShow = true;
});
},
onRateFoodBtnPressed: () {
updateOrders(dataServices.currentOrders[0], 2);
},
onItemSelected: () async {
Navigator.push(context,
MaterialPageRoute(builder: (context) {
return OrderInfoScreen(orderDetails: order);
}));
},
isButtonToShow: true,
);*/
