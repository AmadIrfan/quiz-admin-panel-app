import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../providers/user_role_provider.dart';


class AuthService{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;


  Future<UserCredential?> loginWithEmailPassword (String username, String password) async {
    UserCredential? userCredential;
    await _firebaseAuth.signInWithEmailAndPassword(
      email: username, 
      password: password
    ).then((UserCredential user)async{
      userCredential = user;
    }).catchError((e){
      debugPrint('SignIn Error: $e');
    });

    return userCredential;

  }

  Future loginAnnonumously () async {
    await Future.delayed(const Duration(seconds: 1));
  }
  

  Future adminLogout () async {
    return _firebaseAuth.signOut().then((value){
      debugPrint('Logout Success');
    }).catchError((e){
      debugPrint('Logout error: $e');
    });
  }


  // Future<bool?> checkAdminAccount (String uid) async{
  //   bool? isAdmin;
  //   await _firebaseFirestore.collection('users').doc(uid).get().then((DocumentSnapshot snap){
  //     if(snap.exists){
  //       List? userRole = snap['role'];
  //       debugPrint('User Role: $userRole');
  //       if(userRole != null && userRole.contains('admin')){
  //         isAdmin = true;
  //       }else{
  //         isAdmin = false;
  //       }
  //     }else{
  //       isAdmin = false;
  //     }
  //   }).catchError((e){
  //     isAdmin = false;
  //     debugPrint('check admin error: $e');
  //   });
  //   return isAdmin;
  // }

  // Future<String?> checkUserRole (String uid) async{
  //   String? userRole;
  //   await _firebaseFirestore.collection('users').doc(uid).get().then((DocumentSnapshot snap){
  //     if(snap.exists){
  //       List? role = snap['role'];
  //       if(role != null && role.contains('admin')){
  //         userRole = 'admin';
  //       }else if(role !=  null && role.contains('editor')){
  //         userRole = 'editor';
  //       }
  //     }else{
  //       userRole = null;
  //     }
  //   }).catchError((e){
  //     userRole = null;
  //     debugPrint('check admin error: $e');
  //   });
  //   return userRole;
  // }

  //  Future<UserRoles> checkUserRole(String uid) async {
  //   UserRoles authState = UserRoles.none;
  //   await _firebaseFirestore.collection('users').doc(uid).get().then((DocumentSnapshot snap) {
  //     if (snap.exists) {
  //       List? userRole = snap['role'];
  //       debugPrint('User Role: $userRole');
  //       if (userRole != null) {
  //         if (userRole.contains('admin')) {
  //           authState = UserRoles.admin;
  //         } else if (userRole.contains('editor')) {
  //           authState = UserRoles.editor;
  //         }
  //       }
  //     }
  //   }).catchError((e) {
  //     debugPrint('check access error: $e');
  //   });
  //   return authState;
  // }


  Future<bool?> changeAdminPassword (String oldPassword, String newPassword) async{
    bool? success;
    final user = _firebaseAuth.currentUser;
    final cred = EmailAuthProvider.credential(email: user!.email!, password: oldPassword);
    await user.reauthenticateWithCredential(cred).then((UserCredential? userCredential) async{
      if(userCredential != null){
        await user.updatePassword(newPassword).then((_) {
        success = true;
        }).catchError((error) {
        debugPrint(error);
        success = false;
        });
      }else{
        success = false;
        debugPrint('Reauthentication failed');
      }
      
    }).catchError((err) {
      debugPrint('errro: $err');
      success = false;
    });

    return success;
  }

  static UserRoles getUserRole(UserModel? user) {
    UserRoles userRole = UserRoles.none;
    if (user != null && user.userRole!.isNotEmpty) {
      if (user.userRole!.contains('admin')) {
        userRole = UserRoles.admin;
      } else if (user.userRole!.contains('editor')) {
        userRole = UserRoles.editor;
      }
    }

    return userRole;
  }
  
  

}