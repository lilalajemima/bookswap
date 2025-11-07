import 'package:flutter/material.dart';
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
    
    // TODO: Load books from Firestore
    // Example:
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    //     .collection('books')
    //     .orderBy('postedAt', descending: true)
    //     .get();
    // 
    // setState(() {
    //   _books = snapshot.docs
    //       .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
    //       .toList();
    //   _isLoading = false;
    // });
    
    // Dummy data for now
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _books = [
        Book(
          id: '1',
          title: 'Data Structures & Algorithms',
          author: 'Thomas H. Cormen',
          condition: 'Like New',
          ownerId: 'user1',
          ownerName: 'John Doe',
          postedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Book(
          id: '2',
          title: 'Operating Systems',
          author: 'William Stallings',
          condition: 'Used',
          ownerId: 'user2',
          ownerName: 'Jane Smith',
          postedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _isLoading = false;
    });
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