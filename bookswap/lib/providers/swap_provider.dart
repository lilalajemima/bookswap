import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/swap_offer.dart';
import '../models/book.dart';

class SwapProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SwapOffer> _sentOffers = [];
  List<SwapOffer> _receivedOffers = [];
  List<Book> _myBooks = [];
  bool _isLoading = false;

  List<SwapOffer> get sentOffers => _sentOffers;
  List<SwapOffer> get receivedOffers => _receivedOffers;
  List<Book> get myBooks => _myBooks;
  bool get isLoading => _isLoading;

  // Real-time listener for sent offers
  Stream<List<SwapOffer>> watchSentOffers() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('swap_offers')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SwapOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Real-time listener for received offers
  Stream<List<SwapOffer>> watchReceivedOffers() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('swap_offers')
        .where('recipientId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SwapOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Create swap offer
  Future<bool> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String recipientId,
    required String recipientName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final offer = SwapOffer(
        id: '', // Firestore will generate
        bookId: bookId,
        bookTitle: bookTitle,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'User',
        recipientId: recipientId,
        recipientName: recipientName,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      // Create offer in Firestore
      final docRef =
          await _firestore.collection('swap_offers').add(offer.toMap());

      // Update book status to Pending
      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': 'Pending',
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error creating swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept swap offer
  Future<bool> acceptSwapOffer(String offerId, String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update offer status
      await _firestore.collection('swap_offers').doc(offerId).update({
        'status': 'Accepted',
      });

      // Update book status
      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': 'Accepted',
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error accepting swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reject swap offer
  Future<bool> rejectSwapOffer(String offerId, String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update offer status
      await _firestore.collection('swap_offers').doc(offerId).update({
        'status': 'Rejected',
      });

      // Update book status back to null (available)
      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': null,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error rejecting swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load user's books with real-time updates
  Stream<List<Book>> watchMyBooks() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: currentUserId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Load all books with real-time updates
  Stream<List<Book>> watchAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Cancel/Delete swap offer
  Future<bool> cancelSwapOffer(String offerId, String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Delete the offer document
      await _firestore.collection('swap_offers').doc(offerId).delete();

      // Update book status back to null (available)
      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': null,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error canceling swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
