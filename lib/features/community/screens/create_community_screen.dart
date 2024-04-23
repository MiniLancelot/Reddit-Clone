import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/community/controller/community_controller.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
  String communityName = communityNameController.text.trim(); // Trim the input text
  ref.read(communityControllerProvider.notifier).createCommunity(
    communityName, 
    context,
  );
}

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Community'),
      ),
      body:isLoading
      ? const Loader()
      : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Align(alignment: Alignment.topLeft, child: Text('Community name')),
            const SizedBox(height: 10),
            TextField(
              controller: communityNameController,
              decoration: const InputDecoration(
                hintText: 'r/Community_name',
                filled: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
                fillColor: Color(0xff191819),
              ),
              maxLength: 21,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')), // Allow only alphanumeric characters and underscore
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: createCommunity, 
              
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xff191819),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                
                ),
              ),
              child: const Text(
                'Create community',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}