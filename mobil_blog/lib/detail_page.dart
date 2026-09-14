import 'package:flutter/material.dart';

import 'api_service.dart';
import 'form_post_page.dart';
import 'post.dart';

class DetailPage extends StatefulWidget {
  final Post post;

  const DetailPage({
    super.key,
    required this.post,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ApiService apiService = ApiService();

  late Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  Future<void> editPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPostPage(
          post: post,
        ),
      ),
    );

    if (result == true && mounted) {
      final updated = await apiService.getPost(post.id);

      setState(() {
        post = updated;
      });
    }
  }

  Future<void> deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus artikel?'),
          content: const Text(
            'Artikel yang dihapus tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final success = await apiService.deletePost(post.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel berhasil dihapus'),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus artikel'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            onPressed: editPost,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: deletePost,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null &&
                post.imageUrl!.isNotEmpty)
              Image.network(
                post.imageUrl!,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    height: 230,
                    color: const Color(0xFFE8E7EF),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 45,
                        color: Color(0xFF77788A),
                      ),
                    ),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFC),
                          borderRadius:
                              BorderRadius.circular(7),
                        ),
                        child: Text(
                          post.country,
                          style: const TextStyle(
                            color: Color(0xFF7656D6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        post.categoryName ??
                            'Entertainment',
                        style: const TextStyle(
                          color: Color(0xFF77788A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Text(
                    post.title,
                    style: const TextStyle(
                      color: Color(0xFF20213A),
                      fontSize: 25,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 17,
                        color: Color(0xFF77788A),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        post.author ?? 'Redaksi',
                        style: const TextStyle(
                          color: Color(0xFF77788A),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.schedule_outlined,
                        size: 17,
                        color: Color(0xFF77788A),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        post.publishedAt ?? '-',
                        style: const TextStyle(
                          color: Color(0xFF77788A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Divider(
                    color: Color(0xFFE8E7EF),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    post.content,
                    style: const TextStyle(
                      color: Color(0xFF303147),
                      fontSize: 15,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (post.source != null &&
                      post.source!.isNotEmpty)
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF20213A),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            post.source!,
                            style: const TextStyle(
                              color: Color(0xFF77788A),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.bookmark_border,
                        ),
                        label: const Text('Save'),
                      ),

                      const SizedBox(width: 10),

                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                        ),
                        label: const Text('Share'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}