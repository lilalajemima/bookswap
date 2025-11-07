// lib/screens/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const ChatScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    // TODO: Load messages from Firestore
    // Example:
    // String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // String chatId = _getChatId(currentUserId, widget.recipientId);
    //
    // QuerySnapshot snapshot = await FirebaseFirestore.instance
    //     .collection('messages')
    //     .where('chatId', isEqualTo: chatId)
    //     .orderBy('timestamp', descending: false)
    //     .get();
    //
    // setState(() {
    //   _messages = snapshot.docs
    //       .map((doc) => ChatMessage.fromMap(
    //           doc.data() as Map<String, dynamic>, doc.id))
    //       .toList();
    //   _isLoading = false;
    // });

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _messages = [
        ChatMessage(
          id: '1',
          chatId: 'chat1',
          senderId: widget.recipientId,
          senderName: widget.recipientName,
          message: 'Hi, are you interested in finding?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          id: '2',
          chatId: 'chat1',
          senderId: 'currentUser',
          senderName: 'Me',
          message: "Yes, I'm interested!",
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 58)),
        ),
        ChatMessage(
          id: '3',
          chatId: 'chat1',
          senderId: widget.recipientId,
          senderName: widget.recipientName,
          message: 'Great! When can we meet?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        ),
      ];
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // TODO: Send message to Firestore
    // Example:
    // String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // String currentUserName = FirebaseAuth.instance.currentUser!.displayName ?? 'User';
    // String chatId = _getChatId(currentUserId, widget.recipientId);
    //
    // await FirebaseFirestore.instance.collection('messages').add({
    //   'chatId': chatId,
    //   'senderId': currentUserId,
    //   'senderName': currentUserName,
    //   'message': messageText,
    //   'timestamp': DateTime.now().toIso8601String(),
    // });
    //
    // // Update chat document
    // await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
    //   'participants': [currentUserId, widget.recipientId],
    //   'lastMessage': messageText,
    //   'lastMessageTime': DateTime.now().toIso8601String(),
    // }, SetOptions(merge: true));

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: 'chat1',
        senderId: 'currentUser',
        senderName: 'Me',
        message: messageText,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(time)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(time);
    }
  }

  Widget _buildMessage(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.accent : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? AppColors.textDark : AppColors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(message.timestamp),
              style: TextStyle(
                color: isMe 
                    ? AppColors.textDark.withOpacity(0.6)
                    : AppColors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accent,
              radius: 18,
              child: Text(
                widget.recipientName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.recipientName,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: AppColors.textLight.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textLight.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == 'currentUser';
                          return _buildMessage(message, isMe);
                        },
                      ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.textLight),
                        ),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: AppColors.primary,
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}