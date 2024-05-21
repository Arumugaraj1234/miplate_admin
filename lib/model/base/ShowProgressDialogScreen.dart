import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'HexColor.dart';

class ShowProgressDialogScreen extends ProgressDialog {

  ShowProgressDialogScreen(BuildContext context) : super(context);

  static ProgressDialog showLoading(final String message,final bool isShowing,final BuildContext context) {
    ProgressDialog progressDialog = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    if(isShowing){
      progressDialog.update(
        progress: 50.0,
        message: message,
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: HexColor("#387086"), fontSize: 14,
            fontFamily: 'Avenir Next',
            fontWeight: FontWeight.w600),
        messageTextStyle: TextStyle(
            color: HexColor("#387086"), fontSize: 14,
            fontFamily: 'Avenir Next',
            fontWeight: FontWeight.w600),
      );
      progressDialog.show();
    }else{
      progressDialog.hide();
    }
    return progressDialog;
  }

}