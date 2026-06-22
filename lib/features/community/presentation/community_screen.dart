import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/interactive_providers.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String _selectedTag = 'EV Tech';

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _createPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Create Community Post', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTag,
                    items: ['EV Tech', 'Maintenance', 'Tuning', 'General', 'Events'].map((tag) {
                      return DropdownMenuItem(value: tag, child: Text(tag));
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Topic Tag'),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedTag = val ?? 'General';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Share drive reviews, tips, or vehicle queries with owner clubs...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _postController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppColors.darkTextSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_postController.text.isNotEmpty) {
                      ref.read(communityInteractiveProvider.notifier).addPost(
                        'Alex Pierce',
                        _postController.text,
                        _selectedTag,
                      );
                      _postController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post published successfully!')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Publish', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCommentsSheet(BuildContext context, CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 18),
                  Text('Comments (${post.comments.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  
                  // Comments list
                  Expanded(
                    child: post.comments.isEmpty
                        ? const Center(child: Text('No comments yet. Be the first to reply!'))
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: post.comments.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final comment = post.comments[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.person, size: 14, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text('Member Reply', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(comment, style: const TextStyle(fontSize: 12.5)),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Comment Input Bar
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Type comment...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: () {
                          if (_commentController.text.isNotEmpty) {
                            ref.read(communityInteractiveProvider.notifier).addComment(
                              post.id,
                              _commentController.text,
                            );
                            
                            // Re-read updated post comments
                            final updatedPosts = ref.read(communityInteractiveProvider);
                            final updatedPost = updatedPosts.firstWhere((p) => p.id == post.id);

                            setSheetState(() {
                              post = updatedPost;
                            });

                            _commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editPostDialog(BuildContext context, CommunityPost post) {
    _postController.text = post.content;
    _selectedTag = post.tag;
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Edit Community Post', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTag,
                    items: ['EV Tech', 'Maintenance', 'Tuning', 'General', 'Events'].map((tag) {
                      return DropdownMenuItem(value: tag, child: Text(tag));
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Topic Tag'),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedTag = val ?? 'General';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Edit post content...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _postController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppColors.darkTextSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_postController.text.isNotEmpty) {
                      ref.read(communityInteractiveProvider.notifier).editPost(
                        post.id,
                        _postController.text,
                        _selectedTag,
                      );
                      _postController.clear();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post updated successfully!')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deletePostConfirm(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: const Text('Delete Post', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this post? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(communityInteractiveProvider.notifier).deletePost(post.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final posts = ref.watch(communityInteractiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobility Social Club'),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 14),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: AppColors.primary),
            onPressed: () => _createPostDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.forum_outlined, size: 48, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    const SizedBox(height: 12),
                    const Text('No community posts found. Be the first to share!'),
                  ],
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: posts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final isMyPost = post.author == 'Alex Pierce';

                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                      Text(post.authorTitle, style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      post.tag,
                                      style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (isMyPost) ...[
                                    const SizedBox(width: 4),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 16),
                                      onSelected: (action) {
                                        if (action == 'edit') {
                                          _editPostDialog(context, post);
                                        } else if (action == 'delete') {
                                          _deletePostConfirm(post);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Edit Post', style: TextStyle(fontSize: 12))),
                                        const PopupMenuItem(value: 'delete', child: Text('Delete Post', style: TextStyle(color: AppColors.error, fontSize: 12))),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(post.content, style: const TextStyle(fontSize: 13.5, height: 1.45)),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? AppColors.error : AppColors.primary, size: 20),
                                    onPressed: () => ref.read(communityInteractiveProvider.notifier).toggleLike(post.id),
                                  ),
                                  Text('${post.likes}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 14),
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 18),
                                    onPressed: () => _showCommentsSheet(context, post),
                                  ),
                                  Text('${post.comments.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              IconButton(
                                icon: Icon(post.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary, size: 18),
                                onPressed: () {
                                  ref.read(communityInteractiveProvider.notifier).toggleBookmark(post.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(post.isBookmarked ? 'Removed Bookmark' : 'Bookmarked Post'), duration: const Duration(seconds: 1)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
