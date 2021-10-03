import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/super_admin/userdetail2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'edittask.dart';

class TaskDetailsInAdmin extends StatefulWidget {
  var data,id;
  TaskDetailsInAdmin(d,i) {
    this.data = d;
    this.id=i;
  }
  @override
  _TaskDetailsState createState() => _TaskDetailsState(this.data,this.id);
}

class _TaskDetailsState extends State<TaskDetailsInAdmin> {
  var data,manager,user,docid;
  _TaskDetailsState(d,i) {
    this.data = d;
    this.docid=i;
    _getmanager(data['assigned_by']);
    _getuser(data['assigned_to']);
  }
  _convertdate(d){
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
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

  _gotoedittask(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EditTask(data,docid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream documentStream = FirebaseFirestore.instance.collection('tasks').doc(docid).snapshots();
var obj;
    return Scaffold(

      body: StreamBuilder(
        stream: documentStream,
        builder: (BuildContext context,  snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
            );
          }



          return Scaffold(
            appBar: AppBar(
              title: Text("Task Details"),
              actions: [
                InkWell(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.copy),
                ),onTap: () async {
                  Toast.show("Task Copied !", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  setState(() {
                    obj='{"title": "${snapshot.data["title"]}","description": "${snapshot.data["description"]}","start_date": "${snapshot.data["start_date"].toDate()}","end_date": "${snapshot.data["end_date"].toDate()}","start_time": "${snapshot.data["start_time"]}","end_time": "${snapshot.data["end_time"]}"}';
                  });
                  print(obj);
                  pref.setString("copy", obj);
                },),
                InkWell(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.edit),
                ),onTap: (){
                  _gotoedittask();
                },),

              ],
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
                  // trailing: InkWell(child: Icon(Icons.remove_red_eye),onTap: (){
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => UserDetail2(data['assigned_by'])),
                  //   );
                  // },),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    "Assigned To",
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),
                  ),
                  subtitle: Text(
                    user!=null?user:"",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  trailing: InkWell(child: Icon(Icons.remove_red_eye),onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserDetail2(snapshot.data['assigned_to'])),
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
      )

    );
  }
}

