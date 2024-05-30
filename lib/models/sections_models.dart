import 'package:cloud_firestore/cloud_firestore.dart';

class Section {
  String? id;
  String? name;
  String? thumbnailUrl;
  String? parentId;
  int? index;

  Section(
      {required this.name,
      required this.id,
      required this.thumbnailUrl,
      required this.parentId,
      this.index});

  factory Section.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return Section(
        name: d['name'],
        id: d['id'],
        thumbnailUrl: d['image_url'],
        parentId: d['parent_id'],
        index: d['index']);
  }

  static Map<String, dynamic> getMap(Section d) {
    return {
      'name': d.name,
      'id': d.id,
      'image_url': d.thumbnailUrl,
      'parent_id': d.parentId,
      'index': d.index
    };
  }
}
