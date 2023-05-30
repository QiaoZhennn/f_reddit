import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:f_reddit/features/auth/controller/auth_controller.dart';
import 'package:f_reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils.dart';
import '../../../theme/palette.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen(this.uid, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerImage;
  File? profileImage;
  late TextEditingController nameController;
  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerImage = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileImage = File(res.files.first.path!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void save() {
    ref.read(userProfileControllerProvider.notifier).editUserProfile(
        profileImage, bannerImage, context, nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (data) => Scaffold(
              backgroundColor: Palette.darkModeAppTheme.backgroundColor,
              appBar: AppBar(
                title: Text('Edit Profile'),
                centerTitle: false,
                actions: [
                  TextButton(child: const Text('Save'), onPressed: save)
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(children: [
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(10),
                                  dashPattern: [10, 4],
                                  strokeCap: StrokeCap.round,
                                  color: Palette.darkModeAppTheme.textTheme
                                      .bodyText2!.color!,
                                  child: Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                                                NetworkImage(data.profile),
                                            radius: 32,
                                          ),
                                  )),
                            ]),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Name',
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader());
  }
}
