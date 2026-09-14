import 'package:flutter/material.dart';

import 'api_service.dart';
import 'detail_page.dart';
import 'form_post_page.dart';
import 'login_page.dart';
import 'post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();

  List<Post> posts = [];
  List<Post> filteredPosts = [];

  bool isLoading = true;
  int selectedNav = 0;

  String selectedCategory = 'All';

  final searchController = TextEditingController();

  final categories = [
    'All',
    'Series',
    'Actors & Artists',
    'Film',
    'Music',
    'Entertainment',
    'Lifestyle',
  ];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await apiService.getPosts();

      setState(() {
        posts = result;
        filteredPosts = result;
        isLoading = false;
      });

      applyFilter();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengambill data: $e',
          ),
        ),
      );
    }
  }

  void applyFilter() {
    final keyword = searchController.text.toLowerCase();

    final result = posts.where((post) {
      final matchCategory =
          selectedCategory == 'All' ||
          post.categoryName == selectedCategory;

      final matchSearch =
          post.title.toLowerCase().contains(keyword) ||
          post.content.toLowerCase().contains(keyword);

      return matchCategory && matchSearch;
    }).toList();

    setState(() {
      filteredPosts = result;
    });
  }

  Color countryColor(String country) {
    switch (country) {
      case 'Thailand':
        return const Color(0xFFFCE4E4);

      case 'Korea':
        return const Color(0xFFE4ECFC);

      case 'Indonesia':
        return const Color(0xFFE2F4E9);

      default:
        return const Color(0xFFE8E7EF);
    }
  }

  Future<void> openCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormPostPage(),
      ),
    );

    if (result == true) {
      loadPosts();
    }
  }

  Future<void> openDetail(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(post: post),
      ),
    );

    if (result == true) {
      loadPosts();
    }
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Widget buildHome() {
    return RefreshIndicator(
      onRefresh: loadPosts,
      child: CustomScrollView(
        slivers: [
          // CATEGORY
          SliverToBoxAdapter(
            child: SizedBox(
              height: 55,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected =
                      category == selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                    ),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });

                        applyFilter();
                      },
                      selectedColor:
                          const Color(0xFF7656D6),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : const Color(0xFF77788A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE8E7EF),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // LOADING
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )

          // EMPTY
          else if (filteredPosts.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Artikel tidak ditemukan',
                  style: TextStyle(
                    color: Color(0xFF77788A),
                  ),
                ),
              ),
            )

          // ARTICLES
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                100,
              ),
              sliver: SliverList(
                delegate:
                    SliverChildBuilderDelegate(
                  (context, index) {
                    final post =
                        filteredPosts[index];

                    return GestureDetector(
                      onTap: () =>
                          openDetail(post),
                      child: Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: const Color(
                              0xFFE8E7EF,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            // IMAGE
                            if (post.imageUrl != null &&
                                post.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius:
                                    const BorderRadius
                                        .vertical(
                                  top: Radius.circular(
                                    14,
                                  ),
                                ),
                                child: Image.network(
                                  post.imageUrl!,
                                  width:
                                      double.infinity,
                                  height: 190,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return Container(
                                      height: 190,
                                      color:
                                          const Color(
                                        0xFFE8E7EF,
                                      ),
                                      child:
                                          const Center(
                                        child: Icon(
                                          Icons
                                              .image_outlined,
                                          size: 40,
                                          color:
                                              Color(
                                            0xFF77788A,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // ARTICLE INFO
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 9,
                                          vertical: 5,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              countryColor(
                                            post.country,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            7,
                                          ),
                                        ),
                                        child: Text(
                                          post.country,
                                          style:
                                              const TextStyle(
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Expanded(
                                        child: Text(
                                          post.categoryName ??
                                              'Entertainment',
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF77788A,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Text(
                                    post.title,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF20213A,
                                      ),
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Text(
                                    post.content,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      color:
                                          Color(
                                        0xFF77788A,
                                      ),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 12,
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .schedule_outlined,
                                        size: 15,
                                        color:
                                            Color(
                                          0xFF77788A,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Text(
                                        post.publishedAt ??
                                            '-',
                                        style:
                                            const TextStyle(
                                          color:
                                              Color(
                                            0xFF77788A,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),

                                      const Spacer(),

                                      const Icon(
                                        Icons
                                            .arrow_forward,
                                        size: 18,
                                        color:
                                            Color(
                                          0xFF7656D6,
                                        ),
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
                  },
                  childCount:
                      filteredPosts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSearchPage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            25,
            20,
            15,
          ),
          child: TextField(
            controller: searchController,
            onChanged: (_) {
              applyFilter();
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search articles...',
              prefixIcon:
                  const Icon(Icons.search),
              suffixIcon:
                  searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();
                            applyFilter();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        )
                      : null,
            ),
          ),
        ),

        Expanded(
          child: filteredPosts.isEmpty
              ? const Center(
                  child: Text(
                    'Artikel tidak ditemukan',
                    style: TextStyle(
                      color: Color(0xFF77788A),
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    100,
                  ),
                  itemCount:
                      filteredPosts.length,
                  itemBuilder:
                      (context, index) {
                    final post =
                        filteredPosts[index];

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      leading:
                          post.imageUrl != null &&
                                  post.imageUrl!
                                      .isNotEmpty
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),
                                  child:
                                      Image.network(
                                    post.imageUrl!,
                                    width: 80,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Container(
                                        width: 80,
                                        height: 70,
                                        color:
                                            const Color(
                                          0xFFE8E7EF,
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .image_outlined,
                                          color:
                                              Color(
                                            0xFF77788A,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 70,
                                  color:
                                      const Color(
                                    0xFFE8E7EF,
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .image_outlined,
                                    color:
                                        Color(
                                      0xFF77788A,
                                    ),
                                  ),
                                ),
                      title: Text(
                        post.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                          color:
                              Color(0xFF20213A),
                        ),
                      ),
                      subtitle: Text(
                        '${post.country} • ${post.categoryName ?? ''}',
                      ),
                      onTap: () =>
                          openDetail(post),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(
          height: 25,
        ),

        const Center(
          child: CircleAvatar(
            radius: 42,
            backgroundColor:
                Color(0xFF17182F),
            child: Icon(
              Icons.person_outline,
              size: 42,
              color: Color(0xFFA78BFA),
            ),
          ),
        ),

        const SizedBox(
          height: 15,
        ),

        const Center(
          child: Text(
            'PopDaily Asia Reader',
            style: TextStyle(
              color: Color(0xFF20213A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        const Center(
          child: Text(
            'Entertainment enthusiast',
            style: TextStyle(
              color: Color(0xFF77788A),
            ),
          ),
        ),

        const SizedBox(
          height: 35,
        ),

        // SETTINGS
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          leading: const Icon(
            Icons.settings_outlined,
            color: Color(0xFF7656D6),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF77788A),
          ),
          onTap: () {},
        ),

        const SizedBox(
          height: 10,
        ),

        // LOGOUT
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          leading: const Icon(
            Icons.logout,
            color: Colors.redAccent,
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF77788A),
          ),
          onTap: logout,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (selectedNav) {
      case 1:
        body = buildSearchPage();
        break;

      case 2:
        body = buildProfilePage();
        break;

      default:
        body = buildHome();
        break;
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: const Text(
          'PopDaily Asia',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: body,

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: selectedNav,
        onDestinationSelected:
            (index) {
          setState(() {
            selectedNav = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor:
            const Color(0xFFF0EDFC),

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.search,
            ),
            selectedIcon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),

      floatingActionButton:
          selectedNav == 0
              ? FloatingActionButton(
                  onPressed: openCreate,
                  backgroundColor:
                      const Color(0xFF7656D6),
                  foregroundColor:
                      Colors.white,
                  child: const Icon(
                    Icons.add,
                  ),
                )
              : null,
    );
  }
}