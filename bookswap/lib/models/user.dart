// this model represents a user account in the bookswap app. 
//it stores user profile information including authentication details and account creation date. 
//the model is used to manage user data in firestore separate from firebase authentication.

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;
  final DateTime createdAt;

  // constructor 
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
    required this.createdAt,
  });

  // factory method to create user from firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // method to convert user to map for firestore storage
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}