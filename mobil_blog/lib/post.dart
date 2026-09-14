class Post {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String country;
  final int categoryId;
  final String? categoryName;
  final String? source;
  final String? author;
  final String? publishedAt;
  final String? createdAt;
  final String? updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.country,
    required this.categoryId,
    this.categoryName,
    this.source,
    this.author,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      country: json['country'] ?? '',
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'],
      source: json['source'],
      author: json['author'],
      publishedAt: json['published_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}