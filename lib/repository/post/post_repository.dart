import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/data/remote/network_api_service.dart';
import 'package:product_app/models/post/Base_post_request.dart';
import 'package:product_app/models/post/Post_body_request.dart';
import 'package:product_app/models/post/login/login_res.dart';
import 'package:product_app/models/post/post_base_response.dart';
import 'package:product_app/models/post/post_category.dart';

class PostRepository {
  var storage = GetStorage();
  final _api = NetworkApiService();

  Future<PostBaseResponse> getAllPostCategories(BasePostRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.postAppCategories, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getAllPostCategories: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> createPostCategory(PostCategory req) async {
    try {
      var response = await _api.postApi(ApiUrl.postCreateCategoryPath, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in createPostCategory: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> getCategoryById(BasePostRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.postCategoryByIdPath + req.id.toString(), req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getCategoryById: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> getAllPosts(PostBodyRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.getAllPostPath, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getAllPosts: $e");
      rethrow;
    }
  }

  Future<PostBaseResponse> getPostById(BasePostRequest req) async {
    try {
      var response = await _api.postApi(ApiUrl.getPostByIdPath, req.toJson());
      return PostBaseResponse.fromJson(response);
    } catch (e) {
      print("Error in getPostById: $e");
      rethrow;
    }
  }

  // Create Post with Image upload
  Future<PostBaseResponse> createPost(Map<String, dynamic> postData, File image) async {
    try {
      // Create a MultipartRequest to send the data and image
      var uri = Uri.parse(ApiUrl.createPostPath);  // The API URL
      var request = http.MultipartRequest('POST', uri);

      // Add the post data as fields (text data)
      postData.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add the image file as a multipart file
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      // Retrieve the token from GetStorage
      var storage = GetStorage();
      var user = LoginRes.fromJson(storage.read("USER_KEY"));
      var token = user.accessToken ?? "";

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request and get the response
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        // If successful, read the response body
        var responseBody = await response.stream.bytesToString();
        var responseJson = jsonDecode(responseBody);

        // Handle success response
        return PostBaseResponse.fromJson(responseJson);
      } else {
        // Handle failure response
        throw Exception("Failed to create post: Status Code ${response.statusCode}");
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception("Error in createPost: $e");
    }
  }

}
