import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_authen/model/user_data_model.dart';

class UserService {


  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('User');

  Future<void> addUser(Map<UserDataModel,dynamic> user)async{
    await _userCollection.add(user);

  }
}