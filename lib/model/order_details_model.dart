import 'package:flutter/material.dart';

import 'dish_detail_model.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class OrderDetailsModel {
  int orderId;
  int hotelId;
  int supplierId;
  int tableId;
  int orderType;
  String orderTypeDesc;
  String deliveryAddress;
  double deliveryLatitude;
  double deliveryLongitude;
  double amount;
  double discount;
  double tax;
  double totalAmount;
  int paymentType;
  int paymentStatus;
  int orderStatus;
  String orderStatusDesc;
  Color orderStatusColorCode;
  String orderDate;
  List<DishDetailModel> dishes;
  String dishesName;
  bool isCancelButtonToShow;
  String fromLocation;
  String initialDeliveryTime;
  String modifiedDeliveryTime;
  int noOfTimesClicked = 0;
  String kotPath;
  String billPath;

  OrderDetailsModel(
      {this.orderId,
      this.hotelId,
      this.supplierId,
      this.tableId,
      this.orderType,
      this.deliveryAddress,
      this.deliveryLatitude,
      this.deliveryLongitude,
      this.amount,
      this.discount,
      this.tax,
      this.totalAmount,
      this.paymentType,
      this.paymentStatus,
      this.orderStatus,
      this.orderDate,
      this.dishes,
      this.dishesName,
      this.orderTypeDesc,
      this.orderStatusColorCode,
      this.orderStatusDesc,
      this.isCancelButtonToShow,
      this.fromLocation,
      this.initialDeliveryTime,
      this.modifiedDeliveryTime,
      this.kotPath,
      this.billPath});

  String timeOnly() {
    String req = '';
    if (modifiedDeliveryTime != '') {
      DateTime dateTime = DateTime.parse(modifiedDeliveryTime);
      req = formatDate(dateTime, [
        HH,
        ':',
        nn,
      ]);
    }

    return req;
  }
}
