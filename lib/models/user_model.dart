// ignore_for_file: public_member_api_docs, sort_constructors_first

class UserModel {
  String? uId;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final String? email;
  final String? gender;
  final int? age;
  final List<String>? friends;
  final List<String>? friendsRequest;
  final List<String>? chats;
  final List<String>? storeis;
  final String? fcmToken;
  UserModel(
      {this.uId,
      this.name,
      this.avatarUrl,
      this.bio,
      this.email,
      this.gender,
      this.age,
      this.friends,
      this.friendsRequest,
      this.chats,
      this.storeis,
      this.fcmToken});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uId': uId,
      'name': name,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'email': email,
      'gender': gender,
      'age': age,
      'friends': friends,
      'friendsRequest': friendsRequest,
      'chats': chats,
      'storeis': storeis,
      'fcmToken': fcmToken
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> Json) {
    return UserModel(
      uId: Json['uId'] != null ? Json['uId'] as String : null,
      name: Json['name'] != null ? Json['name'] as String : null,
      avatarUrl: Json['avatarUrl'] != null ? Json['avatarUrl'] as String : null,
      bio: Json['bio'] != null ? Json['bio'] as String : null,
      email: Json['email'] != null ? Json['email'] as String : null,
      gender: Json['gender'] != null ? Json['gender'] as String : null,
      age: Json['age'] != null ? Json['age'] as int : null,
      friends:
          Json['friends'] != null ? List<String>.from((Json['friends'])) : null,
      friendsRequest: Json['friendsRequest'] != null
          ? List<String>.from((Json['friendsRequest']))
          : null,
      chats: Json['chats'] != null ? List<String>.from((Json['chats'])) : null,
      storeis:
          Json['storeis'] != null ? List<String>.from((Json['storeis'])) : null,
      fcmToken: Json['fcmToken'] != null ? Json['fcmToken'] as String : null,
    );
  }
}
