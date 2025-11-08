import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/book.dart';
import '../../services/database_service.dart';

class PostBookScreen extends StatefulWidget {
  final Book? book; // For editing existing book

  const PostBookScreen({Key? key, this.book}) : super(key: key);

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _databaseService = DatabaseService();
  String _selectedCondition = 'Used';
  File? _imageFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _authorController.text = widget.book!.author;
      _selectedCondition = widget.book!.condition;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Create unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Reference to Firebase Storage
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('book_covers')
          .child(fileName);

      // Upload file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      
      // Wait for upload to complete
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        
        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        // Upload image if a new one was selected
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImage(_imageFile!);
          if (imageUrl == null) {
            setState(() => _isLoading = false);
            return; // Upload failed, don't continue
          }
        }

        if (widget.book == null) {
          // Create new book
          Book newBook = Book(
            id: '', // Firestore will generate this
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            condition: _selectedCondition,
            imageUrl: imageUrl,
            ownerId: currentUser.uid,
            ownerName: currentUser.displayName ?? 'User',
            postedAt: DateTime.now(),
          );

          String? bookId = await _databaseService.addBook(newBook);
          
          if (bookId == null) {
            throw Exception('Failed to create book');
          }
        } else {
          // Update existing book
          Map<String, dynamic> updateData = {
            'title': _titleController.text.trim(),
            'author': _authorController.text.trim(),
            'condition': _selectedCondition,
          };

          // Only update imageUrl if a new image was uploaded
          if (imageUrl != null) {
            updateData['imageUrl'] = imageUrl;
          }

          bool success = await _databaseService.updateBook(
            widget.book!.id,
            updateData,
          );

          if (!success) {
            throw Exception('Failed to update book');
          }
        }

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.book == null
                  ? 'Book posted successfully!'
                  : 'Book updated successfully!'),
              backgroundColor: AppColors.secondary,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
        title: Text(
          widget.book == null ? 'Post a Book' : 'Edit Book',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.book?.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    widget.book!.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          color: AppColors.secondary,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 48,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add Cover Image',
                                            style: TextStyle(
                                              color: AppColors.secondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 48,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Cover Image',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Book Title
                CustomTextField(
                  label: 'Book Title',
                  controller: _titleController,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Book title'),
                ),

                const SizedBox(height: 16),

                // Author
                CustomTextField(
                  label: 'Author',
                  controller: _authorController,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Author'),
                ),

                const SizedBox(height: 24),

                // Condition Selection
                const Text(
                  'Condition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.bookConditions.map((condition) {
                    final isSelected = _selectedCondition == condition;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCondition = condition;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.secondary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          condition,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Submit Button
                CustomButton(
                  text: widget.book == null ? 'Post Book' : 'Update Book',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}