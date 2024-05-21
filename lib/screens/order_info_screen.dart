import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:miplate/model/order_details_model.dart';
import 'package:miplate/order_history_widget.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:miplate/screens/Print_Screen.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'dart:ui' as ui;

class OrderInfoScreen extends StatefulWidget {
  final OrderDetailsModel orderDetails;

  OrderInfoScreen({this.orderDetails});

  @override
  _OrderInfoScreenState createState() => _OrderInfoScreenState();
}

class _OrderInfoScreenState extends State<OrderInfoScreen> {
  bool isSpinnerToShow = false;
  void updateSpinnerStatus(bool status) {
    setState(() {
      isSpinnerToShow = status;
    });
  }

  GlobalKey _globalKey = new GlobalKey();

  String imageName = 'emptyCircle.png';
  String paymentStatusDesc = 'Not Paid Yet';

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.orderDetails.orderStatus == 1 ||
          widget.orderDetails.orderStatus == 2) {
        imageName = 'emptyCircle.png';
      } else if (widget.orderDetails.orderStatus == 3 ||
          widget.orderDetails.orderStatus == 4) {
        imageName = 'dotCircle.png';
      } else {
        imageName = 'rightCircle.png';
        if (widget.orderDetails.paymentType == 1) {
          paymentStatusDesc = 'Paid via cash';
        } else {
          paymentStatusDesc = 'Paid via Paypal';
        }
      }
    });
  }

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return PrintScreen(byteData);
        }),
      );
      // var pngBytes = byteData.buffer.asUint8List();
      // var bs64 = base64Encode(pngBytes);
      // print(pngBytes);
      // print(bs64);
      // setState(() {});
      // return pngBytes;
    } catch (e) {
      showAlertDialog(context, e.toString());
    }
  }

  showAlertDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Scaffold(
        body: Container(
          child: Stack(
            children: <Widget>[
              Container(
                constraints: BoxConstraints.expand(),
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 50.0,
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black,
                                    size: 30.0,
                                  ),
                                )),
                            Expanded(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Order #${widget.orderDetails.orderId}',
                                style: kTextStyle.copyWith(
                                    color: Colors.black, fontSize: 22.0),
                              ),
                            )),
                            Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    _capturePng();
                                  },
                                  child: Icon(
                                    Icons.print,
                                    color: Colors.black,
                                    size: 30.0,
                                  ),
                                ))
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0))),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 150.0,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0)),
                                ),
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.orderDetails.orderDate,
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  widget.orderDetails
                                                      .orderTypeDesc,
                                                  overflow: TextOverflow.fade,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        height: 54.0,
                                        child: Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 9.0,
                                                ),
                                                Container(
                                                  height: 6.0,
                                                  width: 6.0,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(
                                                  height: 2.0,
                                                ),
                                                Container(
                                                  height: 20.0,
                                                  width: 10.0,
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        width: 4.0,
                                                      ),
                                                      Dash(
                                                        direction:
                                                            Axis.vertical,
                                                        dashColor: Colors.black,
                                                        length: 20.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2.0,
                                                ),
                                                Container(
                                                  height: 6.0,
                                                  width: 6.0,
                                                  color: Colors.red,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Expanded(
                                              child: Column(children: <Widget>[
                                                Flexible(
                                                  child: Container(
                                                    height: 24.0,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        widget.orderDetails
                                                            .fromLocation,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        maxLines: 1,
                                                        softWrap: false,
                                                        style:
                                                            kTextStyle.copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 6.0,
                                                ),
                                                Flexible(
                                                  child: Container(
                                                    height: 24.0,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        widget.orderDetails
                                                                    .deliveryAddress ==
                                                                ''
                                                            ? '---'
                                                            : widget
                                                                .orderDetails
                                                                .deliveryAddress,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        maxLines: 1,
                                                        softWrap: false,
                                                        style:
                                                            kTextStyle.copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ]),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        height: 25.0,
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              child: Image.asset(
                                                  'assets/images/$imageName'),
                                              width: 25.0,
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  widget.orderDetails
                                                      .orderStatusDesc,
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.orange,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 25.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        height: 50.0,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Items',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                            )),
                                            Container(
                                              width: 100.0,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  'Price',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Dash(
                                        direction: Axis.horizontal,
                                        dashColor: Colors.black,
                                        length:
                                            MediaQuery.of(context).size.width -
                                                50,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: ListView(
                                              children: List.generate(
                                                  widget.orderDetails.dishes
                                                      .length, (int index) {
                                            return Container(
                                              height: 35.0,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      child: Container(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        '${widget.orderDetails.dishes[index].name} x ${widget.orderDetails.dishes[index].count}',
                                                        style:
                                                            kTextStyle.copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18.0),
                                                      ),
                                                    ),
                                                  )),
                                                  Container(
                                                    width: 100.0,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        '\$${widget.orderDetails.dishes[index].totalPrice.toStringAsFixed(2)}',
                                                        style:
                                                            kTextStyle.copyWith(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18.0),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          })),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Dash(
                                        direction: Axis.horizontal,
                                        dashColor: Colors.black,
                                        length:
                                            MediaQuery.of(context).size.width -
                                                50,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        height: 25.0,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Items Total',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            )),
                                            Container(
                                              width: 100.0,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '\$${widget.orderDetails.amount.toStringAsFixed(2)}',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 25.0,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Discount',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            )),
                                            Container(
                                              width: 100.0,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '\$${widget.orderDetails.discount.toStringAsFixed(2)}',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 25.0,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Taxes',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            )),
                                            Container(
                                              width: 100.0,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '\$${widget.orderDetails.tax.toStringAsFixed(2)}',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black87,
                                                      fontSize: 16.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        height: 0.5,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Container(
                                        height: 35.0,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Total',
                                                      style:
                                                          kTextStyle.copyWith(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18.0),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        ' - $paymentStatusDesc',
                                                        style:
                                                            kTextStyle.copyWith(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14.0),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Container(
                                              width: 100.0,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '\$${widget.orderDetails.totalAmount.toStringAsFixed(2)}',
                                                  style: kTextStyle.copyWith(
                                                      color: Colors.black,
                                                      fontSize: 18.0),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                child: Container(
                  color: Colors.black.withAlpha(0),
                ),
                visible: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
