import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mekit_gms/UI/screens/onboarding/otp_screen.dart';
import 'package:mekit_gms/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garage_model.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  GarageModel? _garageModel;
  GarageModel get garageModel => _garageModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  // IF THE USER IS SIGNED IN ALREADY - STAYS SIGNED IN

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // SIGN IN
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  verificationId: verificationId,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationID) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // VERIFIY OTP
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSucsess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        // If user is not null, we carry our logic
        _uid = user.uid;
        onSucsess();
      }

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // DATABASE OPERATION
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("garages").doc(_uid).get();
    if (snapshot.exists) {
      print("Garage Exists");
      return true;
    } else {
      print("New Garage");
      return false;
    }
  }

  // SAVING USER DATA TO FIREBASE

  void saveUserDataToFirebase({
    required BuildContext context,
    required GarageModel garageModel,
    required File garageLogo,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // UPLOADING LOGO TO FIREBASE STORAGE
      await storeFileToStorage("garageLogo/$_uid", garageLogo).then((value) {
        garageModel.garageLogo = value;
        garageModel.createdAt =
            DateTime.now().microsecondsSinceEpoch.toString();
        garageModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        garageModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      });
      _garageModel = garageModel;

      // UPLOAD TO DATABASE

      await _firebaseFirestore
          .collection("garages")
          .doc(_uid)
          .set(garageModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // GETTING DATA FOR REGISTERED GARAGE FROM FIREBASE TO SHARED PREFS
  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("garages")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _garageModel = GarageModel(
        name: snapshot['name'],
        address: snapshot['address'],
        phoneNumber: snapshot['phoneNumber'],
        garageLogo: snapshot['garageLogo'],
        createdAt: snapshot['createdAt'],
        uid: snapshot['uid'],
      );
      _uid = garageModel.uid;
    });
  }

  // STORING DATA LOCALLY WITH SHARED PREFS

  Future saveGarageDatatoSP() async {
    // SP means shared prefs
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("garage_model", jsonEncode(garageModel.toMap()));
  }

  // GETTING DATA FROM SHARED PREFS
  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("garage_model") ?? '';
    _garageModel = GarageModel.fromMap(jsonDecode(data));
    _uid = _garageModel!.uid;
    notifyListeners();
  }

  // SIGN OUT
  Future garageSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }
}
