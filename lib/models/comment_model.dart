import 'package:talk_box/models/user_model.dart';

class Comment {
  String? commentContent;
  String? commenter;
  Comment({
    required this.commentContent,
    required this.commenter,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'commentContent': commentContent,
      'commenter': commenter,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentContent: json['commentContent'] != null
          ? json['commentContent'] as String
          : null,
      commenter: json['commenter'],
    );
  }
}

class Commenter {
  UserModel? commentOwner;
  String? comment;
  Commenter({
    required this.commentOwner,
    required this.comment,
  });
}
