import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart';


class AddTask extends StatefulWidget {
  var email,company;
  AddTask(e,c){this.email=e;this.company=c;}
  @override
  _AddTaskState createState() => _AddTaskState(this.email,this.company);
}

class _AddTaskState extends State<AddTask> {
  var email,company,_assignedto;
  _AddTaskState(e,c){this.email=e;this.company=c; _getallworkers();print(company);print(email);}
  var _progress=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool _success;



  //final String serverToken = 'AAAAkgw6AJk:APA91bGRPBagwJydmgRcvUNkr0KHx6jo6GMaJ67NWguNw3fOrMBz--9TC4btXxO1q1_RIxqUXz8VWUm-LRgTaR_WHr-02iCS1Aibtiatk4bxlSRiBg9PL-tDT3udvDnbxyxRA2IhEEr7';
  //final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

 sendAndRetrieveMessage(topic) async {
    // // var t2=topic.replaceAll('.', "");
    // // var t3=t2.replaceAll(new RegExp(r"\s+"), "");
    // //
    // // await firebaseMessaging.requestNotificationPermissions(
    // //   const IosNotificationSettings(sound: true, badge: true, alert: true),
    // // );
    // try {
    //   var url = 'https://fcm.googleapis.com/fcm/send';
    //   var header = {
    //     "Content-Type": "application/json",
    //     "Authorization":
    //     "key=$serverToken",
    //   };
    //   var request = {
    //     "notification": {
    //       "title": "New Task uploaded",
    //       "text": _title.text,
    //       "sound": "default",
    //       "tag":"New Task Updates from Farmer"
    //     },
    //     "data": {
    //       "click_action": "FLUTTER_NOTIFICATION_CLICK",
    //       "screen": "OPEN_HOMEWORK_PAGE",
    //     },
    //     "priority": "high",
    //     "to": '/topics/$email',
    //   };
    // //
    //    var client = new Client();
    //   var response =
    //   await client.post(url, headers: header, body: json.encode(request));
    //   print(response.body);
    //   print(response.statusCode);
    //   return true;
    // } catch (e, s) {
    //   print(e);
    //   return false;
    //  }
  }

  TextEditingController _textEditingController = TextEditingController();
  DateTime _startdate=DateTime.now();
  DateTime _enddate=DateTime.now();

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _startdate != null ? _startdate : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.teal,
                onPrimary: Colors.white,
                surface: Colors.teal,
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
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.teal,
                onPrimary: Colors.white,
                surface: Colors.teal,
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

  addwork() async {
    setState(() {
      _progress=true;
    });
    print(_enddate.runtimeType);
    print(_startdate.runtimeType);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("tasks")
        .add({
      'title': _title.text,
      'description':_description.text,
      'company':company,
      'assigned_by':email,
      'assigned_to':_assignedto,
      "end_date":_enddate,
      "start_date":_startdate,
      "start_time":_starttime.format(context),
      "end_time":_endtime.format(context),
      "status":"Pending"
    }).then((value) async {
      print(value);
      //await sendAndRetrieveMessage('${list1[i]}-Vrinda');
      setState(() {
        _progress=false;
      });
    });


    Toast.show("Task is uploaded",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);

  }

var allnames,allemails;
  List<DropdownMenuItem> items = [];
  _getallworkers() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('company',isEqualTo: company).where('status',isEqualTo: 'Accepted').where('role',isEqualTo: 'farmer').get().then(
            (value) {val = value;
        });
    int length=val.docs.length;
    print(length);
    for(int i=0;i<length;i++){
      setState(() {
        items.add(DropdownMenuItem(
          child: Text(val.docs[i]['username']),
          value: val.docs[i]['email'],
        ));
      });
    }

  }
  TimeOfDay _starttime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endtime = TimeOfDay(hour: 18, minute: 0);

  void _selectstartingtime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      helpText: "Starting Time",
      initialTime: _starttime,
    );
    if (newTime != null) {
      setState(() {
        _starttime = newTime;
      });
    }
  }
  void _selectendingtime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      helpText: "Ending Time",
      initialTime: _endtime,
    );
    if (newTime != null) {
      setState(() {
        _endtime = newTime;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Tasks"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(
            children: <Widget>[
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
                      return 'Please enter a valid title';
                    }
                    return null;
                  },
                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                      hintText: "Task Title",

                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.grey[200],
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: TextFormField(
                  controller: _description,
                  cursorColor: Colors.teal,
                  minLines: 1,
                  maxLines: 20,
                  decoration: InputDecoration(
                      hintText: "Task Description",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Material(
                color: Colors.grey[200],
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(5)),
                // child:  SearchableDropdown.single(
                //   items: items,
                //   value: _assignedto,
                //   hint: "Assign Task To",
                //   searchHint: null,
                //   onChanged: (value) {
                //     setState(() {
                //       _assignedto = value;
                //     });
                //   },
                //   dialogBox: false,
                //   isExpanded: true,
                //   menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                // )
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchableDropdown.single(
                    // validator: (var value) {
                    //   if (value==null) {
                    //     return 'Please enter a farmer';
                    //   }
                    //   return null;
                    // },
                    items: items,
                    value: _assignedto,
                    hint: "Assign Task To",
                    searchHint: "Select One Worker",
                    onChanged: (value) {
                      setState(() {
                        _assignedto = value;
                      });
                    },
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

          Material(
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

              cursorColor: Colors.teal,
              decoration: InputDecoration(
                  hintText: "Starting Date",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 25, vertical: 13)),

            ),
          ),
              SizedBox(
                height: 20,
              ),
              Material(
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
                  controller: _textEditingController2,
                  onTap: () {
                    _selectDate2(context);
                  },

                  cursorColor: Colors.teal,
                  decoration: InputDecoration(
                      hintText: "Ending Date",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13)),

                ),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: RoundedButton2(
                          text: _starttime==null?"Starting time":_starttime.format(context),
                          state: false,
                          color: Colors.grey,
                          press: () {
                            _selectstartingtime();
                          },
                        ),
                      ),

                      Padding(padding: EdgeInsets.only(left: 8)),
                      Container(
                        child: RoundedButton2(
                          text: _endtime==null?"Ending time":_endtime.format(context),
                          state: false,
                          color: Colors.grey,
                          press: () {
                            _selectendingtime();
                          },
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                //width: MediaQuery.of(context).size.width ,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: RoundedButton(
                    text: "Add Task",
                    state: _progress,
                    press: () {

                      // if(_assignedto==null){
                      //   Toast.show("Add A farmer to assign task",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                      // }
                      // else{
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _progress=true;
                          });
                          addwork();
                        }
                     // }
                    },
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(_success == null
                    ? ''
                    : (_success
                    ? 'Successfully published '
                    : ' failed')),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final bool state;
  const RoundedButton({
    Key key,
    this.text,
    this.state,
    this.press,
    this.color = Colors.teal,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width ,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          color: color,
          onPressed: press,
          child: state
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

class RoundedButton2 extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final bool state;
  const RoundedButton2({
    Key key,
    this.text,
    this.state,
    this.press,
    this.color ,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          color: color,
          onPressed: press,
          child: state
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}