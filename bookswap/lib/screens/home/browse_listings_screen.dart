import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../models/book.dart';
import 'post_book_screen.dart';
import 'book_detail_screen.dart';

class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({Key? key}) : super(key: key);

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    
    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('books')
          .orderBy('postedAt', descending: true)
          .get();
      
      setState(() {
        _books = snapshot.docs
            .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((book) => book.ownerId != currentUserId) // Don't show own books
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Browse Listings',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostBookScreen(),
                ),
              ).then((_) => _loadBooks());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            )
          : _books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No books listed yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to post a book!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textLight.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.secondary,
                  onRefresh: _loadBooks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: _books[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(
                                book: _books[index],
                              ),
                            ),
                          ).then((_) => _loadBooks());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}