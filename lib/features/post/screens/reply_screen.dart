// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:reddit_clone/core/common/error_text.dart';
// import 'package:reddit_clone/core/common/loader.dart';
// import 'package:reddit_clone/features/post/controller/post_controller.dart';
// import 'package:reddit_clone/features/post/widgets/reply_card.dart';
// import 'package:reddit_clone/models/comment_model.dart';

// class ReplyScreen extends ConsumerStatefulWidget {
//   final String commentId;
//   const ReplyScreen({super.key, required this.commentId});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ReplyScreenState();
// }

// class _ReplyScreenState extends ConsumerState<ReplyScreen> {
//   final replyController = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     replyController.dispose();
//   }

//   void addReply(Comment comment) {
//     ref.read(postControllerProvider.notifier).addReply(
//         context: context, text: replyController.text.trim(), comment: comment);
//     setState(() {
//       replyController.text = '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(),
//       body: ref.watch(getCommentByIdProvider(widget.commentId)).when(
//             data: (data) {
//               return Column(
//                 children: [
//                   // PostCard(post: data),
//                   TextField(
//                     onSubmitted: (val) => addReply(data),
//                     controller: replyController,
//                     decoration: const InputDecoration(
//                       hintText: 'What are your thoughts?',
//                       filled: true,
//                       border: InputBorder.none,
//                     ),
//                   ),
//                   ref.watch(getCommentRepliesProvider(widget.commentId)).when(
//                         data: (data) {
//                           return Expanded(
//                             child: ListView.builder(
//                               itemCount: data.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 final reply = data[index];
//                                 return ReplyCard(reply: reply);
//                               },
//                             ),
//                           );
//                         },
//                         error: (error, stackTrace) {
//                           return ErrorText(
//                             error: error.toString(),
//                           );
//                         },
//                         loading: () => const Loader(),
//                       ),
//                 ],
//               );
//             },
//             error: (error, stackTrace) => ErrorText(error: error.toString()),
//             loading: () => const Loader(),
//           ),
//     );
//   }
// }