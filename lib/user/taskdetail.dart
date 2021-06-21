
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/super_admin/userdetail2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart';
import 'dart:convert';
// import 'edittask.dart';

class TaskDetailsInfarmer extends StatefulWidget {
  var data,id;
  TaskDetailsInfarmer(d,i) {
    this.data = d;
    this.id=i;
  }
  @override
  _TaskDetailsState createState() => _TaskDetailsState(this.data,this.id);
}

class _TaskDetailsState extends State<TaskDetailsInfarmer> {
  var data,manager,user,docid;
  _TaskDetailsState(d,i) {
    this.data = d;
    this.docid=i;
    _getmanager(data['assigned_by']);
    _getuser(data['assigned_to']);
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM , yy');
    final String formatted = formatter.format(d);
    return formatted;
  }
  _getmanager(input) async {
    var val;
    var document = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: input);
    document.get().then((document) {
      val=document.docs[0]["username"];
      setState(() {
        manager=val;
      });
    });
  }

  _getuser(input) async {
    var val;
    var document = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: input);
    document.get().then((document) {
      val=document.docs[0]["username"];
      setState(() {
        user=val;
      });
    });
  }

  // _gotoedittask(){
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => EditTask(data,docid)),
  //   );
  // }

  Future<bool> confirm(docid,status,tasktitle,company) {
    print(status);
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are You Sure , to set status as $status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () {
              if(status=="Task Complete"){
                update(docid,"Done",tasktitle,company);
              }
              else if(status=="In Progress"){
                update(docid,"In Progress",tasktitle,company);
              }
            } ,
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }


  Future<bool> _ifinprogress(docid,tasktitle,company) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Set Task Status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('Cancel'),
          ),
          new FlatButton(
            onPressed: ()  {confirm(docid, "Task Complete",tasktitle,company);},
            child: new Text('Task Completed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _ifinpending(docid,tasktitle,company) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Set Task Status'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {confirm(docid, "In Progress",tasktitle,company);} ,
            child: new Text('In Progress'),
          ),
          new FlatButton(
            onPressed: () => confirm(docid, "Task Complete",tasktitle,company),
            child: new Text('Task Completed'),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> resetstatus(docid,tasktitle,company) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are You Sure?'),
        content:new Text('Do You Want To Reset Status?') ,
        actions: <Widget>[
          new FlatButton(
            onPressed: () {update(docid,"Pending",tasktitle,company);} ,
            child: new Text('Yes'),
          ),
          new FlatButton(
            onPressed: () =>  Navigator.pop(context),
            child: new Text('No'),
          ),
        ],
      ),
    ) ??
        false;
  }
  update(docid,status,tasktitle,company) async {

    final databaseReference = FirebaseFirestore.instance;

    await databaseReference
        .collection("tasks")
        .doc(docid)
        .update({
      'status':status
    }).then((value) {
      _sendnotification(tasktitle,company);
      Toast.show("Status Updated", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      Navigator.pop(context);
      if(status=="Pending"){

      }
      else{
        Navigator.pop(context);
      }
    });

  }

  var serverToken="AAAAwaoyCQk:APA91bGBDoI9m0Ih3cEeEUVTMY6JtrV2xy2nKI88OcRXd6Pj3ee_4K0yM3ZVPoWOBUmiVg9p-jqwLStOkxS0Xmp8QCYaoGY7wWd-4qCgR0k35zoDV1dmOBq04YQQ-WdfLxJYV3UrQGBQ";
  _sendnotification(tasktitle,company) async {
    var topic='admin$company';
    var topic2=topic.replaceAll(' ', "");
    try {
      var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      var header = {
        "Content-Type": "application/json",
        "Authorization":
        "key=$serverToken",
      };
      var request = {
        "notification": {
          "title": "Task Status is Updated",
          "body": tasktitle,
          "sound": "default",
          "tag":"New Updates from Rompin"
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "screen": "AllTasksAdmin",
        },
        "priority": "high",
        "to": '/topics/$topic2',
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
  @override
  Widget build(BuildContext context) {
    Stream documentStream = FirebaseFirestore.instance.collection('tasks').doc(docid).snapshots();

    return  StreamBuilder(
          stream: documentStream,
          builder: (BuildContext context,  snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        child: CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)),
                        width: 30,
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text("Loading.."),
                      )
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text("Task Details"),
                actions: [
                  InkWell(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.refresh),
                  ),onTap: (){
                    resetstatus(docid,snapshot.data['title'],snapshot.data['company']);
                  },),


                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                icon: snapshot.data['status']=="Done"?Icon(Icons.done):Icon(Icons.priority_high_rounded),
                label: snapshot.data['status']!="Done"?Text("set status"):Text("Done"),
                onPressed: (){
                  if(snapshot.data['status']!="Done"){
                    if(snapshot.data['status']=="Pending") _ifinpending(docid,snapshot.data['title'],snapshot.data['company']);
                      else _ifinprogress(docid,snapshot.data['title'],snapshot.data['company']);
                  }
                  else{

                  }
                },

              ),
              body: new ListView(
                children: <Widget>[
                  SizedBox(height: 20,),
                  ListTile(
                    title: Text(
                      "Task ID",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['id'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Task Title",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['title'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Task Description",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['description'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Company",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['company'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Task Status",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['status'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Starting Date",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      _convertdate(snapshot.data['start_date'].toDate()),
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),

                  ListTile(
                    title: Text(
                      "Starting Time",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['start_time'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Ending Date",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      _convertdate(snapshot.data['end_date'].toDate()),
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Ending Time",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      snapshot.data['end_time'],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      "Assigned By",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                    ),
                    subtitle: Text(
                      manager!=null?manager:"",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    trailing: InkWell(child: Icon(Icons.remove_red_eye),onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserDetail2(data['assigned_by'])),
                      );
                    },),
                  ),
                  Divider(),

                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          },


    );
  }
}

