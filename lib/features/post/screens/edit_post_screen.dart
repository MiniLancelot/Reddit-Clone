import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/error_text.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/post/controller/post_controller.dart';
import 'package:reddit_clone/models/community_model.dart';
import 'package:reddit_clone/models/post_model.dart';
import 'package:reddit_clone/theme/pallete.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final String id;
  const EditPostScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditPostTypeScreenState();
}

class _EditPostTypeScreenState extends ConsumerState<EditPostScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerFile;
  Community? selectedCommunity;
  bool isDataLoaded = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void initializeControllersWithData(data) {
    if (!isDataLoaded) {
      titleController.text = data.title ?? '';
      descriptionController.text = data.description ?? '';
      linkController.text = data.link ?? '';
      setState(() {
        isDataLoaded = true;
      });
    }
  }

  void updatePost(Post data) {
    if (data.type == 'text' && titleController.text.isNotEmpty) {
      Post updatedPost = data.copyWith(
          title: titleController.text.trim(),
          description: descriptionController.text.trim());
      ref
          .read(postControllerProvider.notifier)
          .updateTextPost(context, updatedPost);
    } else if (data.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      Post updatedPost = data.copyWith(
          title: titleController.text.trim(), link: linkController.text.trim());
      ref
          .read(postControllerProvider.notifier)
          .updateLinkPost(context, updatedPost);
    } else if (data.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).updateImagePost(
          context: context,
          data: data,
          title: titleController.text.trim(),
          file: bannerFile);
    } else {
      showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);
    return ref.watch(getPostByIdProvider(widget.id)).when(
          data: (data) {
            initializeControllersWithData(data);
            final isTypeImage = data.type == 'image';
            final isTypeText = data.type == 'text';
            final isTypeLink = data.type == 'link';
            return Scaffold(
                appBar: AppBar(
                  title: Text('Post ${data.type}'),
                  actions: [
                    TextButton(
                      onPressed: () => updatePost(data),
                      child: const Text('Update'),
                    ),
                  ],
                ),
                body: isLoading
                    ? const Loader()
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                filled: true,
                                hintText: 'Enter Title here',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(18),
                              ),
                              maxLength: 30,
                            ),
                            const SizedBox(height: 10),
                            if (isTypeImage)
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color:
                                      currentTheme.textTheme.bodyText2!.color!,
                                  child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : data.link!.isEmpty ? const Center(
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 40,
                                              ),
                                            ) :Image.network(data.link!),), 
                                ),
                              ),
                            if (isTypeText)
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: 'Enter Description here',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(18),
                                ),
                                maxLines: 5,
                              ),
                            if (isTypeLink)
                              TextField(
                                controller: linkController,
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: 'Enter Link here',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(18),
                                ),
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                            Align(
                                alignment: Alignment.topLeft,
                                child:
                                    Text('Community: ${data.communityName}')),
                          ],
                        ),
                      ));
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
