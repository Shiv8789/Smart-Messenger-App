import '/Screens/home.dart';
import './addmembers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;

    membersList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Home()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Manage Your Group",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          leading: Icon(Icons.arrow_back_ios_new),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
              ),
            ),
          ),
        ),
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green[600],
                                elevation: 42,
                                shadowColor: Colors.black12,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(8)),
                            child: Icon(
                              Icons.group,
                              size: 44,
                            ),
                            onPressed: () {},
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(widget.groupName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //

                    SizedBox(
                      height: size.height / 20,
                    ),

                    Container(
                      width: size.width / 1.1,
                      child: Text("${membersList.length} Members",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                    ),

                    SizedBox(
                      height: size.height / 45,
                    ),

                    // Members Name

                    checkAdmin()
                        ? Card(
                            elevation: 15,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddMembersINGroup(
                                    groupChatId: widget.groupId,
                                    name: widget.groupName,
                                    membersList: membersList,
                                  ),
                                ),
                              ),
                              leading: Icon(
                                Icons.add,
                              ),
                              title: Text(
                                "Add Members",
                                style: TextStyle(
                                  fontSize: size.width / 22,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),

                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 32,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              onTap: () => showDialogBox(index),
                              leading: Icon(
                                Icons.account_circle,
                                color: Colors.green,
                                size: 35,
                              ),
                              title: Text(membersList[index]['name'],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(membersList[index]['email']),
                              trailing: Text(
                                  membersList[index]['isAdmin'] ? "Admin" : "",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.fromLTRB(5, 20, 5, 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18),
                        ),
                      ),
                      child: ListTile(
                        onTap: onLeaveGroup,
                        leading: Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                          size: 35,
                        ),
                        title: Text("Leave Group",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
