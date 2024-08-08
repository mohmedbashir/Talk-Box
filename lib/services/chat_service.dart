import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talk_box/models/message_model.dart';

class ChatService {
  final messagesCollectionRef =
      FirebaseFirestore.instance.collection('Messages');
  Future sendMessage({required MessageModel message}) async {
    messagesCollectionRef.doc().set(message.toJson());
  }

  Future deleteCallDocuments(String chatId) async {
    CollectionReference parentCollectionRef =
        FirebaseFirestore.instance.collection('Chats');
    final documentQuery = parentCollectionRef
        .doc()
        .collection('Messages')
        .where('type', whereIn: ['video call', 'voice call']);
    final doc = documentQuery.get().then((querySnapshot) {
      if (querySnapshot.size > 0) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete().then((value) {
            print("Document deleted successfully");
          }).catchError((error) {
            print("Failed to delete document: $error");
          });
        });
      } else {
        print("No matching document found");
      }
    });
  }
}
