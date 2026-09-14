import 'dart:convert';
import 'package:http/http.dart' as http;

import 'post.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001/api';

  Future<List<Post>> getPosts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    print('GET POSTS STATUS: ${response.statusCode}');
    print('GET POSTS RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List posts = data is List
          ? data
          : data['data'];

      return posts
          .map((item) => Post.fromJson(item))
          .toList();
    }

    throw Exception(
      'Gagal mengambil artikel: ${response.body}',
    );
  }

  Future<Post> getPost(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$id'),
    );

    print('GET POST STATUS: ${response.statusCode}');
    print('GET POST RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final postData =
          data is Map<String, dynamic> &&
                  data.containsKey('data')
              ? data['data']
              : data;

      return Post.fromJson(postData);
    }

    throw Exception(
      'Gagal mengambil detail artikel: ${response.body}',
    );
  }
  Future<bool> createPost({
    required String title,
    required String content,
    required String country,
    required int categoryId,
    String? imageUrl,
    String? source,
    String? author,
    String? publishedAt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'country': country,
        'category_id': categoryId,
        'image_url': imageUrl,
        'source': source,
        'author': author,
        'published_at': publishedAt,
      }),
    );

    // DEBUG
    print('========================================');
    print('CREATE POST');
    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');
    print('========================================');

    return response.statusCode == 201 ||
        response.statusCode == 200;
  }
  Future<bool> updatePost({
    required int id,
    required String title,
    required String content,
    required String country,
    required int categoryId,
    String? imageUrl,
    String? source,
    String? author,
    String? publishedAt,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'country': country,
        'category_id': categoryId,
        'image_url': imageUrl,
        'source': source,
        'author': author,
        'published_at': publishedAt,
      }),
    );

    // DEBUG
    print('========================================');
    print('UPDATE POST');
    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');
    print('========================================');

    return response.statusCode == 200;
  }
  Future<bool> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
    );

    print('========================================');
    print('DELETE POST');
    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');
    print('========================================');

    return response.statusCode == 200 ||
        response.statusCode == 204;
  }
}