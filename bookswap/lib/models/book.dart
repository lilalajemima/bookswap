// this model represents a book listing in the bookswap marketplace. 
//it contains all the necessary information about a book including its owner details, condition, and swap status. 
//the model provides methods to convert between dart objects and firestore documents for seamless database operations.

class Book {
  final String id;
  final String title;
  final String author;
  final String condition;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final DateTime postedAt;
  final String? swapStatus; 

  // constructor 
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

  // factory method to create a book object from firestore document data
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

  // method to convert book object to map for firestore storage
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

  // method to create a copy of book with updated fields
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