import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/swap_offer.dart';
import '../models/book.dart';

// this provider manages all swap-related operations and book listings using provider state management. 
//it handles creating swap offers, accepting or rejecting offers, and provides real-time streams for books and offers. 
//this is the central state management class for the swap functionality.

class SwapProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<SwapOffer> _sentOffers = [];
  final List<SwapOffer> _receivedOffers = [];
  final List<Book> _myBooks = [];
  bool _isLoading = false;

  List<SwapOffer> get sentOffers => _sentOffers;
  List<SwapOffer> get receivedOffers => _receivedOffers;
  List<Book> get myBooks => _myBooks;
  bool get isLoading => _isLoading;

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
              SwapOffer.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // real-time stream of swap offers received by current user
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
              SwapOffer.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // method to create a new swap offer
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
        id: '', 
        bookId: bookId,
        bookTitle: bookTitle,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'User',
        recipientId: recipientId,
        recipientName: recipientName,
        status: 'Pending',
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      await _firestore.collection('swap_offers').add(offer.toMap());

      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': 'Pending',
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // method to accept a swap offer
  Future<bool> acceptSwapOffer(String offerId, String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('swap_offers').doc(offerId).update({
        'status': 'Accepted',
      });

      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': 'Accepted',
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error accepting swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // method to reject a swap offer
  Future<bool> rejectSwapOffer(String offerId, String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('swap_offers').doc(offerId).update({
        'status': 'Rejected',
      });

      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': null,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error rejecting swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // real-time stream of books owned by current user
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
              (doc) => Book.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // real-time stream of all books in the marketplace
  Stream<List<Book>> watchAllBooks() {
    return _firestore
        .collection('books')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => Book.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // method to cancel or delete a pending swap offer
  Future<bool> cancelSwapOffer(String offerId, String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('swap_offers').doc(offerId).delete();

      await _firestore.collection('books').doc(bookId).update({
        'swapStatus': null,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error canceling swap offer: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}