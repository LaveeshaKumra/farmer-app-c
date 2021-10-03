import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart';
import 'dart:convert';

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
  final TextEditingController _id = TextEditingController();

  bool _success;





  TextEditingController _textEditingController = TextEditingController();
  DateTime _startdate=DateTime.now();
  DateTime _enddate=DateTime.now();

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _startdate != null ? _startdate : DateTime.now(),
        firstDate: DateTime(DateTime.now().day),
        lastDate: DateTime(DateTime.now().year+1),
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
        firstDate: DateTime(1970),
        lastDate: DateTime(DateTime.now().year+1),
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

  _showdialog(context){
    return AwesomeDialog(
      context: context,
      dialogType: DialogType.SUCCES,
      animType: AnimType.TOPSLIDE,
      title: 'Task Added Successfully',
      desc: 'We Have Sent Task to Worker!',
      //showCloseIcon: true,
      // btnCancelOnPress: () {},
      btnOkOnPress: () {Navigator.pop(context);},
    )..show();
  }
  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification() async {
var topic3=_assignedto.replaceAll('@',"");
      var topic4=topic3.replaceAll('.', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "New Task is assigned to you",
          "body": _title.text,
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "Alltasks",
        },
        "priority": "high",
        "to": '/topics/$topic4',
      };
      var client = new Client();
      var response =
      await client.post(url, headers: header, body: json.encode(request));
      print(response.body);
      print(response.statusCode);
      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  addwork(context) async {
    setState(() {
      _progress=true;
    });

    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("tasks")
        .add({
      'id':_id.text,
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

      //await sendAndRetrieveMessage('${list1[i]}-Vrinda');
      //_showdialog(context);
       Toast.show("Task is added",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
       _sendnotification();
      setState(() {
        _progress=false;
      });
      Navigator.pop(context);
    });



  }

var allnames,allemails;
  List<DropdownMenuItem> items = [];
  _getallworkers() async {
    var val;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("tasks").where('company',isEqualTo: company).get().then((val){
      setState(() {
        _id.text=(val.docs.length+1).toString();
      });
    });
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
  bool _startcolor=false;bool _endcolor=false;
  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }
  void _selectstartingtime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      helpText: "Starting Time",
      initialTime: _starttime,
    );
    if (newTime != null) {
      setState(() {
        _startcolor=true;
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
        _endcolor=true;
        _endtime = newTime;
      });
    }
  }

  _pastetask() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    Map json = jsonDecode(pref.getString('copy'));

    print(json['title']);
    _title.text=json['title'];
    _description.text=(json['description']);
    _textEditingController..text = DateFormat.yMMMd().format(DateTime.parse(json['start_date']));
    _textEditingController2..text = DateFormat.yMMMd().format(DateTime.parse(json['end_date']));
    setState(() {
      _starttime=stringToTimeOfDay(json['start_time']);
      _startcolor=true;
    });
    setState(() {
      _endtime=stringToTimeOfDay(json['end_time']);
      _endcolor=true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Tasks"),
        actions: [
          InkWell(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.paste),
          ),onTap: () async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            if(pref.getString('copy')!=null &&pref.getString('copy')!='')
            Toast.show("Task Pasted !", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
            else{
              Toast.show("No Task copied", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
            }
            //_pastetask();
          },),

        ],
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
                  controller: _id,
             enabled: false,
                  cursorColor: Theme.of(context).primaryColor,
                  decoration: InputDecoration(
                      hintText: "Task ID",

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
                  controller: _title,
                  validator: (var value) {
                    if (value.isEmpty) {
                      return 'Please enter a valid title';
                    }
                    return null;
                  },
                  cursorColor: Theme.of(context).primaryColor,
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
                  cursorColor: Theme.of(context).primaryColor,
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

              cursorColor: Theme.of(context).primaryColor,
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

                  cursorColor: Theme.of(context).primaryColor,
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
                        child: Column(
                          children: [
                            Text("Starting Time"),

                            RoundedButton2(
                              text: _starttime==null?"Starting time":_starttime.format(context),
                              state: false,
                              color: _startcolor==false?Colors.grey:Theme.of(context).primaryColor,
                              press: () {
                                _selectstartingtime();
                              },
                            ),
                          ],
                        ),
                      ),

                      Padding(padding: EdgeInsets.only(left: 8)),
                      Container(
                        child: Column(
                          children: [
                            Text("Ending Time"),

                            RoundedButton2(
                              text: _endtime==null?"Ending time":_endtime.format(context),
                              state: false,
                              color: _endcolor==false?Colors.grey:Theme.of(context).primaryColor,
                              press: () {
                                _selectendingtime();
                              },
                            ),
                          ],
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
                    color: Theme.of(context).primaryColor,
                    press: () {

                      // if(_assignedto==null){
                      //   Toast.show("Add A farmer to assign task",context,duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP);
                      // }
                      // else{
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            _progress=true;
                          });
                          addwork(context);
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
    this.color ,
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
      width: size.width * 0.38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          color: color,
          onPressed: press,
          child: Column(
            children: [
              state
                  ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                text,
                style: TextStyle(color: textColor),
              ),
            ],
          )
        ),
      ),
    );
  }
}

class TaskModel {
  String title;
  String description;
  String startDate;
  String endDate;
  String startTime;
  String endTime;

  TaskModel(
      {this.title,
        this.description,
        this.startDate,
        this.endDate,
        this.startTime,
        this.endTime});

  TaskModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    return data;
  }
}
