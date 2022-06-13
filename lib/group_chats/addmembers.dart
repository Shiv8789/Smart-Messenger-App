import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
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

  void onAddMembers() async {
    membersList.add(userMap);

    await _firestore.collection('groups').doc(widget.groupChatId).update({
      "members": membersList,
    });

    await _firestore
        .collection('users')
        .doc(userMap!['uid'])
        .collection('groups')
        .doc(widget.groupChatId)
        .set({"name": widget.name, "id": widget.groupChatId});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Members To Group"),
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      borderSide: BorderSide(width: 3, color: Colors.blue),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.green),
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
                  : GestureDetector(
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
              userMap != null && userMap!['uid'] != _auth.currentUser!.uid
                  ? Container(
                      margin: EdgeInsets.fromLTRB(5, 20, 5, 5),
                      child: Card(
                        elevation: 32,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: ListTile(
                          onTap: onAddMembers,
                          leading: Icon(Icons.account_box, color: Colors.black),
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
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
