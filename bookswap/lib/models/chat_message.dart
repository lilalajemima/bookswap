// this model represents a single message in a chat conversation between two users. 
//it stores the message content, sender information, and timestamp. 
//messages are stored as subcollections under chat documents in firestore.

class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  // constructor 
  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });

  // factory method to create message from firestore document
  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // method to convert message to map for firestore storage
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}