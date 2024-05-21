import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/base/Constants.dart';
import 'package:miplate/model/dish_detail_model.dart';
import 'package:miplate/model/order_details_model.dart';
import 'package:miplate/model/response_model.dart';
import 'package:http/http.dart' as http;
import 'package:miplate/model/toggle_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class NetworkServices {
  static final NetworkServices shared = NetworkServices();

  Future<ResponseModel> updateTimings(
      {int timingId,
      int hotelId,
      String name,
      String startTime,
      String endTime}) async {
    ResponseModel responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['timing_id'] = timingId;
      params['hotel_id'] = hotelId;
      params['name'] = name;
      params['start_time'] = startTime;
      params['end_time'] = endTime;
      print(params);

      var body = json.encode(params);
      print(body);
      http.Response response =
          await http.post(kUrlToSaveTimings, headers: kHeader, body: body);

      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        responseValue = ResponseModel(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = ResponseModel(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = ResponseModel(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<ResponseModel> getToggleDetails({BuildContext context}) async {
    ResponseModel responseValue;
    try {
      http.Response response =
          await http.post(kUrlToGetToggleStatus, headers: kHeader);

      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        var resData = jsonData['Data'];
        for (var res in resData) {
          int type = res['type'];
          int flgStatus = res['flg'];
          String name = res['name'];

          ToggleModel tM = ToggleModel(name: name, id: type, status: flgStatus);

          if (type == 1) {
            Provider.of<DataServices>(context, listen: false)
                .setRestaurantToggle(tM);
          } else if (type == 2) {
            Provider.of<DataServices>(context, listen: false)
                .setCollectionToggle(tM);
          } else if (type == 3) {
            Provider.of<DataServices>(context, listen: false)
                .setDeliveryToggle(tM);
          }
        }
        responseValue = ResponseModel(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = ResponseModel(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = ResponseModel(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<ResponseModel> updateToggleStatus({
    int type,
    int status,
  }) async {
    ResponseModel responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['type'] = type;
      params['flg'] = status;
      print(params);

      var body = json.encode(params);
      print(body);
      http.Response response = await http.post(kUrlToUpdateToggleStatus,
          headers: kHeader, body: body);

      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        responseValue = ResponseModel(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = ResponseModel(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = ResponseModel(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<ResponseModel> completeOrder(
      {int orderId, int paymentType, int index, BuildContext context}) async {
    ResponseModel responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['order_id'] = orderId;
      params['payment_type'] = paymentType;
      print(params);

      var body = json.encode(params);
      print(body);
      http.Response response =
          await http.post(kUrlToCompleteOrder, headers: kHeader, body: body);

      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          Provider.of<DataServices>(context, listen: false)
              .removeOrderFromCurrentOrder(index);
        }
        responseValue = ResponseModel(
            code: responseCode, message: responseMessage, data: null);
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = ResponseModel(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = ResponseModel(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  Future<ResponseModel> getAllCurrentOrders(
      {int orderType, BuildContext context}) async {
    ResponseModel responseValue;
    try {
      var params = new Map<String, dynamic>();
      params['hotel_id'] = 1;
      params['type'] = orderType;
      print(params);

      var body = json.encode(params);
      http.Response response = await http.post(kUrlToGetAllCurrentOrders,
          headers: kHeader, body: body);

      String data = response.body;
      var jsonData = jsonDecode(data);
      if (response.statusCode == 200) {
        int responseCode = jsonData['Code'];
        String responseMessage = jsonData['Message'];
        if (responseCode == 1) {
          List<OrderDetailsModel> orders = [];
          var orderDetails = jsonData['Data'];
          for (var order in orderDetails) {
            int orderId = order['order']['order_id'];

            int hotelId = order['order']['hotel_id'];
            int supplierId = order['order']['supplier_id'];

            int tableId = order['order']['table_id'];
            int orderType = order['order']['order_type'];

            String deliveryAddress = order['order']['delivery_address'];
            double deliveryLat = order['order']['delivery_lat'];
            double deliveryLon = order['order']['delivery_lon'];
            double baseAmount = order['order']['amount'];
            double discount = order['order']['discount'];
            double tax = order['order']['tax'];
            double totalAmount = order['order']['total'];
            int paymentType = order['order']['payment_type'];
            int paymentStatus = order['order']['payment_status'];
            int orderStatus = order['order']['order_status'];
            String orderStatusDesc = order['order_status'];
            String fromLocation = order['hotel_name'];
            String kotPath = order['kot_path'] ?? '';
            String billPath = order['bill_path'] ?? '';

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

            var serverDate = order['order']['order_date'];

            String orderDate = changeDateFormata(serverDate);
            var orderedItems = order['items'];
            String orderTypeDesc = '';
            var dT = order['order']['delivery_time'];
            print(dT);
            String deliveryTime = '';
            if (dT != null && dT != '') {
              deliveryTime = changeDateFormatOne(dT);
            }

            switch (orderType) {
              case 1:
                orderTypeDesc = 'Table';
                break;
              case 2:
                orderTypeDesc = 'Collection';
                break;
              case 3:
                orderTypeDesc = 'Delivery';
                break;
              case 4:
                orderTypeDesc = 'Curbside';
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

            orders.add(oM);
          }
          Provider.of<DataServices>(context, listen: false)
              .setCurrentOrders(orders);
          responseValue = ResponseModel(
              code: responseCode, message: responseMessage, data: orders);
        } else {
          responseValue = ResponseModel(
              code: responseCode, message: responseMessage, data: null);
        }
      } else {
        // The response code is not 200.
        String message = jsonData['Message'];
        responseValue = ResponseModel(code: 0, message: message, data: null);
      }
    } catch (e) {
      // The webservice throws an error.
      String err = e.toString();
      responseValue = ResponseModel(code: 0, message: err, data: null);
    }
    return responseValue;
  }

  String changeDateFormat(DateTime serverDate) {
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    final String formatted = formatter.format(serverDate);
    return formatted;
  }

  String changeDateFormata(String serverDate) {
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
}
