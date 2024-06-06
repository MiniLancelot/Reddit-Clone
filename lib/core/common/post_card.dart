import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/models/user_model.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void editPost(BuildContext context) {
    Routemaster.of(context).push('/edit-post/${post.id}');
  }

  void deletePost(WidgetRef ref, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                ref
                    .read(postControllerProvider.notifier)
                    .deletePost(post, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void upvotePost(WidgetRef ref, UserModel postUser) async {
    ref.read(postControllerProvider.notifier).upvote(post, postUser);
  }

  void downvotePost(WidgetRef ref, UserModel postUser) async {
    ref.read(postControllerProvider.notifier).downvote(post, postUser);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getUserByIdProvider(post.uid)).when(
      data: (postUser) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentTheme.drawerTheme.backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ).copyWith(right: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => navigateToCommunity(context),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          post.communityProfilePic,
                                        ),
                                        radius: 16,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          GestureDetector(
                                              onTap: () => navigateToUser(context),
                                              child: Text(
                                                'u/${post.username}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (post.uid == user.uid)
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => editPost(context),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Pallete.whiteColor,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => deletePost(ref, context),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Pallete.redColor,
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            const SizedBox(height: 10),
                            if (isTypeImage)
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.35,
                                width: double.infinity,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      post.link!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            if (isTypeLink)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                ),
                              ),
                            if (isTypeText)
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Text(
                                  post.description!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => upvotePost(ref, postUser),
                                      icon: Icon(
                                        Constants.up,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid)
                                            ? Pallete.redColor
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    IconButton(
                                        onPressed: () => downvotePost(ref, postUser),
                                        icon: Icon(
                                          Constants.down,
                                          size: 30,
                                          color: post.downvotes.contains(user.uid)
                                              ? Pallete.blueColor
                                              : null,
                                        ))
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => navigateToComments(context),
                                      icon: const Icon(
                                        Icons.comment,
                                      ),
                                    ),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                ref
                                    .watch(getCommunityByNameProvider(
                                        post.communityName))
                                    .when(
                                      data: (date) {
                                        if (date.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () =>
                                                deletePost(ref, context),
                                            icon: const Icon(
                                              Icons.admin_panel_settings,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const Loader(),
                                    ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ))
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
    }, 
    error:(error, stackTrace) => ErrorText(error: error.toString()), 
    loading: () => const Loader());
  }
}
