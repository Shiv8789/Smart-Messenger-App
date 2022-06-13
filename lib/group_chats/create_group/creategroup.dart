import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:messengerapp/group_chats/groupscreen.dart';


class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({required this.membersList, Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": widget.membersList,
      "id": groupId,
    });

    for (int i = 0; i < widget.membersList.length; i++) {
      String uid = widget.membersList[i]['uid'];

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupName.text,
        "id": groupId,
      });
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": "${_auth.currentUser!.displayName} Created This Group.",
      "type": "notify",
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => GroupChatHomeScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Group Name",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
          automaticallyImplyLeading: false,
          leading: Icon(Icons.arrow_back_ios_new),
          centerTitle: true,
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
            : Column(
                children: [
                  SizedBox(
                    height: size.height / 10,
                  ),
                  Container(
                      padding: EdgeInsets.all(5),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _groupName,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.black87,
                          ),
                          labelText: 'Enter Group Name .....',
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
                  GestureDetector(
                      onTap: createGroup,
                      child: Container(
                        width: 280,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text("Create Group",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
