import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_authen/model/user_data_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UpdatePage extends StatefulWidget {
  
  String userImage;
  String userName;
  String userEmail;
  String userId;



   UpdatePage({super.key,
    required this.userImage,
    required this.userName,
    required this.userEmail,
     required this.userId
   });

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {


  TextEditingController userName = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isUpdating = false;
  ImagePicker imagePicker = ImagePicker();
  File? imageFile;
  String? image;

  
  @override
  void initState() {
    super.initState();
    userName = TextEditingController(text: widget.userName);
    userEmail = TextEditingController(text: widget.userEmail);
    image = widget.userImage;
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink,
        title: const Text('Update Your Data', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  imagePickerF();
                },
                child: CircleAvatar(
                  backgroundColor: Colors.pink,
                  maxRadius: 60,
                  child: ClipOval(
                    child: imageFile != null
                        ? Image.file(File(imageFile!.path), height: 110, width: 110, fit: BoxFit.cover,)
                        : Image.network(image!,height: 110, width: 110, fit: BoxFit.cover,)
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(userName, 'UserName'),
              const SizedBox(height: 20),
              _buildTextField(userEmail, 'UserEmail'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                    updateData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: isUpdating
                    ? const SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      Text(
                        'Loading...',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    ],
                  ),
                )
                    : const Text('Update', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return Card(
      elevation: 10,
      child: TextField(
        keyboardType: TextInputType.name,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.only(left: 10),
          border: InputBorder.none,
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.pink)),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.pink)),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.pink)),
        ),
      ),
    );
  }




  Future<void> imagePickerF() async {
    var getImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (getImage != null) {
      setState(() {
        imageFile = File(getImage.path);
      });
    } else {
      Fluttertoast.showToast(msg: 'Image path is empty');
    }
  }


  Future<void> updateData()async{

    var name = userName.text;
    var email = userEmail.text;

    if(name.isNotEmpty && email.isNotEmpty){
      startProgress();

      if(imageFile != null){
        image = await uplodeImageToStorage(imageFile!);
      }

      var data = UserDataModel(
        id: widget.userId,
        userName: name,
        userEmail: email,
        userImage: image!,

      );

      try{
        startProgress();
        await firestore.collection('User').doc(widget.userId).update(
            data.toMap()
        );
        Fluttertoast.showToast(msg: 'User data updated successfully');
        Navigator.pop(context);
        stopProgress();

      }catch(e){
        Fluttertoast.showToast(msg: 'Error updating user data: $e');
        stopProgress();
      }
    }else{
      Fluttertoast.showToast(msg: 'Please feel all feald');
    }
  }

  uplodeImageToStorage(File imageFile)async {

    try{
      Reference storageRef = FirebaseStorage.instance.ref().child('user_images/${widget.userId}.jpg');
      await storageRef.putFile(imageFile);

      String downloadUrl= await storageRef.getDownloadURL();
      stopProgress();
      return downloadUrl;

    }catch(e){
      Fluttertoast.showToast(msg: 'Image uplode error $e');
      stopProgress();
    }
  }





  void startProgress() {
    setState(() {
      isUpdating = true;
    });
  }

  void stopProgress() {
    setState(() {
      isUpdating = false;
    });
  }


}
