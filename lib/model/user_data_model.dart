class UserDataModel {
  String id;
  String userName;
  String userEmail;
  String userImage;

  UserDataModel({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userImage

  });

  // Method to convert Firestore data to model instance
  factory UserDataModel.fromMap(Map<String, dynamic> map, String id) {
    return UserDataModel(
      id: id,
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userImage: map['userImage'] ?? ''
    );
  }

  // Method to convert model instance to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userEmail': userEmail,
      'userImage': userImage
    };
  }
}
