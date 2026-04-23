import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'models/models.dart';
import 'services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  // Stream of auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('Firebase Auth Error: ${e.code}');
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        UserRole role = UserRole.student;
        if (email == 'admin@mereb.com') {
          role = UserRole.admin;
        } else if (email == 'teacher@mereb.com') {
          role = UserRole.teacher;
        }

        await _db.createUser(AppUser(
          id: cred.user!.uid,
          email: email,
          role: role,
        ));
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print('Firebase Auth Error: ${e.code}');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // For google_sign_in >= 7.1.0, use GoogleSignIn.instance
      // Note: In some recent versions, signIn() might be replaced by authenticate()
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken, // Fallback if accessToken is missing
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        final existingUser = await _db.getUser(cred.user!.uid);
        if (existingUser == null) {
          await _db.createUser(AppUser(
            id: cred.user!.uid,
            email: cred.user!.email ?? '',
            role: UserRole.student,
            displayName: cred.user!.displayName,
          ));
        }
      }
      return cred;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // ignore: avoid_print
      print('Google Sign-In Sign-Out Error: $e');
    }
    await _auth.signOut();
  }
}
