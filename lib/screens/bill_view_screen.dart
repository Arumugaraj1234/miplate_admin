import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miplate/data_services.dart';
import 'package:miplate/model/order_details_model.dart';
import 'package:miplate/screens/Print_Screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui' as ui;

class BillViewScreen extends StatefulWidget {
  final OrderDetailsModel order;
  final int flag;

  BillViewScreen({this.order, this.flag});
  @override
  _BillViewScreenState createState() => _BillViewScreenState();
}

class _BillViewScreenState extends State<BillViewScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey _globalKey = new GlobalKey();

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
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
      child: Scaffold(
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
              child: Text(widget.flag == 1 ? 'BILL' : 'KOT'),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.print,
                color: Colors.white,
              ),
              onPressed: () {
                _capturePng();
              },
            )
          ],
        ),
        body: Container(
          child: WebView(
            initialUrl:
                widget.flag == 1 ? widget.order.billPath : widget.order.kotPath,
          ),
        ),
      ),
      key: _globalKey,
    );
  }
}
