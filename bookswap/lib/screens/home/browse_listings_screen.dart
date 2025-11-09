import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../models/book.dart';
import '../../providers/swap_provider.dart';
import 'post_book_screen.dart';
import 'book_detail_screen.dart';

// this screen displays all book listings from all users in the marketplace. 
//it uses a real-time stream to show books as they are posted, allows users to browse available books, and provides navigation to view book details or post new books.

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);

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
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: swapProvider.watchAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            );
          }


          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return BookCard(
                book: snapshot.data![index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailScreen(
                        book: snapshot.data![index],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}