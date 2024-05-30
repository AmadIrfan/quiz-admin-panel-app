import 'package:app_admin/models/sections_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/categories_provider.dart';

class CategoryDropdown extends ConsumerWidget {
  const CategoryDropdown(
      {Key? key, required this.selectedCategoryId, required this.onChanged})
      : super(key: key);

  final String? selectedCategoryId;
  final Function onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButtonFormField(
        itemHeight: 50,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (dynamic value) {
          onChanged(value);
        },
        value: selectedCategoryId,
        hint: const Text('Select Category'),
        items: categories.map(
          (f) {
            return DropdownMenuItem(
              value: f.id,
              child: Text(f.name!),
            );
          },
        ).toList(),
      ),
    );
  }
}
class SectionAllDropdown extends ConsumerWidget {
  const SectionAllDropdown(
      {Key? key, required this.selectedSectionId, required this.onChanged})
      : super(key: key);

  final String? selectedSectionId;
  final Function onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(sectionProvider);
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButtonFormField(
        itemHeight: 50,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (dynamic value) {
          onChanged(value);
        },
        value: selectedSectionId,
        hint: const Text('Select Section'),
        items: categories.map(
          (f) {
            return DropdownMenuItem(
              value: f.id,
              child: Text(f.name!),
            );
          },
        ).toList(),
      ),
    );
  }
}

class SectionDropdown extends ConsumerWidget {
  const SectionDropdown({
    Key? key,
    required this.onChanged,
    required this.selectedSectionId,
    required this.selectedCategoryId,
  }) : super(key: key);

  final String? selectedCategoryId;
  final String? selectedSectionId;
  final Function onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(sectionProvider);
    Set<Section> selectedCategories = {};
    selectedCategories = categories
        .where(
          (element) => element.parentId == selectedCategoryId,
        )
        .toSet();
//     debugPrint(
//         '$selectedCategoryId =====> ${selectedCategories.map((e) => e.parentId)}');
    final isValidSectionId =
        selectedCategories.any((section) => section.id == selectedSectionId);
    final dropdownValue = isValidSectionId ? selectedSectionId : null;
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 15, right: 15),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5)),
      child: DropdownButtonFormField(
        itemHeight: 50,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (value) {
          onChanged(value);
        },
        value: dropdownValue,
        hint: const Text('Select Section'),
        items: selectedCategories.map(
          (f) {
            return DropdownMenuItem(
              value: f.id,
              child: Text(f.name!),
            );
          },
        ).toList(),
      ),
    );
  }
}
