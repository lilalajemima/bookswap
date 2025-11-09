import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../services/database_service.dart';
import 'chat_screen.dart';

// this screen displays a list of all active chat conversations for the current user. 
//it shows chat previews with the last message, recipient name, and timestamp. 
//users can tap on any chat to open the full conversation and the list updates in real-time as new messages arrive.

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {

  final DatabaseService _databaseService = DatabaseService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String _getRecipientName(Map<String, dynamic> chat) {
    List participants = chat['participants'] ?? [];

    if (chat['lastSenderId'] != _currentUserId && chat['lastSenderName'] != null) {
      return chat['lastSenderName'];
    }

    return 'User';
  }


  String? _getRecipientId(Map<String, dynamic> chat) {
    List participants = chat['participants'] ?? [];
    
    for (var participantId in participants) {
      if (participantId != _currentUserId) {
        return participantId;
      }
    }
    
    return null;
  }

  // build method to create ui
  @override
  Widget build(BuildContext context) {

    if (_currentUserId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            'Chats',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text('Please log in to view chats'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _databaseService.getUserChatsStream(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.secondary,
              ),
            );
          }


          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading chats',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
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
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppColors.textLight.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation from book details',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!;
          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final recipientName = _getRecipientName(chat);
                final recipientId = _getRecipientId(chat);
                
                if (recipientId == null) {
                  return const SizedBox.shrink();
                }

                DateTime lastMessageTime;
                try {
                  lastMessageTime = DateTime.parse(chat['lastMessageTime']);
                } catch (e) {
                  lastMessageTime = DateTime.now();
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      radius: 28,
                      child: Text(
                        recipientName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      chat['lastMessage'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(lastMessageTime),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientId: recipientId,
                            recipientName: recipientName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}