import 'package:flutter/material.dart';

import 'api_service.dart';
import 'post.dart';

class FormPostPage extends StatefulWidget {
  final Post? post;

  const FormPostPage({
    super.key,
    this.post,
  });

  @override
  State<FormPostPage> createState() => _FormPostPageState();
}

class _FormPostPageState extends State<FormPostPage> {
  final ApiService apiService = ApiService();

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final imageController = TextEditingController();
  final sourceController = TextEditingController();
  final authorController = TextEditingController();
  final dateController = TextEditingController();

  String country = 'Thailand';
  int categoryId = 1;

  bool isSaving = false;

  final categories = const {
    1: 'Series',
    2: 'Actors & Artists',
    3: 'Film',
    4: 'Music',
    5: 'Entertainment',
    6: 'Lifestyle',
  };

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      final post = widget.post!;

      titleController.text = post.title;
      contentController.text = post.content;
      imageController.text = post.imageUrl ?? '';
      sourceController.text = post.source ?? '';
      authorController.text = post.author ?? '';
      dateController.text = post.publishedAt ?? '';

      country = post.country;
      categoryId = post.categoryId;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    imageController.dispose();
    sourceController.dispose();
    authorController.dispose();
    dateController.dispose();

    super.dispose();
  }

  bool validate() {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Judul, isi artikel, dan author wajib diisi',
          ),
        ),
      );

      return false;
    }

    return true;
  }

  Future<void> savePost() async {
    if (!validate()) return;

    setState(() {
      isSaving = true;
    });

    try {
      bool success;

      if (widget.post == null) {
        success = await apiService.createPost(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          country: country,
          categoryId: categoryId,
          imageUrl: imageController.text.trim(),
          source: sourceController.text.trim(),
          author: authorController.text.trim(),
          publishedAt: dateController.text.trim(),
        );
      } else {
        success = await apiService.updatePost(
          id: widget.post!.id,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          country: country,
          categoryId: categoryId,
          imageUrl: imageController.text.trim(),
          source: sourceController.text.trim(),
          author: authorController.text.trim(),
          publishedAt: dateController.text.trim(),
        );
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.post == null
                  ? 'Artikel berhasil ditambahkan'
                  : 'Artikel berhasil diperbarui',
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal menyimpan artikel',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF20213A),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Article' : 'Add Article',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            fieldLabel('Title'),

            TextField(
              controller: titleController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Judul artikel',
              ),
            ),

            const SizedBox(height: 18),

            fieldLabel('Content'),

            TextField(
              controller: contentController,
              minLines: 8,
              maxLines: 15,
              decoration: const InputDecoration(
                hintText: 'Isi artikel...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 18),

            fieldLabel('Image URL'),

            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                hintText: 'https://...',
                prefixIcon: Icon(
                  Icons.image_outlined,
                ),
              ),
            ),

            const SizedBox(height: 18),

            fieldLabel('Country'),

            DropdownButtonFormField<String>(
              initialValue: country,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(
                  value: 'Thailand',
                  child: Text('Thailand'),
                ),
                DropdownMenuItem(
                  value: 'Korea',
                  child: Text('Korea'),
                ),
                DropdownMenuItem(
                  value: 'Indonesia',
                  child: Text('Indonesia'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  country = value;
                });
              },
            ),

            const SizedBox(height: 18),

            fieldLabel('Category'),

            DropdownButtonFormField<int>(
              initialValue: categoryId,
              decoration: const InputDecoration(),
              items: categories.entries.map(
                (entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  categoryId = value;
                });
              },
            ),

            const SizedBox(height: 18),

            fieldLabel('Source'),

            TextField(
              controller: sourceController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Reuters, SBS, GMMTV',
              ),
            ),

            const SizedBox(height: 18),

            fieldLabel('Author'),

            TextField(
              controller: authorController,
              decoration: const InputDecoration(
                hintText: 'Nama author',
              ),
            ),

            const SizedBox(height: 18),

            fieldLabel('Published Date'),

            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7656D6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit
                            ? 'Save Changes'
                            : 'Publish Article',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}