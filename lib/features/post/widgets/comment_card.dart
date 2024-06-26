import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
// import 'package:reddit_clone/features/post/screens/reply_screen.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/features/post/widgets/reply_card.dart';
import 'package:reddit_clone/models/comment_model.dart';

class CommentCard extends ConsumerStatefulWidget {
  final Comment comment;
  const CommentCard({
    super.key,
    required this.comment,
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  bool _isWidgetVisible = false;
  final replyController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    replyController.dispose();
  }

  void addReply(Comment comment) {
    ref.read(postControllerProvider.notifier).addReply(
        context: context, text: replyController.text.trim(), comment: comment);
    setState(() {
      replyController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.comment.profilePic),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'u/${widget.comment.username}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(widget.comment.text),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isWidgetVisible = !_isWidgetVisible;
                  });
                },
                icon: const Icon(Icons.reply),
              ),
              const Text('Reply - '),
              Text('${widget.comment.replyCount ?? 0} replies')
            ],
          ),
          if (_isWidgetVisible)
            Container(
              margin: const EdgeInsets.only(left: 40.0), // Adjust the left margin as needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isGuest)
                  TextField(
                    onSubmitted: (val) => addReply(widget.comment),
                    controller: replyController,
                    decoration: const InputDecoration(
                      hintText: 'What is your reply?',
                      filled: true,
                      border: InputBorder.none,
                    ),
                  ),
                  Container(
                    // height: 200, 
                    child: ref.watch(getCommentRepliesProvider(widget.comment.id)).when(
                          data: (data) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final reply = data[index];
                                return ReplyCard(reply: reply);
                              },
                            );
                          },
                          error: (error, stackTrace) {
                            return ErrorText(
                              error: error.toString(),
                            );
                          },
                          loading: () => const Loader(),
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
