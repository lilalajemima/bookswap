class Book {
  final String id;
  final String title;
  final String author;
  final String condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime postedAt;
  final String? swapStatus; // null, 'Pending', 'Accepted', 'Rejected'

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.postedAt,
    this.swapStatus,
  });

  factory Book.fromMap(Map<String, dynamic> map, String id) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      condition: map['condition'] ?? 'Used',
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      postedAt: DateTime.parse(map['postedAt']),
      swapStatus: map['swapStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'postedAt': postedAt.toIso8601String(),
      'swapStatus': swapStatus,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerName,
    DateTime? postedAt,
    String? swapStatus,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      postedAt: postedAt ?? this.postedAt,
      swapStatus: swapStatus ?? this.swapStatus,
    );
  }
}