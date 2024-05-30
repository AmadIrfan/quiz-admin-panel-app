// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  String? id;
  String? sectionId;
  String? quizId;
  var createdAt;
  var updatedAt;
  String? questionTitle;
  List? options;
  int? correctAnswerIndex;
  bool? hasFourOptions;
  String? questionType;
  String? questionImageUrl;
  String? questionAudioUrl;
  String? questionVideoUrl;
  String? explanation;
  String? optionsType;

  Question(
      {this.id,
      this.sectionId,
      this.quizId,
      this.createdAt,
      this.updatedAt,
      this.questionTitle,
      this.options,
      this.correctAnswerIndex,
      this.hasFourOptions,
      this.questionType,
      this.questionImageUrl,
      this.questionAudioUrl,
      this.questionVideoUrl,
      this.explanation,
      this.optionsType});

  factory Question.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return Question(
        id: d['id'],
        sectionId: d['cat_id'],
        quizId: d['quiz_id'] ?? '',
        createdAt: d['created_at'],
        updatedAt: d['updated_at'],
        questionTitle: d['question_title'],
        options: d['options'],
        correctAnswerIndex: d['correct_ans_index'],
        hasFourOptions: d['has_four_options'],
        questionType: d['question_type'],
        questionImageUrl: d['question_image_url'],
        questionAudioUrl: d['question_audio_url'],
        questionVideoUrl: d['question_video_url'],
        explanation: d['explanation'],
        optionsType: d['options_type']);
  }

  static Map<String, dynamic> getMap(Question d) {
    return {
      'id': d.id,
      'cat_id': d.sectionId,
      'quiz_id': d.quizId,
      'created_at': d.createdAt,
      'updated_at': d.updatedAt,
      'question_title': d.questionTitle,
      'options': d.options,
      'correct_ans_index': d.correctAnswerIndex,
      'has_four_options': d.hasFourOptions,
      'question_type': d.questionType,
      'question_image_url': d.questionImageUrl,
      'question_audio_url': d.questionAudioUrl,
      'question_video_url': d.questionVideoUrl,
      'explanation': d.explanation,
      'options_type': d.optionsType
    };
  }
}
