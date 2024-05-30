import 'package:app_admin/components/category_dropdown.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/providers/categories_provider.dart';

import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../components/image_textfield.dart';
import '../models/sections_models.dart';
import '../services/firebase_service.dart';

class SectionForm extends ConsumerStatefulWidget {
  const SectionForm({Key? key, required this.sections}) : super(key: key);

  final Section? sections;

  @override
  ConsumerState<SectionForm> createState() => _SectionFormState();
}

class _SectionFormState extends ConsumerState<SectionForm> {
  late String _submitBtnText;
  late String _dialogText;
  var nameCtlr = TextEditingController();
  var categoryCtlr = TextEditingController();
  var thumbnailUrlCtlr = TextEditingController();
  final _btnCtlr = RoundedLoadingButtonController();
  var formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'sections';

  String? _selectedCategoryId;
//   bool _timer = true;
//   final int _defaultQuizTime = 2; //2 minutes as default
  XFile? _selectedImage;
  String? _qOrderString;

  _onPickImage() async {
    XFile? image = await AppService().pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        thumbnailUrlCtlr.text = image.name;
      });
    }
  }

  initData() {
    if (widget.sections == null) {
    } else {
      _selectedCategoryId = widget.sections!.parentId;
      nameCtlr.text = widget.sections!.name!;
      thumbnailUrlCtlr.text = widget.sections!.thumbnailUrl!;
//       _qOrderString =
//           AppService.setQuestionOrderString(widget.sections!.questionOrder);
    }
  }

  @override
  void initState() {
    _submitBtnText =
        widget.sections == null ? 'Upload sections' : 'Update sections';
    _dialogText = widget.sections == null
        ? 'Uploaded Successfully!'
        : 'Updated Successfully!';
    initData();
    super.initState();
  }

  void _handleSubmit() async {
    if (hasAccess(ref)) {
      if (_selectedCategoryId != null) {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          if (_selectedImage != null) {
            //local image
            _btnCtlr.start();
            await FirebaseService()
                .uploadImageToFirebaseHosting(
                    _selectedImage!, 'sections_thumbnails')
                .then((String? imageUrl) {
              if (imageUrl != null) {
                setState(() => thumbnailUrlCtlr.text = imageUrl);
                _uploadProcedure();
              } else {
                setState(() {
                  _selectedImage = null;
                  thumbnailUrlCtlr.clear();
                  _btnCtlr.reset();
                });
              }
            });
          } else {
            //netwok image
            _btnCtlr.start();
            _uploadProcedure();
          }
          // ignore: use_build_context_synchronously
          //     openCustomDialog(context, "Description can't be empty", '');
        }
      } else {
        openCustomDialog(context, 'Select A Category First', '');
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  _uploadProcedure() async {
    await uploadSections().then((value) async {
      ref.read(sectionProvider.notifier).getSections();
      _btnCtlr.success();
      debugPrint('Upload Complete');
      if (!mounted) return;
      Navigator.pop(context);
      openCustomDialog(context, _dialogText, '');
    });
  }

  Future uploadSections() async {
    int orderIndex = widget.sections == null ? 0 : widget.sections?.index ?? 0;
    String docId = widget.sections == null
        ? firestore.collection(collectionName).doc().id
        : widget.sections!.id!;
    debugPrint(docId);
    Section d = Section(
      id: docId,
      name: nameCtlr.text,
      thumbnailUrl: thumbnailUrlCtlr.text,
      parentId: _selectedCategoryId,
      index: orderIndex,
    );
    Map<String, dynamic> data = Section.getMap(d);
    debugPrint(data.toString());
    debugPrint(docId);
    await firestore
        .collection(collectionName)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: InkWell(
            child: const CircleAvatar(
              radius: 20,
              child: Icon(Icons.close),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, top: 15),
        child: RoundedLoadingButton(
          animateOnTap: false,
          borderRadius: 5,
          width: 300,
          controller: _btnCtlr,
          onPressed: () => _handleSubmit(),
          color: Theme.of(context).primaryColor,
          elevation: 0,
          child: Wrap(
            children: [
              Text(
                _submitBtnText,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Category',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        CategoryDropdown(
                          selectedCategoryId: _selectedCategoryId,
                          onChanged: (value) {
                            _selectedCategoryId = value;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Section Name',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextFormField(
                            controller: nameCtlr,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: 'Enter Section Title',
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => nameCtlr.clear(),
                                )),
                            validator: (value) {
                              if (value!.isEmpty) return 'Value is empty';
                              return null;
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Section Thumbnail Image',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        ImageTextField(
                          imageCtrl: thumbnailUrlCtlr,
                          imageFile: _selectedImage,
                          onClear: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          onPickImage: _onPickImage,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

//   Row _timerWidget(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Icon(
//           CupertinoIcons.timer,
//           size: 20,
//           color: Theme.of(context).primaryColor,
//         ),
//         const SizedBox(
//           width: 5,
//         ),
//         const Text('Timer: '),
//         const SizedBox(
//           width: 30,
//         ),
//         Radio(
//           value: true,
//           groupValue: _timer,
//           activeColor: Theme.of(context).primaryColor,
//           onChanged: (value) {
//             setState(() {
//               _timer = true;
//             });
//           },
//         ),
//         const Text('On'),
//         const SizedBox(
//           width: 10,
//         ),
//         Radio(
//           value: false,
//           groupValue: _timer,
//           activeColor: Theme.of(context).primaryColor,
//           onChanged: (value) {
//             setState(() {
//               _timer = false;
//             });
//           },
//         ),
//         const Text('Off'),
//         const SizedBox(
//           width: 20,
//         ),
//         Expanded(
//           child: Visibility(
//             visible: _timer,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 5),
//                   child: Text(
//                     'Timer In Minutes Per Complete Quiz',
//                     style: Theme.of(context)
//                         .textTheme
//                         .bodySmall
//                         ?.copyWith(fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 180,
//                   child: TextFormField(
//                       controller: timeCtlr,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: [
//                         FilteringTextInputFormatter.digitsOnly,
//                         LengthLimitingTextInputFormatter(2)
//                       ],
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           hintText: 'Timer in Minutes',
//                           suffixIcon: IconButton(
//                             icon: const Icon(Icons.close),
//                             onPressed: () => timeCtlr.clear(),
//                           )),
//                       validator: (value) {
//                         if (value!.isEmpty) return 'Value is empty';
//                         return null;
//                       }),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

  Widget _questionOrderDropdown() {
    return Container(
        height: 50,
        padding: const EdgeInsets.only(left: 15, right: 15),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30)),
        child: DropdownButtonFormField(
            itemHeight: 50,
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (dynamic value) {
              setState(() {
                _qOrderString = value;
              });
            },
            value: _qOrderString,
            hint: const Text('Select Question Order'),
            items: Constants.questionOrders.map((f) {
              return DropdownMenuItem(
                value: f,
                child: Text(f),
              );
            }).toList()));
  }
}
