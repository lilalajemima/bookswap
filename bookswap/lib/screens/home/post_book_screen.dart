import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/book.dart';

// this screen allows users to create new book listings or edit existing ones. 
//it provides form fields for book details, supports image selection from gallery, converts images to base64 for storage, validates all inputs before submission, and updates firestore with the book data.

class PostBookScreen extends StatefulWidget {
  final Book? book;

  const PostBookScreen({Key? key, this.book}) : super(key: key);

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
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
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
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

  // method to convert image file to base64 string
  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      String base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  // method to handle form submission
  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? imageUrl;
        

        if (_imageFile != null) {
          imageUrl = await _convertImageToBase64(_imageFile!);
          if (imageUrl == null) {
            throw Exception('Failed to process image');
          }
        }

        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        String currentUserName = FirebaseAuth.instance.currentUser!.displayName ?? 'User';

        if (widget.book == null) {
          await FirebaseFirestore.instance.collection('books').add({
            'title': _titleController.text.trim(),
            'author': _authorController.text.trim(),
            'condition': _selectedCondition,
            'imageUrl': imageUrl,
            'ownerId': currentUserId,
            'ownerName': currentUserName,
            'postedAt': DateTime.now().toIso8601String(),
            'swapStatus': null,
          });
        } else {
          Map<String, dynamic> updateData = {
            'title': _titleController.text.trim(),
            'author': _authorController.text.trim(),
            'condition': _selectedCondition,
          };
          
          if (imageUrl != null) {
            updateData['imageUrl'] = imageUrl;
          }
          
          await FirebaseFirestore.instance
              .collection('books')
              .doc(widget.book!.id)
              .update(updateData);
        }

        if (mounted) {
          setState(() => _isLoading = false);
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
        print('Error in _handleSubmit: $e');
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // build method to create ui
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
                                  child: widget.book!.imageUrl!.startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(widget.book!.imageUrl!.split(',')[1]),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          widget.book!.imageUrl!,
                                          fit: BoxFit.cover,
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
                
                CustomTextField(
                  label: 'Book Title',
                  controller: _titleController,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Book title'),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Author',
                  controller: _authorController,
                  validator: (value) =>
                      Validators.validateRequired(value, 'Author'),
                ),
                const SizedBox(height: 24),
                

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
                

                CustomButton(
                  text: widget.book == null ? 'Post' : 'Update',
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