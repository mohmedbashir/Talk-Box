// ignore_for_file: public_member_api_docs, sort_constructors_first

class FriendRequestModel {
  String? requester;
  String? recipient;
  String? status;
  String? requesterName;
  String? requesterPhoto;
  var timestamp;
  FriendRequestModel({
    this.requester,
    this.recipient,
    this.status,
    this.requesterName,
    this.requesterPhoto,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'requester': requester,
      'recipient': recipient,
      'status': status,
      'requesterName': requesterName,
      'requesterPhoto': requesterPhoto,
      'timestamp': timestamp,
    };
  }

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      requester: json['requester'] != null ? json['requester'] as String : null,
      recipient: json['recipient'] != null ? json['recipient'] as String : null,
      status: json['status'] != null ? json['status'] as String : null,
      requesterName: json['requesterName'] != null
          ? json['requesterName'] as String
          : null,
      requesterPhoto: json['requesterPhoto'] != null
          ? json['requesterPhoto'] as String
          : null,
      timestamp: json['timestamp'],
    );
  }
}
