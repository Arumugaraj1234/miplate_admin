import 'package:flutter/material.dart';
import 'model/order_details_model.dart';

const kTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'Roboto Regular',
    fontWeight: FontWeight.w500);

class OrderHistoryWidgetOne extends StatelessWidget {
  final OrderDetailsModel orderDetails;
  final Function onCancelBtnPressed;
  final Function onTrackBtnPressed;
  final Function onOrderAgainPressed;
  final Function onRateFoodBtnPressed;
  final Function onItemSelected;
  final bool isButtonToShow;

  OrderHistoryWidgetOne(
      {this.orderDetails,
      this.onCancelBtnPressed,
      this.onTrackBtnPressed,
      this.onOrderAgainPressed,
      this.onRateFoodBtnPressed,
      this.onItemSelected,
      this.isButtonToShow});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: onItemSelected,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          orderDetails.orderDate,
                          style: kTextStyle.copyWith(
                              color: Colors.black, fontSize: 16.0),
                        )),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Text(
                            '#${orderDetails.orderId}',
                            textAlign: TextAlign.end,
                            style: kTextStyle.copyWith(
                                color: Colors.black, fontSize: 16.0),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '£${orderDetails.totalAmount.toStringAsFixed(2)}',
                          style: kTextStyle.copyWith(
                              color: Colors.black, fontSize: 20.0),
                        ),
                        Text(
                          ' - ${orderDetails.orderTypeDesc}',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: kTextStyle.copyWith(
                              color: Colors.black87, fontSize: 14.0),
                        ),
                        Text(
                          '',
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                          softWrap: false,
                          style: kTextStyle.copyWith(
                              color: Colors.black,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Container(
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: false,
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.deepOrange, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            child: FlatButton(
                                onPressed: onCancelBtnPressed,
                                child: Text(
                                  'Decline',
                                  style: kTextStyle.copyWith(
                                      color: Colors.black, fontSize: 18.0),
                                )),
                          ),
                        ),
                        /*SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.green, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            child: FlatButton(
                                onPressed: onTrackBtnPressed,
                                child: Text(
                                  'Check Status',
                                  style: kLabelTextStyle.copyWith(
                                      color: Colors.black, fontSize: 18.0),
                                )),
                          ),
                        )*/
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isButtonToShow,
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.green, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            child: FlatButton(
                                onPressed: onOrderAgainPressed,
                                child: Text(
                                  'ACCEPT',
                                  style: kTextStyle.copyWith(
                                      color: Colors.black, fontSize: 18.0),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.red, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0))),
                            child: FlatButton(
                                onPressed: onRateFoodBtnPressed,
                                child: Text(
                                  'DECLINE',
                                  style: kTextStyle.copyWith(
                                      color: Colors.black, fontSize: 18.0),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
