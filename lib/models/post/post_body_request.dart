class PostBodyRequest {
  PostBodyRequest({
    this.limit = 10,
    this.page = 0,
    this.userId = 0,
    this.status = 'ACT',
    this.id = 0,
    this.categoryId = 0,
    this.category, // Added category parameter
    this.title,
    this.description,
    this.name,
  });

  int? limit;
  int? page;
  int? userId;
  String? status;
  int? id;
  int? categoryId; // Assuming you are still using categoryId for filtering
  String? category; // If you're filtering by category name instead of category ID
  String? title;
  String? description;
  String? name;

  // From JSON constructor
  PostBodyRequest.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    page = json['page'];
    userId = json['userId'];
    status = json['status'];
    id = json['id'];
    categoryId = json['categoryId'];
    category = json['category']; // Deserialize category if available
    title = json['title'];
    description = json['description'];
    name = json['name'];
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['limit'] = limit;
    map['page'] = page;
    map['userId'] = userId;
    map['status'] = status;
    map['id'] = id;
    map['categoryId'] = categoryId;
    map['category'] = category; // Add category to JSON if needed
    map['title'] = title;
    map['description'] = description;
    map['name'] = name;
    return map;
  }
}
