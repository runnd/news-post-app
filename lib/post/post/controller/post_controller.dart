import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:product_app/data/status.dart';
import 'package:product_app/models/post/Base_post_request.dart';
import 'package:product_app/models/post/Post_body_request.dart';
import 'package:product_app/models/post/post_category.dart';
import 'package:product_app/models/post/response/post_response.dart';
import 'package:product_app/repository/post/post_repository.dart';

class PostController extends GetxController {
  var categoryList = <PostCategory>[].obs; // List to hold categories
  var isLoading = false.obs;
  var postList = <PostResponse>[].obs; // All posts
  var filteredPosts = <PostResponse>[].obs; // Filtered posts for search
  var userPost = <PostResponse>[].obs; // Filtered posts for search
  var requestLoadingPostStatus = Status.loading.obs;
  var loadingMore = false.obs;
  var currentPage = 1.obs;
  var storage = GetStorage();
  var baseRequest = BasePostRequest().obs;

  final _postRepository = PostRepository();
  var selectedCategoryId = 0.obs;  // Track selected category
  var onCreateLoading = false.obs;

  void setRequestLoadingPostStatus(Status value) {
    requestLoadingPostStatus.value = value;
  }

  @override
  void onInit() {
    loadingData();
    super.onInit();
  }

  loadingData() async {
    print('loading');
    setRequestLoadingPostStatus(Status.loading);
    try {
      await _getAllPost();
      await fetchUserPosts();
      await _fetchAllCategories();
      filteredPosts.assignAll(postList); // Initialize filteredPosts with all posts
      setRequestLoadingPostStatus(Status.completed);
    } catch (e) {
      setRequestLoadingPostStatus(Status.error);
      print("Error loading data: $e");
    }
  }

  _getAllPost() async {
    var request = PostBodyRequest(page: 1);
    var response = await _postRepository.getAllPosts(request);
    print("API Response: ${response.data}");

    if (response.data != null && response.data is List) {
      try {
        postList.assignAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
        filteredPosts.assignAll(postList); // Initialize filtered posts
      } catch (e) {
        print("Error parsing posts: $e");
        throw Exception("Failed to parse posts");
      }
    } else {
      throw Exception("No data available or invalid data format");
    }
  }

  // Method to filter posts by category
  void filterPostsByCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    if (categoryId == 0) {
      filteredPosts.assignAll(postList); // No filter applied, show all posts
    } else {
      filteredPosts.assignAll(postList.where((post) => post.category?.id == categoryId).toList());
    }
  }

  _fetchAllCategories() async {
    var response = await _postRepository.getAllPostCategories(baseRequest.value);
    print('RESPOND Category ${response.data}');
    response.data.forEach((data) {
      categoryList.add(PostCategory.fromJson(data));
    });
  }

  fetchPosts() async {
    setRequestLoadingPostStatus(Status.loading);
    try {
      currentPage.value = 1;
      var request = PostBodyRequest(page: currentPage.value);
      var response = await _postRepository.getAllPosts(request);

      if (response.data != null && response.data is List) {
        postList.assignAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
        filteredPosts.assignAll(postList); // Reset filtered posts
      } else {
        throw Exception("Invalid or empty data");
      }
      setRequestLoadingPostStatus(Status.completed);
    } catch (e) {
      setRequestLoadingPostStatus(Status.error);
      print("Error in fetchPosts: $e");
    }
  }

  getAllPostMore() async {
    if (loadingMore.value) return;

    loadingMore.value = true;
    try {
      var request = PostBodyRequest(page: currentPage.value + 1);
      var response = await _postRepository.getAllPosts(request);

      if (response.data != null && response.data is List) {
        postList.addAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
        filteredPosts.assignAll(postList); // Update filtered posts
        currentPage.value++;
      }
    } catch (e) {
      print("Error loading more posts: $e");
    } finally {
      loadingMore.value = false;
    }
  }

  fetchUserPosts() async {
    var data = storage.read('USER_KEY');
    var userID = data['user']['id'];
    setRequestLoadingPostStatus(Status.loading);
    try {
      var request = PostBodyRequest(userId: userID, status: 'ACT'); // Update request to include userId and status
      var response = await _postRepository.getAllPosts(request);
      print('UserResponse ${response.data}');

      if (response.data != null && response.data is List) {
        userPost.assignAll(
          (response.data as List).map((data) => PostResponse.fromJson(data)).toList(),
        );
      } else {
        throw Exception("Invalid or empty data");
      }
      setRequestLoadingPostStatus(Status.completed);
    } catch (e) {
      setRequestLoadingPostStatus(Status.error);
      print("Error fetching user posts: $e");
    }
  }

  Future<void> createPost({
    required String title,
    required String description,
    required File image,
    required int categoryId,
  }) async {
    onCreateLoading(true);  // Show loading state for creating post
    try {
      // Prepare the post data
      var postData = {
        'title': title,
        'description': description,
        'categoryId': categoryId,
      };

      // Make the API call to create the post (send both postData and image)
      var response = await _postRepository.createPost(postData, image);

      if (response.code == "SUC-000") {
        Get.snackbar("Success", "Post created successfully");
        fetchPosts();  // Refresh the list of posts
      } else {
        Get.snackbar("Error", response.message ?? "Failed to create post");
      }
    } catch (e) {
      // Handle errors
      Get.snackbar("Error", "Failed to create post: $e");
    } finally {
      onCreateLoading(false);  // Hide the loading indicator
    }
  }



  // Search functionality
  void searchPosts(String query) {
    if (query.isEmpty) {
      filteredPosts.assignAll(postList); // Reset to all posts
    } else {
      filteredPosts.assignAll(postList.where((post) {
        final title = post.title?.toLowerCase() ?? '';
        final description = post.description?.toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) || description.contains(query.toLowerCase());
      }).toList());
    }
  }
}
