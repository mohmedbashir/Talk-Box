class StoryModel {
  String? storyId;
  String? publisherId;
  String? phublisherPhoto;
  String? phublisherName;
  String? storyType;
  String? storyContent;
  List<Map>? comments;
  List<String>? views;
  List<String>? likes;
  var publishTime;
  String? firebaseStoragePath;

  StoryModel(
      {this.storyId,
      this.publisherId,
      this.phublisherPhoto,
      this.phublisherName,
      this.storyType,
      this.storyContent,
      this.comments,
      this.views,
      this.likes,
      this.publishTime,
      this.firebaseStoragePath});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'storyId': storyId,
      'publisherId': publisherId,
      'phublisherPhoto': phublisherPhoto,
      'phublisherName': phublisherName,
      'storyType': storyType,
      'storyContent': storyContent,
      'comments': comments,
      'views': views,
      'likes': likes,
      'publishTime': publishTime,
      'firebaseStoragePath': firebaseStoragePath
    };
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      storyId: json['storyId'],
      publisherId: json['publisherId'],
      phublisherPhoto: json['phublisherPhoto'],
      phublisherName: json['phublisherName'],
      storyType: json['storyType'],
      storyContent: json['storyContent'],
      comments:
          json['comments'] != null ? List<Map>.from(json['comments']) : null,
      views: json['views'] != null ? List<String>.from((json['views'])) : null,
      likes: json['likes'] != null ? List<String>.from((json['likes'])) : null,
      publishTime: json['publishTime'],
      firebaseStoragePath: json['firebaseStoragePath'],
    );
  }
}
