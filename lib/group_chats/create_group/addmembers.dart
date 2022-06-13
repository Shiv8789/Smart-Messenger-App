import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'creategroup.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "email": map['email'],
          "uid": map['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Create New Group",
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: Icon(Icons.arrow_back_ios_new),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10,),
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
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        onTap: () => onRemoveMembers(index),
                        leading: Icon(
                          Icons.account_circle,
                          color: Colors.green,
                          size: 35,
                        ),
                        title: Text(membersList[index]['name']),
                        subtitle: Text(membersList[index]['email']),
                        trailing: Icon(Icons.close),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: size.height / 20,
              ),
             Container(
                      padding: EdgeInsets.all(5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black87,
                          ),
                          labelText: 'Search',
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 3, color: Colors.blue),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 3, color: Colors.green),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: size.height / 50,
              ),
              isLoading
                  ? Container(
                      height: size.height / 12,
                      width: size.height / 12,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  :GestureDetector(
                      onTap: () {
                        onSearch();
                      },
                      child: Container(
                        width: 280,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text("Search",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 20,),
               userMap != null && userMap!['uid'] != _auth.currentUser!.uid
                        ? Card(
                            elevation: 32,
                            shadowColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              onTap: onResultTap,
                              leading:
                                  Icon(Icons.account_box, color: Colors.black),
                              title: Text(
                                userMap!['name'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                userMap!['email'],
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Icon(Icons.chat, color: Colors.red),
                            ),
                          )
                        : Container(),
            ],
          ),
        ),
        floatingActionButton: membersList.length >= 2
            ? FloatingActionButton(
                child: Icon(Icons.forward),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateGroup(
                      membersList: membersList,
                    ),
                  ),
                ),
              )
            : SizedBox(),
      ),
    );
  }
}
