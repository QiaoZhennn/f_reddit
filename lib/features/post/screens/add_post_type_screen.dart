import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:f_reddit/features/community/controller/community_controller.dart';
import 'package:f_reddit/features/post/controller/post_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';
import '../../../responsive/responsive.dart';
import '../../../theme/palette.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen(this.type, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  File? bannerImage;
  Uint8List? bannerImageWeb;
  List<Community> communities = [];
  Community? selectedCommunity;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerImageWeb = res.files.first.bytes;
        });
      }
      setState(() {
        bannerImage = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        (bannerImage != null || bannerImageWeb != null) &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
          context,
          titleController.text.trim(),
          selectedCommunity ?? communities[0],
          bannerImage,
          bannerImageWeb);
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context,
          titleController.text.trim(),
          selectedCommunity ?? communities[0],
          descriptionController.text.trim());
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
          context,
          titleController.text.trim(),
          selectedCommunity ?? communities[0],
          linkController.text.trim());
    } else {
      showSnackBar(context, 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Post ${widget.type}'), actions: [
        TextButton(onPressed: sharePost, child: const Text('Share'))
      ]),
      body: isLoading
          ? const Loader()
          : Responsive(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter title here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18.0)),
                    maxLength: 30,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectBannerImage,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        radius: Radius.circular(10),
                        dashPattern: [10, 4],
                        strokeCap: StrokeCap.round,
                        color: currentTheme.textTheme.bodyText2!.color!,
                        child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10)),
                            child: bannerImageWeb != null
                                ? Image.memory(bannerImageWeb!)
                                : bannerImage != null
                                    ? Image.file(bannerImage!)
                                    : const Center(
                                        child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                      ))),
                      ),
                    )
                  else if (isTypeText)
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter description here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18.0)),
                      maxLines: 5,
                    )
                  else if (isTypeLink)
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                          filled: true,
                          hintText: 'Enter link here',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(18.0)),
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Comunity'),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                      data: (data) {
                        communities = data;
                        if (data.isEmpty) {
                          return const SizedBox();
                        }
                        return DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text(e.name)))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                              });
                            });
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader())
                ]),
              ),
            ),
    );
  }
}
