import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/enums/enums.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/providers/firebase_provider.dart';
import 'package:reddit_clone/core/type_defs.dart';
import 'package:reddit_clone/models/comment_model.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/models/reply_model.dart';
import 'package:reddit_clone/models/user_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(firestore: ref.watch(firestoreProvider));
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  CollectionReference get _replies =>
      _firestore.collection(FirebaseConstants.replyCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(Post post, String userId, UserModel postUser) async {
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
      _users
          .doc(post.uid)
          .update({'karma': postUser.karma + 3});
    }

    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
      _users
          .doc(post.uid)
          .update({'karma': postUser.karma - UserKarma.upvote.karma});
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
      _users
          .doc(post.uid)
          .update({'karma': postUser.karma + UserKarma.upvote.karma});
    }
  }

  void downvote(Post post, String userId, UserModel postUser) async {
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
      _users
          .doc(post.uid)
          .update({'karma': postUser.karma - 1});
    }

    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
      _users
          .doc(post.uid)
          .update({'karma': postUser.karma - UserKarma.downvote.karma});
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
      _users
          .doc(post.uid)
          .update({'karma': postUser.karma + UserKarma.downvote.karma});
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map(
          (event) => Post.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  Stream<Comment> getCommentById(String commentId) {
    return _comments
        .doc(commentId)
        .snapshots()
        .map((event) => Comment.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Comment.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  FutureVoid addReply(Reply reply, String postId) async {
    try {
      await _replies.doc(reply.id).set(reply.toMap());
      await _posts.doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
      return right(_comments.doc(reply.commentId).update({
        'replyCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Reply>> getRepliesOfComment(String commentId) {
    return _replies
        .where('commentId', isEqualTo: commentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Reply.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }
}
