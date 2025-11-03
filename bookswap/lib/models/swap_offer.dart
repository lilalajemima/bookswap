class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String status; // 'Pending', 'Accepted', 'Rejected'
  final DateTime createdAt;

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