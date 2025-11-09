// this model represents a swap offer between two users. 
//when a user wants to exchange books with another user, a swap offer is created. 
//it tracks the sender, recipient, book details, and the current status of the offer which can be pending, accepted, or rejected.

class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String status; 
  final DateTime createdAt;

  // constructor 
  SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.status,
    required this.createdAt,
  });

  // factory method to create swap offer from firestore document
  factory SwapOffer.fromMap(Map<String, dynamic> map, String id) {
    return SwapOffer(
      id: id,
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      recipientId: map['recipientId'] ?? '',
      recipientName: map['recipientName'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // method to convert swap offer to map for firestore storage
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}