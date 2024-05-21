import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:miplate/model/Timings.dart';
import 'package:intl/intl.dart';
import 'package:miplate/model/response_model.dart';
import 'package:miplate/network_services.dart';
import 'package:progress_dialog/progress_dialog.dart';

const kTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'Roboto Regular',
    fontWeight: FontWeight.w500);

class UpdateTimingScreen extends StatefulWidget {
  final Timings timings;

  UpdateTimingScreen({this.timings});
  @override
  _UpdateTimingScreenState createState() => _UpdateTimingScreenState();
}

class _UpdateTimingScreenState extends State<UpdateTimingScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: Colors.green, content: new Text(text)));
  }

  bool _isDatePickerToShow = false;

  String _startTime = '';
  String _endTime = '';
  int _flag = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _startTime = widget.timings.start_time;
      _endTime = widget.timings.end_time;
    });
  }

  String getStringFromDate(DateFormat required, DateTime date) {
    DateFormat reqFormat = required;
    return reqFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
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
            child: Text(widget.timings.name),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Start Time',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Avenir Next',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: () async {
                            TimeOfDay initialTime = TimeOfDay.now();
                            TimeOfDay pickedTime = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                            );
                            print(pickedTime);
                            String t =
                                '${pickedTime.hour}:${pickedTime.minute}:00';
                            print(t);

                            setState(() {
                              _flag = 0;
                              _startTime = t;
                              //_isDatePickerToShow = !_isDatePickerToShow;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _startTime,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Avenir Next',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'End Time',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Avenir Next',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: () async {
                            TimeOfDay initialTime = TimeOfDay.now();
                            TimeOfDay pickedTime = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                            );
                            print(pickedTime);
                            String t =
                                '${pickedTime.hour}:${pickedTime.minute}:00';
                            print(t);
                            setState(() {
                              _flag = 1;
                              //_isDatePickerToShow = !_isDatePickerToShow;
                              _endTime = t;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _endTime,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Avenir Next',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down)
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    ProgressDialog dialog = new ProgressDialog(context);
                    dialog.style(message: 'Please wait...');
                    await dialog.show();
                    ResponseModel response = await NetworkServices.shared
                        .updateTimings(
                            timingId: widget.timings.meal_id,
                            hotelId: 1,
                            name: widget.timings.name,
                            startTime: _startTime,
                            endTime: _endTime);
                    dialog.hide();

                    if (response.code == 1) {
                      Timings tim = widget.timings;
                      tim.start_time = _startTime;
                      tim.end_time = _endTime;
                      _showSnackBar(response.message);
                      Navigator.pop(context, tim);
                    } else {
                      _showSnackBar(response.message);
                    }
                  },
                  child: Container(
                    height: 40,
                    color: Colors.deepOrangeAccent,
                    child: Center(
                      child: Text(
                        'UPDATE',
                        style: kTextStyle.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: _isDatePickerToShow,
            child: Container(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        color: Colors.transparent,
                      ),
                      onTap: () {
                        setState(() {
                          _isDatePickerToShow = false;
                        });
                      },
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    color: Colors.grey.shade200,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.black,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CupertinoButton(
                                child: Text(
                                  'Done',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Avenir Next',
                                      fontWeight: FontWeight.w400),
                                ),
                                onPressed: () {
                                  //Navigator.pop(context);
                                  print('Hi');
                                  setState(() {
                                    _isDatePickerToShow = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            //minuteInterval: 15,
                            use24hFormat: true,
                            maximumDate: DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                22,
                                0),
                            onDateTimeChanged: (startTime) {
                              setState(() {
                                String a = getStringFromDate(
                                    DateFormat("HH:mm:ss"), startTime);
                                print(a);
                                if (_flag == 0) {
                                  setState(() {
                                    _startTime = a;
                                  });
                                } else {
                                  setState(() {
                                    _endTime = a;
                                  });
                                }
                                // // _currentHour = startTime;
                                // _deliveryTime = getStringFromDate(
                                //     DateFormat("hh:mm a"), startTime);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
