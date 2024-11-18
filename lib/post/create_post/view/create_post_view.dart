import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:product_app/post/post/controller/post_controller.dart';
import 'package:product_app/models/post/post_category.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({Key? key}) : super(key: key);

  @override
  _CreatePostViewState createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final PostController postController = Get.put(PostController());

  File? _selectedImage;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Track selected category
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
  }

  // Handle image selection from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Handle post creation
  void _createPost() {
    if (selectedCategoryId == null || _selectedImage == null) {
      Get.snackbar("Error", "Please select a category and image");
      return;
    }

    // Prepare the request data
    postController.createPost(
      title: titleController.text,
      description: descriptionController.text,
      categoryId: selectedCategoryId!,
      image: _selectedImage!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26247B),
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Image.asset(
                      'assets/images/icons/no-image.jpg',
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choose Image',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title Input Field
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  prefixIcon: Icon(Icons.edit, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Description Input Field
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  prefixIcon: Icon(Icons.description, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),

              // Category Dropdown
              Obx(() {
                if (postController.categoryList.isEmpty) {
                  return const CircularProgressIndicator();
                }

                return DropdownButton<int>(
                  value: selectedCategoryId,
                  hint: const Text("Select Category"),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategoryId = newValue;
                    });
                  },
                  items: postController.categoryList.map((PostCategory category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name ?? "Unknown Category"),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 30),

              // Create Button
              ElevatedButton(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26247B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'CREATE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
