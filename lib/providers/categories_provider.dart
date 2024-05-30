import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/sections_models.dart';
import '../services/firebase_service.dart';

final categoriesProvider = StateNotifierProvider<CategoryData, List<Category>>(
    (ref) => CategoryData());
final sectionProvider =
    StateNotifierProvider<SectionData, List<Section>>((ref) => SectionData());

class CategoryData extends StateNotifier<List<Category>> {
  CategoryData() : super([]);

  Future getCategories() async {
    state = await FirebaseService().getCategories();
    state.sort((a, b) => a.orderIndex!.compareTo(b.orderIndex!));
    debugPrint('got categories');
  }
}

class SectionData extends StateNotifier<List<Section>> {
  SectionData() : super([]);

  Future getSections() async {
    state = await FirebaseService().getSections();
    state.sort((a, b) => a.index!.compareTo(b.index!));
    debugPrint('got sections');
  }
}
