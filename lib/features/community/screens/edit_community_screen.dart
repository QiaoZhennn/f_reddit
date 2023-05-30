import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:f_reddit/core/common/error_text.dart';
import 'package:f_reddit/core/common/loader.dart';
import 'package:f_reddit/core/utils.dart';
import 'package:f_reddit/features/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/constants.dart';
import '../../../model/community_model.dart';
import '../../../theme/palette.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen(this.name, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerImage;
  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerImage = File(res.files.first.path!);
      });
    }
  }

  File? profileImage;
  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileImage = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref
        .read(communityControllerProvider.notifier)
        .editCommunity(profileImage, bannerImage, context, community);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (data) => Scaffold(
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                title: Text('Edit Community: ${widget.name}'),
                centerTitle: false,
                actions: [
                  TextButton(
                      onPressed: () => save(data), child: const Text('Save'))
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 200,
                        child: Stack(children: [
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
                                  child: bannerImage != null
                                      ? Image.file(bannerImage!)
                                      : data.banner.isEmpty ||
                                              data.banner ==
                                                  Constants.bannerDefault
                                          ? const Center(
                                              child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 40,
                                            ))
                                          : Image.network(data.banner,
                                              fit: BoxFit.cover)),
                            ),
                          ),
                          Positioned(
                              bottom: 20,
                              left: 20,
                              child: GestureDetector(
                                onTap: selectProfileImage,
                                child: profileImage != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            FileImage(profileImage!),
                                        radius: 32,
                                      )
                                    : CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(data.avatar),
                                        radius: 32,
                                      ),
                              )),
                        ]),
                      ),
                    ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
