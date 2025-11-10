import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../models/chat_message.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all books stream (real-time updates)
  Stream<List<Book>> getBooksStream() {
    return _firestore
        .collection('books')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all books (one-time fetch)
  Future<List<Book>> getAllBooks() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .orderBy('postedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting books: $e');
      return [];
    }
  }

  // Get user's books stream (real-time)
  Stream<List<Book>> getUserBooksStream(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Book.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get user's books (one-time)
  Future<List<Book>> getUserBooks(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .where('ownerId', isEqualTo: userId)
          .orderBy('postedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting user books: $e');
      return [];
    }
  }

  // Add a new book
  Future<String?> addBook(Book book) async {
    try {
      DocumentReference docRef = await _firestore.collection('books').add(book.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding book: $e');
      return null;
    }
  }

  // Update a book
  Future<bool> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('books').doc(bookId).update(data);
      return true;
    } catch (e) {
      print('Error updating book: $e');
      return false;
    }
  }

  // Delete a book
  Future<bool> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
      return true;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }

  // ==================== SWAP OFFERS ====================

  // Create a swap offer
  Future<String?> createSwapOffer(SwapOffer offer) async {
    try {
      // Add the swap offer
      DocumentReference docRef = await _firestore.collection('swap_offers').add(offer.toMap());

      // Update the book's swap status
      await _firestore.collection('books').doc(offer.bookId).update({
        'swapStatus': 'Pending',
      });

      return docRef.id;
    } catch (e) {
      print('Error creating swap offer: $e');
      return null;
    }
  }

  // Get swap offers for a user (sent and received) - stream
  Stream<List<SwapOffer>> getUserSwapOffersStream(String userId) {
    return _firestore
        .collection('swap_offers')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get sent swap offers stream
  Stream<List<SwapOffer>> getSentSwapOffersStream(String userId) {
    return _firestore
        .collection('swap_offers')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapOffer.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all user's swap offers (sent + received)
  Future<List<SwapOffer>> getUserSwapOffers(String userId) async {
    try {
      // Get offers where user is sender
      QuerySnapshot sentSnapshot = await _firestore
          .collection('swap_offers')
          .where('senderId', isEqualTo: userId)
          .get();

      // Get offers where user is recipient
      QuerySnapshot receivedSnapshot = await _firestore
          .collection('swap_offers')
          .where('recipientId', isEqualTo: userId)
          .get();

      List<SwapOffer> offers = [];
      offers.addAll(sentSnapshot.docs.map((doc) =>
          SwapOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
      offers.addAll(receivedSnapshot.docs.map((doc) =>
          SwapOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id)));

      // Sort by creation date
      offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return offers;
    } catch (e) {
      print('Error getting swap offers: $e');
      return [];
    }
  }

  // Update swap offer status
  Future<bool> updateSwapOfferStatus(String offerId, String bookId, String status) async {
    try {
      // Update the swap offer
      await _firestore.collection('swap_offers').doc(offerId).update({
        'status': status,
      });

      // Update the book's swap status
      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': status,
      });

      return true;
    } catch (e) {
      print('Error updating swap offer: $e');
      return false;
    }
  }

  // ==================== CHAT ====================

  // Generate consistent chat ID for two users
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Send a message
  Future<bool> sendMessage(ChatMessage message, String recipientId) async {
    try {
      // Add message to messages collection
      await _firestore.collection('messages').add(message.toMap());

      // Update or create chat document
      await _firestore.collection('chats').doc(message.chatId).set({
        'participants': [message.senderId, recipientId],
        'lastMessage': message.message,
        'lastMessageTime': message.timestamp.toIso8601String(),
        'lastSenderId': message.senderId,
        'lastSenderName': message.senderName,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Get messages stream for a chat (real-time)
  Stream<List<ChatMessage>> getMessagesStream(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get user's chats stream (real-time)
  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'chatId': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Get user's chats (one-time)
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'chatId': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }
}