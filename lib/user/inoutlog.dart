import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
class ClockInClockOutLog extends StatefulWidget {
  @override
  _ClockInClockOutLogState createState() => _ClockInClockOutLogState();
}

class _ClockInClockOutLogState extends State<ClockInClockOutLog> {

  _convertdate(d) {
    final DateFormat formatter = DateFormat('dd MMMM yy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  _convertdatetime(d) {
    final DateFormat formatter = DateFormat.jm();
    final String formatted = formatter.format(d);
    return formatted;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Attendance Report"),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("attendance")
              .where("email", isEqualTo: FirebaseAuth.instance.currentUser.email).where("out_time",isNotEqualTo: "")
              .orderBy('out_time', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
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
            if (snapshot.data.docs.length == 0) {
              return Center(
                child: Container(
                  child: Image.asset(
                    "assets/nodata.png",
                    width: 300,
                  ),
                ),
              );
            }
            return GroupedListView(
                elements: snapshot.data.docs,
                groupBy: (element) => _convertdate(element['in_time'].toDate()),
                order: GroupedListOrder.DESC,
                groupHeaderBuilder: (element) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                        _convertdate(element['in_time'].toDate()),
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      )),
                ),
                indexedItemBuilder: (context, document, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: ListTile(
                        leading: Icon(Icons.lock_clock,color: Colors.green,),
                        title:
                        Row(
                          children: [
                            Text("${_convertdatetime(document.data()['in_time'].toDate())}",style: TextStyle(fontWeight: FontWeight.w500),),
                            Text("\t to \t"),
                            Text("${_convertdatetime(document.data()['out_time'].toDate())}",style: TextStyle(fontWeight: FontWeight.w500),),
                          ],
                        ),
                        trailing: document.data()['out_time'].toDate().difference(document.data()['in_time'].toDate()).inMinutes<60?
                        Text("${document.data()['out_time'].toDate().difference(document.data()['in_time'].toDate()).inMinutes} Mins",style: TextStyle(fontSize: 16,color: Colors.green),):
                        Text("${(document.data()['out_time'].toDate().difference(document.data()['in_time'].toDate()).inMinutes/60).toStringAsFixed(2)} Hrs",style: TextStyle(fontSize: 16,color: Colors.green)),
                      ),
                      onTap: () {

                      },
                    ),
                  );
                });
          },
        ));
  }
}


