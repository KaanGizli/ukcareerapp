import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:uk_untitled_v0/DatabaseHelper.dart';
import 'UniversityService.dart';
import 'package:uk_untitled_v0/UserInfoForm.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Flutter'ın platform ile bağlanmasını sağlar
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // Firebase yapılandırmasını kullan
  );
  runApp(CareerCounselingApp());
}

class CareerCounselingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Counseling App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _signInWithPhone() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          String smsCode = ''; // Kullanıcının girdiği SMS kodu

          // Bir dialog açarak kullanıcıdan SMS kodunu isteyin
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('SMS Kodunu Girin'),
                content: TextField(
                  onChanged: (value) {
                    smsCode = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      PhoneAuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: smsCode,
                      );
                      await _auth.signInWithCredential(credential);
                      Navigator.of(context).pop();
                    },
                    child: Text('Doğrula'),
                  ),
                ],
              );
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Do something on timeout
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone verification failed: ${e.toString()}')),
      );
    }
  }
  Future<void> _signInWithFacebook() async {
    try {
      // Facebook ile giriş işlemi
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Eğer giriş başarılı olursa, Facebook'tan OAuthCredential oluştur
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.token);

        // Firebase Authentication ile giriş yap
        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => UserInfoForm(),
          ));
        }
      } else {
        // Giriş işlemi başarısız olduysa kullanıcıya mesaj göster
        print("Facebook ile giriş başarısız: ${result.message}");
      }
    } catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      print("Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook ile giriş yapılamadı: $e')),
      );
    }
  }
  void _signUpWithEmail() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kayıt başarılıysa ikinci ekrana yönlendirin
      if (userCredential.user != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserInfoForm(),
        ));
      }
    } catch (e) {
      // Hata mesajı göstermek için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: ${e.toString()}')),
      );
    }
  }
  Future<void> _signUpWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // Kullanıcı Google oturum açmayı iptal etti
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Google ile kayıt başarılıysa ikinci ekrana yönlendirin
      if (userCredential.user != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserInfoForm(),
        ));
      }
    } catch (e) {
      // Hata mesajı göstermek için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: 'Telefon Numarası'),
          keyboardType: TextInputType.phone,
        ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUpWithEmail,
              child: Text('Sign Up with Email'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _signUpWithGoogle,
              icon: Icon(Icons.login),
              label: Text('Continue with Google'),
            ),
            ElevatedButton.icon(
              onPressed: _signInWithFacebook,
              icon: Icon(Icons.facebook),
              label: Text('Continue with Facebook'),
            ),
            ElevatedButton.icon(
              onPressed: _signInWithPhone,
              icon: Icon(Icons.phone),
              label: Text('Continue with Phone'),
            ),
          ],
        ),
      ),
    );
  }
}
