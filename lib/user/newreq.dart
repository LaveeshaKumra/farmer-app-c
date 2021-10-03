import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/addtask.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart';
import 'dart:convert';

class AddReq extends StatefulWidget {
  var email, company, name;
  AddReq(e, n, c) {
    this.email = e;
    this.name = n;
    this.company = c;
  }
  @override
  _AddReqState createState() =>
      _AddReqState(this.email, this.name, this.company);
}

class _AddReqState extends State<AddReq> {
  var email, _type, company, name;
  _AddReqState(e, n, c) {
    this.email = e;
    this.name = n;
    this.company = c;
  }
  List<String> _leavetype = ["Sick Leave", "Day Off", "Others"];
  var _progress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _success;

  TextEditingController _textEditingController = TextEditingController();
  DateTime _startdate = DateTime.now();
  DateTime _enddate = DateTime.now();
var noleaves=false;
  _showdialog() {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.TOPSLIDE,
      title: 'Leave Request Sent Successfully',
      desc: 'We Have Sent Your Request to manager!',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    )..show();
  }
  _showdialog2(str) {
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.TOPSLIDE,
      title: 'Request Denied',
      desc: 'You have already applied leaves for $str',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {
        // Navigator.pop(context);
      },
    )..show();
  }

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _startdate != null ? _startdate : DateTime.now(),
        firstDate:DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 1),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Theme.of(context).primaryColor,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey[100],
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      setState(() {
        _startdate = newSelectedDate;
      });
      _textEditingController
        ..text = DateFormat.yMMMd().format(_startdate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  TextEditingController _textEditingController2 = TextEditingController();

  _selectDate2(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _enddate != null ? _enddate : DateTime.now(),
        firstDate:DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 1),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Theme.of(context).primaryColor,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.grey[100],
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      setState(() {
        _enddate = newSelectedDate;
      });

      _textEditingController2
        ..text = DateFormat.yMMMd().format(_enddate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _textEditingController2.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  _convertdate(d) {
    final DateFormat formatter = DateFormat('dd MMMM,yy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  var serverToken =
      "AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification() async {
    var topic = 'admin$company';
    var topic2 = topic.replaceAll(' ', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization": "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "New Leave Request from $name",
          "body":
              "From ${_convertdate(_startdate)} to ${_convertdate(_enddate)}",
          "sound": "default",
          "tag": "New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "TimeoffAdmin",
        },
        "priority": "high",
        "to": '/topics/${topic2}',
      };
      var client = new Client();
      var response =
          await client.post(url, headers: header, body: json.encode(request));

      return true;
    } catch (e, s) {
      return false;
    }
  }

  addwork() async {
    setState(() {
      _progress = true;
    });

    final databaseReference = FirebaseFirestore.instance;
    var date_array=[],leave_array=[],common_dates=[];
    databaseReference
        .collection("timeoff")
        .where('email', isEqualTo: email).get().then((value) async {
          for(int i=0;i<value.docs.length;i++){
            DateTime sd=DateTime(value.docs[i]['start_date'].toDate().year,value.docs[i]['start_date'].toDate().month,value.docs[i]['start_date'].toDate().day,0,0,0,0);
            DateTime ed=DateTime(value.docs[i]['end_date'].toDate().year,value.docs[i]['end_date'].toDate().month,value.docs[i]['end_date'].toDate().day+1,0,0,0,0);
            while(ed.isAfter(sd)){
              date_array.add(sd);
              sd=sd.add(Duration(days: 1));
            }
          }
          DateTime sd1=DateTime(_startdate.year,_startdate.month,_startdate.day,0,0,0,0);
          DateTime ed1=DateTime(_enddate.year,_enddate.month,_enddate.day+1,0,0,0,0);
          while(ed1.isAfter(sd1)){
            leave_array.add(sd1);
            sd1=sd1.add(Duration(days: 1));
          }

          if (date_array.length > 0 && leave_array.length > 0) {
            Set<DateTime> firstSet = new Set<DateTime>();
            for (int i = 0; i < date_array.length; i++) {
              firstSet.add(date_array[i]);
            }

            // Iterate the elements of the arr2
            for (int j = 0; j < leave_array.length; j++) {
              if (firstSet.contains(leave_array[j])) {
                common_dates.add(leave_array[j]);
              }
            }
          }
          if(common_dates.length>0){
            var f= DateFormat('dd MMMM yy');
            var str='';
            for(int i=0;i<common_dates.length;i++){
              str=str+'\n'+f.format(common_dates[i]);
            }
            _showdialog2(str);

          }
          else{
              await databaseReference.collection("timeoff").add({
                'email': email,
                'title': _title.text,
                'description': _description.text,
                'company': company,
                'username': name,
                "end_date": _enddate,
                "start_date": _startdate,
                "status": "Pending",
                "leavetype":_type
              }).then((value) async {
                _sendnotification();
                setState(() {
                  _progress = false;
                });

                _showdialog();
              });

          }

    });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Request"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)), //here
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Material(
                      color: Colors.grey[200],
                      elevation: 2.0,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: TextFormField(
                        controller: _title,
                        validator: (var value) {
                          if (value.isEmpty) {
                            return 'Please enter a valid subject';
                          }
                          return null;
                        },
                        cursorColor: Theme.of(context).primaryColor,
                        decoration: InputDecoration(
                            hintText: "Leave Subject",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 13)),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .where('email', isEqualTo: email)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          var numberofleaves;
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("...");
                          }
                          var x=[];
                          var map=snapshot.data.docs[0]
                              .data()['leaveEnt'];
                          var keys=snapshot.data.docs[0]
                              .data()['leaveEnt'].keys;
                          keys.forEach((v){x.add(v);});
                          return Column(
                            children: [
                              Material(
                                color: Colors.grey[200],
                                elevation: 2.0,
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    hint: Text('Leave Type'),
                                    value: _type,
                                    items: x
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _type = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              _type==null?Container():SizedBox(
                                height: 20,
                              ),
                              _type==null?Container():StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("timeoff")
                                      .where('email', isEqualTo: email)
                                      .where("status", isEqualTo: "Accepted")
                                      .where("leavetype", isEqualTo: _type)
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot2) {
                                    if (snapshot.hasError) {
                                      return Text('Something went wrong');
                                    }

                                    if (snapshot2.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text("...");
                                    }

                                    var leaves = snapshot2.data.docs.length;
                                    if(map[_type]=="0"){
                                      return Column(
                                        children: [
                                          _type==null?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null?Container():Image.asset("assets/icons/sad.png",width: 80,),
                                          _type==null?Container():Text("You Can't Apply For $_type",style: TextStyle(fontSize: 18),),
                                          _type==null?Container():Text("Contact Your Manager",style: TextStyle(fontSize: 18),)

                                        ],
                                      );
                                    }
                                    if (leaves == 0) {
                                      numberofleaves=int.parse(map[_type])-1;
                                      return Column(
                                        children: [
                                          Text(
                                              "${map[_type]} / ${map[_type]} days leave remaining"),
                                          _type==null || numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():Material(
                                            color: Colors.grey[200],
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: TextFormField(
                                              validator: (var value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter a valid date';
                                                }
                                                return null;
                                              },
                                              //focusNode: AlwaysDisabledFocusNode(),
                                              controller: _textEditingController,
                                              onTap: () {
                                                _selectDate(context);
                                              },

                                              cursorColor: Theme.of(context).primaryColor,
                                              decoration: InputDecoration(
                                                  hintText: "Starting Date",
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 13)),
                                            ),
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null||numberofleaves==0 || int.parse(map[_type])==0?Container():Material(
                                            color: Colors.grey[200],
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: TextFormField(
                                              validator: (var value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter a valid date';
                                                }
                                                var d=_enddate.difference(_startdate).inDays+1;
                                                if(d>numberofleaves){
                                                  return "Can't apply more than $numberofleaves day leave";
                                                }
                                                return null;
                                              },
                                              //focusNode: AlwaysDisabledFocusNode(),
                                              controller: _textEditingController2,
                                              onTap: () {
                                                _selectDate2(context);
                                              },

                                              cursorColor: Theme.of(context).primaryColor,
                                              decoration: InputDecoration(
                                                  hintText: "Ending Date",
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 13)),
                                            ),
                                          ),
                                          _type==null||numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():Material(
                                            color: Colors.grey[200],
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: TextFormField(
                                              controller: _description,
                                              cursorColor: Theme.of(context).primaryColor,
                                              minLines: 3,
                                              maxLines: 20,
                                              decoration: InputDecoration(
                                                  hintText: "Notes",
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 13)),
                                            ),
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():RoundedButton(
                                            text: "Apply Now",
                                            state: _progress,
                                            color:Theme.of(context).primaryColor,
                                            press: () {
                                              if (_formKey.currentState.validate()) {
                                                setState(() {
                                                  _progress = true;
                                                });
                                                addwork();
                                              }
                                              // }
                                            },
                                          ),
                                        ],
                                      );
                                    }

                                    else {
                                      var days, hours = 0;
                                      for (var i = 0; i < leaves; i++) {
                                        hours += snapshot2.data.docs[i]
                                            .data()['end_date']
                                            .toDate()
                                            .difference(snapshot2.data.docs[i]
                                            .data()['start_date']
                                            .toDate())
                                            .inDays;
                                      }
                                      days = hours+1;
                                      numberofleaves=int.parse(map[_type]) - days.ceil();
                                      return Column(
                                        children: [
                                          Text(
                                              "${int.parse(map[_type]) - days.ceil()} / ${map[_type]} days leave remaining"),
                                          _type==null|| numberofleaves>0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null || numberofleaves>0?Container():Image.asset("assets/icons/sad.png",width: 80,),
                                          _type==null|| numberofleaves>0?Container():Text("You Can't Apply For $_type",style: TextStyle(fontSize: 18),),
                                          _type==null|| numberofleaves>0?Container():Text("Contact Your Manager",style: TextStyle(fontSize: 18),),


                                          _type==null || numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():Material(
                                            color: Colors.grey[200],
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: TextFormField(
                                              validator: (var value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter a valid date';
                                                }
                                                return null;
                                              },
                                              //focusNode: AlwaysDisabledFocusNode(),
                                              controller: _textEditingController,
                                              onTap: () {
                                                _selectDate(context);
                                              },

                                              cursorColor: Theme.of(context).primaryColor,
                                              decoration: InputDecoration(
                                                  hintText: "Starting Date",
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 13)),
                                            ),
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null||numberofleaves==0 || int.parse(map[_type])==0?Container():Material(
                                            color: Colors.grey[200],
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: TextFormField(
                                              validator: (var value) {
                                                if (value.isEmpty) {
                                                  return 'Please enter a valid date';
                                                }
                                                var d=_enddate.difference(_startdate).inDays+1;
                                                if(d>numberofleaves){
                                                  return "Can't apply more than $numberofleaves day leave";
                                                }
                                                return null;
                                              },
                                              //focusNode: AlwaysDisabledFocusNode(),
                                              controller: _textEditingController2,
                                              onTap: () {
                                                _selectDate2(context);
                                              },

                                              cursorColor: Theme.of(context).primaryColor,
                                              decoration: InputDecoration(
                                                  hintText: "Ending Date",
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 13)),
                                            ),
                                          ),
                                          _type==null||numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():Material(
                                            color: Colors.grey[200],
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: TextFormField(
                                              controller: _description,
                                              cursorColor: Theme.of(context).primaryColor,
                                              minLines: 3,
                                              maxLines: 20,
                                              decoration: InputDecoration(
                                                  hintText: "Notes",
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 25, vertical: 13)),
                                            ),
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():SizedBox(
                                            height: 20,
                                          ),
                                          _type==null|| numberofleaves==0 || int.parse(map[_type])==0?Container():RoundedButton(
                                            text: "Apply Now",
                                            state: _progress,
                                            color:Theme.of(context).primaryColor,
                                            press: () {
                                              if (_formKey.currentState.validate()) {
                                                setState(() {
                                                  _progress = true;
                                                });
                                                addwork();
                                              }
                                              // }
                                            },
                                          ),
                                        ],
                                      );
                                    }


                                  }),


                            ],
                          );
                        }),

                    Container(
                      alignment: Alignment.center,
                      child: Text(_success == null
                          ? ''
                          : (_success
                              ? 'Request Successfully Sent'
                              : ' failed')),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

