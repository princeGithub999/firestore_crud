import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authen/auth/sign_in_page.dart';
import 'package:firebase_authen/crud/add_data_page.dart';
import 'package:firebase_authen/crud/update_data.dart';
import 'package:firebase_authen/model/user_data_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLogin = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Store',style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: const Icon(CupertinoIcons.back,color: Colors.white,)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink,
        
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(onPressed: () {
                logOutF();
            }, icon: const Icon(Icons.login_sharp)),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddDataPage(),));

      }, label: const Text('add',style: TextStyle(color: Colors.white),),
      icon: const Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.pink,
      ),

      body: RefreshIndicator(
        backgroundColor: Colors.pink,
        color: Colors.white,
        onRefresh: ()async {
            getUser();
      },
      child: SafeArea(child:
      StreamBuilder<List<UserDataModel>>(
        stream: getUser(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if(snapshot.hasError){
            return const Center(child: Text('Error getting data'),);
          }
          final users = snapshot.data;

          return ListView.builder(
            itemCount: users?.length,
            itemBuilder: (context, index) {
              final user = users![index];
              return Padding(
                padding: const EdgeInsets.only(left: 10,top: 10,right: 10),

                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),

                  color: Colors.white54,
                  child: ListTile(
                    onLongPress: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdatePage(
                        userId:user.id,
                        userImage:user.userImage,
                        userName:user.userName,
                        userEmail:user.userEmail,

                      ),));
                    },
                    leading: CircleAvatar(
                      maxRadius: 25,
                      backgroundColor: Colors.pink,
                      child: ClipOval(
                        child: Image.network(user.userImage,height: 45,width: 45,fit: BoxFit.cover,),
                      ),
                    ),
                    title: Text(user.userName,style: const TextStyle(color: Colors.pink,fontSize: 23),),
                    subtitle: Text(user.userEmail),
                    trailing: IconButton(onPressed: () {
                      deleteData(user.id);
                    }, icon: const Icon(Icons.delete,color: Colors.pink,)),
                  ),
                ),
              );
            },);

        },)
      ),),
    );

  }



  Stream<List<UserDataModel>> getUser(){
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore.collection('User').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserDataModel.fromMap(doc.data(),doc.id);
      },).toList();
    },);
  }


  Future<void> deleteData(String userId)async{
    try{
      DocumentSnapshot userDoc = await _firestore.collection('User').doc(userId).get();
      if(userDoc.exists){
        var userData = UserDataModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);

        if(userData.userImage.isNotEmpty){
          final storageRef = FirebaseStorage.instance.refFromURL(userData.userImage);
          await storageRef.delete();
        }
       await _firestore.collection('User').doc(userId).delete();

      }
      Fluttertoast.showToast(msg: 'User data deleted successfully');

    }catch(e){
      Fluttertoast.showToast(msg: 'Error deleting user data: $e');

    }
  }



  void logOutF(){
    prossesStart();
    _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInPage(),));
  }

  void prossesStop(){
    setState(() {
      isLogin = false;
    });
  }

  void prossesStart(){
    setState(() {
      isLogin = true;
    });

  }

}
