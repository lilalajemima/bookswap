// lib/screens/home/my_listings_screen.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../models/book.dart';
import 'post_book_screen.dart';
import 'book_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  List<Book> _myBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyBooks();
  }

  Future<void> _loadMyBooks() async {
    setState(() => _isLoading = true);
    
    // TODO: Load user's books from Firestore
    // Example:
    // String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    //     .collection('books')
    //     .where('ownerId', isEqualTo: currentUserId)
    //     .orderBy('postedAt', descending: true)
    //     .get();
    // 
    // setState(() {
    //   _myBooks = snapshot.docs
    //       .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
    //       .toList();
    //   _isLoading = false;
    // });
    
    // Dummy data for now
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _myBooks = [
        Book(
          id: '3',
          title: 'Database Management',
          author: 'Ramez Elmasri',
          condition: 'Good',
          ownerId: 'currentUser',
          ownerName: 'Me',
          postedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _deleteBook(String bookId) async {
    // TODO: Delete book from Firestore
    // await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
    
    setState(() {
      _myBooks.removeWhere((book) => book.id == bookId);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book deleted successfully'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  void _showDeleteDialog(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBook(book.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'My Listings',
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
              ).then((_) => _loadMyBooks());
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
          : _myBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books_outlined,
                        size: 80,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No books listed',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first book',
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
                  onRefresh: _loadMyBooks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myBooks.length,
                    itemBuilder: (context, index) {
                      final book = _myBooks[index];
                      return Dismissible(
                        key: Key(book.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          _showDeleteDialog(book);
                          return false;
                        },
                        child: BookCard(
                          book: book,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailScreen(
                                  book: book,
                                  isOwner: true,
                                ),
                              ),
                            ).then((_) => _loadMyBooks());
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
