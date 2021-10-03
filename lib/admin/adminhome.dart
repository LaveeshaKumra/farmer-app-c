import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_app/admin/leaveentitlement.dart';
import 'package:farmers_app/admin/profile.dart';
import 'package:farmers_app/admin/taskdetail.dart';
import 'package:farmers_app/admin/timeoff.dart';
import 'package:farmers_app/admin/workerRequest.dart';
import 'package:farmers_app/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Theme.dart';
import 'addtask.dart';
import 'allteam.dart';
import 'homepageadmin.dart';
import 'allrewards.dart';
import 'myprofile.dart';
import 'package:intl/intl.dart';
class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  var image, company, email;
  var d1,d2;


  _AdminPageState() {
    _getUser();
    var d = DateTime.now();
    d1 = new DateTime(d.year, d.month, d.day, 0, 0, 0, 0, 0);
    d2 = new DateTime(d.year, d.month, d.day, 23, 59, 59, 0, 0);

  }
  var firebase = FirebaseAuth.instance;

  Future<bool> _onBackPressed(context) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to LogOut'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => _logout(context),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  _logout(context) async {
    var emaill=FirebaseAuth.instance.currentUser.email;
   
  await firebase.signOut().then((value)  async {
 final themeNotifier = Provider.of<ThemeNotifier>(context,listen: false);
    var topic='admin$company';
    var topic2=topic.replaceAll(' ', "");
    var topic3=emaill.replaceAll('@',"");
    var topic4=topic3.replaceAll('.', "");
    print(topic2);
    FirebaseMessaging.instance.unsubscribeFromTopic(topic2);
    FirebaseMessaging.instance.unsubscribeFromTopic(topic4);
      var prefs=await  SharedPreferences.getInstance();
      prefs.setString("theme", "tealTheme");
      themeNotifier.setTheme(tealTheme);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
    });
  }

  _getUser() async {
    var user = firebase.currentUser;
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference
        .collection("users")
        .where('email', isEqualTo: user.email)
        .get()
        .then((val) async {
      setState(() {
        company = val.docs[0]['company'];
        email = val.docs[0]['email'];
      });
      if (val.docs[0]['gender'] == "Male") {
        setState(() {
          image = "assets/male.png";
        });
      } else if (val.docs[0]['gender'] == "Female") {
        setState(() {
          image = "assets/female.png";
        });
      }
      var topic='admin$company';
      var topic2=topic.replaceAll(' ', "");
      var topic3=email.replaceAll('@',"");
      var topic4=topic3.replaceAll('.', "");
      print(topic2);
      print(topic4);
      FirebaseMessaging.instance.subscribeToTopic(topic2);
      FirebaseMessaging.instance.subscribeToTopic(topic4);
    });
  }

  void initState() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: ListTile(
                title: Text(message.notification.title),
                subtitle: Text(message.notification.body),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(message.data['screen']);
      print('A new onMessageOpenedApp event was published!');
      switch (message.data['screen']) {
        case "TimeoffAdmin":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimeOff(company)),
          );
          break;
        case "AllTasksAdmin":

          break;
        case "NewRegister":
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkerRequestsScreen(company)),
          );
          break;
        case "login":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          break;
        default:
          break;
      }

      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });

  }

  _convertdate(d){
    final DateFormat formatter = DateFormat('dd MMMM,yy');
    final String formatted = formatter.format(d);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: NavDrawer(image, company, email),
      appBar: AppBar(title: Text("Farmer's Page"),backgroundColor: Theme.of(context).primaryColor,actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(onTap:(){_onBackPressed (context);},child: Icon(Icons.logout)),
        )
      ],),

      //body: HomePageAdmin(email,company),
      body:ListView(
        shrinkWrap: true,
        children: [

          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.22,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(10)),
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Today's DeadLine",
                          style: TextStyle(color: Colors.black26, fontSize: 18),
                        )
                      ],
                    ),
                    Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection("tasks").where("assigned_by",isEqualTo: FirebaseAuth.instance.currentUser.email)
                            .where('end_date', isGreaterThanOrEqualTo: d1, isLessThan: d2).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                          if(snapshot.data.docs.length==0){
                            return Center(
                              child: Container(
                                child: Text("No Task"),
                              ),
                            );
                          }
                          return new ListView(
                            children: snapshot.data.docs.map((DocumentSnapshot document) {

                              return new InkWell(
                                child: ListTile(
                                  trailing: document.data()['status']=="Done"?Icon(Icons.check_circle,color: Colors.green,):Icon(Icons.warning,color: Colors.yellow,),
                                  title: document.data()['title']==null?Text(''):Text(document.data()['title']),
                                  subtitle: _convertdate(document.data()['start_date'].toDate())==_convertdate(document.data()['end_date'].toDate())?
                                  Text("From ${_convertdate(document.data()['start_date'].toDate())}"):
                                  Text("From ${_convertdate(document.data()['start_date'].toDate())} to ${_convertdate(document.data()['end_date'].toDate())}"),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TaskDetailsInAdmin(
                                                document.data(), document.id)),
                                  );
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/alltasks.png",width: 80,),
                                ),
                                Text("View All\nTasks",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageAdmin(FirebaseAuth.instance.currentUser.email,company)),
                          )
                        },
                      ),
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/team.png",width: 80,),
                                ),
                                Text("All Team\nMembers",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllUsersincompany(company)),
                          );
                        },
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap:(){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkerRequestsScreen(company)),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/workerrequest.png",width: 80,),
                                ),
                                Text("Worker ID\nRequests",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/leaveent.png",width: 80,),
                                ),
                                Text("Leave\nEntitlement",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LeaveEntitlement(company)),
                          )
                        },
                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap:(){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimeOff(company)),
                          );
                        },
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/leaverequest.png",width: 80,),
                                ),
                                Text("Leave Requests",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/sendrewards.png",width: 80,),
                                ),
                                Text("Send Rewards",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: () => {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllRewards(FirebaseAuth.instance.currentUser.email,company)),
                          )
                        },
                      ),

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      InkWell(
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset("assets/icons/profile.png",width: 80,),
                                ),
                                Text("View Profile",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)
                              ],
                            ),
                          ),
                        ),
                        onTap: () => {


                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyProfilePage(email)),
                          )
                        },
                      ),

                    ],
                  ),
                )
              ],
            ),
            // child: GridView(
            //     shrinkWrap: true,
            //     children:
            //     category.map((data)  {return Container(
            //       padding: EdgeInsets.all(10.0),
            //       child: Card(
            //
            //         child: Center(child: Column(
            //           children: [
            //             Container(height: MediaQuery.of(context).size.height*0.05,),
            //             Icon(Icons.adb_sharp),
            //             Container(height: MediaQuery.of(context).size.height*0.01,),
            //             Text(data),
            //           ],
            //         )),
            //       ),
            //     );}).toList()
            //     ,
            //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            //         childAspectRatio: 3 / 3,
            //         crossAxisSpacing: 8,
            //         mainAxisSpacing: 6,
            //         maxCrossAxisExtent: 200)
            //       ),
          )
        ],
      ),
    );
  }
}


