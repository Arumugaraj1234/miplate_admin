import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/base/HexColor.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/network_services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class OrderTypeScreen extends StatefulWidget {
  @override
  _OrderTypeScreenState createState() => _OrderTypeScreenState();
}

class _OrderTypeScreenState extends State<OrderTypeScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataServices>(builder: (context, dataServices, child) {
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
              child: Text('Order Type'),
            ),
          ),
        ),
        body: Container(
          color: Colors.grey,
          child: Column(
            children: [
              Container(
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
                      /*new Expanded(
                        flex: 3,
                        child: new Container(
                          margin: EdgeInsets.only(bottom: 2),
                          alignment: Alignment.center,
                          child: Container(
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
                          ),
                        ),
                      ),*/
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
                              child: Text('Delivery',
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
                      ),
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
                                          dataServices.deliveryToggle.status ==
                                                  1
                                              ? true
                                              : false,
                                      onChanged: (bool value) async {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Please wait...');
                                        await dialog.show();
                                        int v = value ? 1 : 0;
                                        ResponseModel response =
                                            await NetworkServices.shared
                                                .updateToggleStatus(
                                                    type: 3, status: v);
                                        dialog.hide();
                                        _showSnackBar(response.message);
                                        if (response.code == 1) {
                                          dataServices
                                              .updateDeliveryToggleStatus(v);
                                        }
                                      }),
                                )
                              ]))
                    ],
                  ),
                ),
              ),
              Container(
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
                      /*new Expanded(
                        flex: 3,
                        child: new Container(
                          margin: EdgeInsets.only(bottom: 2),
                          alignment: Alignment.center,
                          child: Container(
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
                          ),
                        ),
                      ),*/
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
                              child: Text('Collection',
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
                      ),
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
                                      value: dataServices
                                                  .collectionToggle.status ==
                                              1
                                          ? true
                                          : false,
                                      onChanged: (bool value) async {
                                        ProgressDialog dialog =
                                            new ProgressDialog(context);
                                        dialog.style(message: 'Please wait...');
                                        await dialog.show();
                                        int v = value ? 1 : 0;
                                        ResponseModel response =
                                            await NetworkServices.shared
                                                .updateToggleStatus(
                                                    type: 2, status: v);
                                        dialog.hide();
                                        _showSnackBar(response.message);
                                        if (response.code == 1) {
                                          dataServices
                                              .updateCollectionToggleStatus(v);
                                        }
                                      }),
                                )
                              ]))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
