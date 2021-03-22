import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/login/login.dart';
import 'package:farmers_app/super_admin/super_admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'allusers.dart';

class TeamsScreen extends StatefulWidget {
  @override
  _TeamsScreenState createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  var newList;
  _TeamsScreenState(){
    _getallcompanies();
  }

  @override
  void initState() {
    _getallcompanies();
  }

  _getallcompanies() async {
    var val;
    var arr=[];
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("users").where('role',isNotEqualTo: 'super_admin').get().then(
            (QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
            print(doc["company"]);
            arr.add(doc['company']);
            })
    });

   setState(() {
     newList=arr.toSet().toList();
   });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Team Details"),
        // actions: [
        //   InkWell(child: Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Icon(Icons.power_settings_new),
        //   ),onTap: (){
        //     _logout();
        //    },),
        // ],
      ),
      body: ListView.builder(
        itemCount: newList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text(newList[index]),
                  trailing: Icon(Icons.navigate_next),
                  //trailing: Text(d[index].data['role']),
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllUsers(newList[index])),
                  );
                },
              ),Divider(height: 5,)
            ],
          );
        },
      ),
      );
  }
}