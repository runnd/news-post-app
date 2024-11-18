import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:product_app/data/remote/api_url.dart';
import 'package:product_app/post/post/controller/post_controller.dart';
import 'package:product_app/post/post_info/view/post_info_view.dart';

class PostSearchView extends StatelessWidget {
  final PostController postController = Get.find<PostController>();

  PostSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Posts"),
        backgroundColor: const Color(0xFF26247B),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by title or category...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: postController.searchPosts, // Directly pass the search function
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredPosts = postController.filteredPosts;

              if (filteredPosts.isEmpty) {
                return const Center(
                  child: Text(
                    "No posts found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredPosts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: post.image != null
                          ? NetworkImage("${ApiUrl.imageViewPath}${post.image}")
                          : const AssetImage("assets/images/icons/no-image.jpg") as ImageProvider,
                    ),
                    title: Text(
                      post.title ?? "No Title",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      post.description ?? "No Description",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => Get.to(() => PostInfoView(postData: post)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
