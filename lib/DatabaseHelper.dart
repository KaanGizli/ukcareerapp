
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class DatabaseHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(String name, String surname, int age, String gender, String email, String phone, String educationLevel, String university, {String? job, String? company, int? salary, List<String>? areasOfInterest}) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      await _db.collection('users').doc(userId).set({
        'name': name,
        'surname': surname,
        'age': age,
        'gender': gender,
        'email': email,
        'phone': phone,
        'educationLevel': educationLevel,
        'university': university,
        'job': job,
        'company': company,
        'salary': salary,
        'areasOfInterest': areasOfInterest ?? []
      });
    }
  }
}
