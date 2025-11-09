import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../models/swap_offer.dart';
import '../../providers/swap_provider.dart';
import '../chat/chat_screen.dart';
import 'package:intl/intl.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({Key? key}) : super(key: key);

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(date);
    }
  }

  void _showCancelDialog(BuildContext context, SwapOffer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Swap Offer'),
        content: Text(
          'Are you sure you want to cancel the swap offer for "${offer.bookTitle}"?\n\nThis will make the book available for other users again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Offer',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final swapProvider = Provider.of<SwapProvider>(
                context,
                listen: false,
              );
              
              final success = await swapProvider.cancelSwapOffer(
                offer.id,
                offer.bookId,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Offer canceled successfully' 
                          : 'Failed to cancel offer',
                    ),
                    backgroundColor: success ? AppColors.secondary : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Cancel Offer',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(SwapOffer offer, bool isSent) {
    // Only allow deletion/dismissal for sent offers with Pending status
    final canCancel = isSent && offer.status == 'Pending';
    
    // Determine who to chat with
    final chatRecipientId = isSent ? offer.recipientId : offer.senderId;
    final chatRecipientName = isSent ? offer.recipientName : offer.senderName;

    Widget cardContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to chat with the other party
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                recipientId: chatRecipientId,
                recipientName: chatRecipientName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Title and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.bookTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(offer.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      offer.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(offer.status),
                      ),
                    ),
                  ),
                  // Delete button for sent offers with Pending status
                  if (canCancel) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showCancelDialog(context, offer),
                      tooltip: 'Cancel offer',
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Sender/Recipient info with chat icon
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    radius: 20,
                    child: Text(
                      chatRecipientName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSent ? 'To: $chatRecipientName' : 'From: $chatRecipientName',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          _formatDate(offer.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chat icon hint
                  Icon(
                    Icons.chat_bubble_outline,
                    color: AppColors.secondary.withOpacity(0.6),
                    size: 20,
                  ),
                ],
              ),

              // Action buttons for received offers with Pending status
              if (!isSent && offer.status == 'Pending') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final swapProvider = Provider.of<SwapProvider>(
                            context,
                            listen: false,
                          );
                          final success = await swapProvider.rejectSwapOffer(
                            offer.id,
                            offer.bookId,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Offer rejected'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final swapProvider = Provider.of<SwapProvider>(
                            context,
                            listen: false,
                          );
                          final success = await swapProvider.acceptSwapOffer(
                            offer.id,
                            offer.bookId,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Offer accepted! 🎉'),
                                backgroundColor: AppColors.secondary,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],

              // Hint text for tapping to chat
              if (offer.status == 'Pending' || offer.status == 'Accepted') ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Tap to chat with ${isSent ? 'book owner' : 'requester'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete (only for sent pending offers)
    if (canCancel) {
      return Dismissible(
        key: Key(offer.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(height: 4),
              Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          _showCancelDialog(context, offer);
          return false; // Don't auto-dismiss, let the dialog handle it
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  @override
  Widget build(BuildContext context) {
    final swapProvider = Provider.of<SwapProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'My Offers',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Sent Offers Tab
          StreamBuilder<List<SwapOffer>>(
            stream: swapProvider.watchSentOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading offers',
                        style: TextStyle(fontSize: 16, color: AppColors.textLight),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 80,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No sent offers yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Browse books and request swaps!',
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
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildOfferCard(snapshot.data![index], true);
                },
              );
            },
          ),

          // Received Offers Tab
          StreamBuilder<List<SwapOffer>>(
            stream: swapProvider.watchReceivedOffers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading offers',
                        style: TextStyle(fontSize: 16, color: AppColors.textLight),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: AppColors.textLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No received offers yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Other users can send you swap requests',
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
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return _buildOfferCard(snapshot.data![index], false);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}