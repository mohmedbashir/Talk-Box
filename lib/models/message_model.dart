// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageModel {
  // String? mediaUrl;
  String? senderId;
  String? reciverId;
  String? text;
  String? type;
  String? msgId;
  var sendAt;
  MessageModel(
      {
      // this.mediaUrl,
      this.senderId,
      this.reciverId,
      this.text,
      this.sendAt,
      this.msgId,
      this.type});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      // 'mediaUrl': mediaUrl,
      'senderId': senderId,
      'reciverId': reciverId,
      'text': text,
      'sendAt': sendAt,
      'type': type,
      'msgId': msgId,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      // mediaUrl: json['mediaUrl'] != null ? json['mediaUrl'] as String : null,
      senderId: json['senderId'] != null ? json['senderId'] as String : null,
      reciverId: json['reciverId'] != null ? json['reciverId'] as String : null,
      text: json['text'] != null ? json['text'] as String : null,
      msgId: json['msgId'] != null ? json['msgId'] as String : null,
      sendAt: json['sendAt'],
      type: json['type'],
    );
  }
}
