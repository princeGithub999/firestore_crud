import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authen/model/user_data_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  TextEditingController userName = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  bool isAdding = false;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage _storageRef = FirebaseStorage.instance;
  String id = randomAlphaNumeric(10);
  Uri? imageUri;
  ImagePicker imagePicker = ImagePicker();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink,
        title: const Text('Add Your Data', style: TextStyle(color: Colors.white)),
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
                        ? Image.file(
                      File(imageFile!.path),
                      height: 110,
                      width: 110,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.person, color: Colors.white, size: 100),
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
                  addData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: isAdding
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
                    : const Text('Add Data', style: TextStyle(color: Colors.black)),
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

  Future<void> addData() async {
    var name = userName.text;
    var email = userEmail.text;
    UserDataModel data;

    if (name.isNotEmpty && email.isNotEmpty) {
      startProgress();

      try {
        final imageUrl = await storeImage();

        if (imageUrl == null) {
          Fluttertoast.showToast(msg: 'Image upload failed');
          stopProgress();
          return;

        }else{
           data = UserDataModel(
            id: id,
            userName: name,
            userEmail: email,
            userImage: imageUrl.toString(),
          );
        }

        await store.collection('User').doc(id).set(data.toMap());

        Fluttertoast.showToast(msg: 'Data added successfully');
        userName.clear();
        userEmail.clear();
        stopProgress();
        Navigator.pop(context);

      } catch (e) {
        Fluttertoast.showToast(msg: 'Error adding data: $e');
        stopProgress();
      }
    } else {
      Fluttertoast.showToast(msg: 'Please fill all fields');
    }
  }

  Future<String?> storeImage() async {

    if (imageFile != null) {
      try {
        final storageRef = _storageRef.ref('user_images/$id.jpg');
        await storageRef.putFile(imageFile!);
        return await storageRef.getDownloadURL();

      } catch (e) {
        Fluttertoast.showToast(msg: 'Image Error: $e');

      }
    }
    return null;
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

  void startProgress() {
    setState(() {
      isAdding = true;
    });
  }

  void stopProgress() {
    setState(() {
      isAdding = false;
    });
  }
}
