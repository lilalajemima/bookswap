// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap_offer.dart';
import '../models/chat_message.dart';

class DatabaseService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // BOOKS
  Future<List<Book>> getAllBooks() async {
    try {
      // QuerySnapshot snapshot = await _firestore
      //     .collection('books')
      //     .orderBy('postedAt', descending: true)
      //     .get();
      //
      // return snapshot.docs
      //     .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      //     .toList();
      
      return [];
    } catch (e) {
      print('Error getting books: $e');
      return [];
    }
  }

  Future<List<Book>> getUserBooks(String userId) async {
    try {
      // QuerySnapshot snapshot = await _firestore
      //     .collection('books')
      //     .where('ownerId', isEqualTo: userId)
      //     .orderBy('postedAt', descending: true)
      //     .get();
      //
      // return snapshot.docs
      //     .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      //     .toList();
      
      return [];
    } catch (e) {
      print('Error getting user books: $e');
      return [];
    }
  }

  Future<String?> addBook(Book book) async {
    try {
      // DocumentReference docRef = await _firestore.collection('books').add(book.toMap());
      // return docRef.id;
      return 'book_id';
    } catch (e) {
      print('Error adding book: $e');
      return null;
    }
  }

  Future<bool> updateBook(String bookId, Map<String, dynamic> data) async {
    try {
      // await _firestore.collection('books').doc(bookId).update(data);
      return true;
    } catch (e) {
      print('Error updating book: $e');
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      // await _firestore.collection('books').doc(bookId).delete();
      return true;
    } catch (e) {
      print('Error deleting book: $e');
      return false;
    }
  }

  // SWAP OFFERS
  Future<String?> createSwapOffer(SwapOffer offer) async {
    try {
      // DocumentReference docRef = await _firestore.collection('swap_offers').add(offer.toMap());
      // 
      // // Update book status
      // await _firestore.collection('books').doc(offer.bookId).update({
      //   'swapStatus': 'Pending',
      // });
      //
      // return docRef.id;
      return 'offer_id';
    } catch (e) {
      print('Error creating swap offer: $e');
      return null;
    }
  }

  Future<List<SwapOffer>> getUserSwapOffers(String userId) async {
    try {
      // // Get offers where user is sender or recipient
      // QuerySnapshot sentSnapshot = await _firestore
      //     .collection('swap_offers')
      //     .where('senderId', isEqualTo: userId)
      //     .get();
      //
      // QuerySnapshot receivedSnapshot = await _firestore
      //     .collection('swap_offers')
      //     .where('recipientId', isEqualTo: userId)
      //     .get();
      //
      // List<SwapOffer> offers = [];
      // offers.addAll(sentSnapshot.docs.map((doc) => 
      //     SwapOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
      // offers.addAll(receivedSnapshot.docs.map((doc) => 
      //     SwapOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id)));
      //
      // return offers;
      
      return [];
    } catch (e) {
      print('Error getting swap offers: $e');
      return [];
    }
  }

  Future<bool> updateSwapOfferStatus(String offerId, String bookId, String status) async {
    try {
      // await _firestore.collection('swap_offers').doc(offerId).update({
      //   'status': status,
      // });
      //
      // await _firestore.collection('books').doc(bookId).update({
      //   'swapStatus': status,
      // });
      
      return true;
    } catch (e) {
      print('Error updating swap offer: $e');
      return false;
    }
  }

  // CHAT
  String getChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<bool> sendMessage(ChatMessage message) async {
    try {
      // await _firestore.collection('messages').add(message.toMap());
      //
      // // Update or create chat document
      // await _firestore.collection('chats').doc(message.chatId).set({
      //   'participants': [message.senderId, /* recipientId */],
      //   'lastMessage': message.message,
      //   'lastMessageTime': message.timestamp.toIso8601String(),
      // }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    // return _firestore
    //     .collection('messages')
    //     .where('chatId', isEqualTo: chatId)
    //     .orderBy('timestamp', descending: false)
    //     .snapshots()
    //     .map((snapshot) => snapshot.docs
    //         .map((doc) => ChatMessage.fromMap(
    //             doc.data() as Map<String, dynamic>, doc.id))
    //         .toList());
    
    return Stream.value([]);
  }

  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      // QuerySnapshot snapshot = await _firestore
      //     .collection('chats')
      //     .where('participants', arrayContains: userId)
      //     .orderBy('lastMessageTime', descending: true)
      //     .get();
      //
      // return snapshot.docs
      //     .map((doc) => {
      //           'chatId': doc.id,
      //           ...doc.data() as Map<String, dynamic>,
      //         })
      //     .toList();
      
      return [];
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }
}