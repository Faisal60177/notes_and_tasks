import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

const String _kWebClientId = '948897677805-dmkctq6fs8vuonsri6i7pdprcatgbqva.apps.googleusercontent.com';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void>? _googleInitFuture;
  AuthCredential? _pendingGoogleCrendential;
  String? _pendingGoogleEmail;
  String? _pendingGooglePhoto;
  StreamSubscription<User?>? _authSub;

  @override
  AuthState build(){
    _googleInitFuture = _googleSignIn.initialize(serverClientId: _kWebClientId).then((_){
      _googleSignIn.authenticationEvents.listen((_){}).onError((_){});
    });

    _authSub = _auth.userChanges().listen((user) {
      if(user != null) {
        _loadUserData(user);
      }else {
        state = const AuthState(isLoggedIn: false);
      }
    });
    ref.onDispose(()=> _authSub?.cancel());
    return const AuthState();
  }

  void clearError()=> state = state.copyWith(errorMessage: '');

  void cancelGoogleLink() {
    _pendingGoogleCrendential = null;
    _pendingGoogleEmail = null;
    _pendingGooglePhoto = null;
    state = state.copyWith(needsGoogleLinkPassword: false, errorMessage: '');
  }

  Future<void> _loadUserData(User user) async {
    final hasPassword = user.providerData.any((p) => p.providerId == 'password');
    final hasGoogle = user.providerData.any((p) => p.providerId == 'google.com');

    state = state.copyWith(
      isLoggedIn: true,
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      hasPassword: hasPassword,
      hasGoogle: hasGoogle,
    );

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if(doc.exists) {
        final data = doc.data()!;
        final firestoreName = data['name'] as String? ?? '';
        final firestorePhoto = data['photoUrl'] as String? ?? '';
        state = state.copyWith(
          displayName: firestoreName.isNotEmpty ? firestoreName: state.displayName,
          photoUrl: firestorePhoto.isNotEmpty ? firestorePhoto : user.photoURL ?? '',
        );

      }else {
        state = state.copyWith(photoUrl: user.photoURL ?? '');
      }
    } catch (_) {
      state =state.copyWith(photoUrl: user.photoURL ?? '');
    }
  }

  Future<List<String>> _getProvidersFromFirestore(String email) async {
    try {
      final query = await _firestore
          .collection('users').where('email', isEqualTo: email.trim())
          .limit(1).get();
      if(query.docs.isEmpty) return[];
      final raw = query.docs.first.data()['providers'];
      if(raw is List) return List<String>.from(raw);
      if(raw is String) return [raw];
      return [];
    }catch(_){
      return [];
    }
  }

  Future<({
    AuthCredential credential,
  String email,
  String displayName,
  String photoUrl,
})> _getGoogleCredential() async {
    await _googleInitFuture;

    try {
      await _googleSignIn.signOut();
    } catch(_){}
    if(!_googleSignIn.supportsAuthenticate()){
      throw Exception('Google Sign-In is not supported on this platform/device.');
    }
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(scopeHint: ['email', 'profile']);
    final String? idToken = googleUser.authentication.idToken;
    if(idToken == null){
      throw Exception( 'Google sign-in failed: idToken is null. '
          'Ensure serverClientId is set and SHA-1 is registered in Firebase Console.',);
    }
    final clientAuth = await googleUser.authorizationClient
    .authorizationForScopes(['email', 'profile']) ??
    await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: clientAuth?.accessToken,
    );
    return(
    credential :credential,
    email : googleUser.email,
    displayName: googleUser.displayName ?? '',
    photoUrl: googleUser.photoUrl?? '',
    );
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
}) async {
    try {
      state = state.copyWith(isLoggedIn: true,errorMessage: '');
      UserCredential credential;
      try{
        credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      } on FirebaseAuthException catch(e) {
        if(e.code == 'email-already-in-use'){
          final providers = await _getProvidersFromFirestore(email.trim());
          if(providers.contains('password')){
            state = state.copyWith(errorMessage: 'This email is already registered. Please sign in instead.');
            return false;
          }
          return await _linkPasswordToExistingAccount(
            email: email.trim(),
            password : password,
            name: name.trim(),
          );
        }
        rethrow;
      }

      final user = credential.user!;
      await user.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'photoUrl': '',
        'providers': ['password'],
        'createdAt' : FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseAuthException catch(e){
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } catch(_){
      state = state.copyWith(errorMessage: 'Something went wrong. Please try again.');
      return false;
    } finally {
    state = state.copyWith(isLoading: false);
  }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
       await _firestore.collection('users')
      .doc(_auth.currentUser!.uid)
      .update({'lastLogin' : FieldValue.serverTimestamp()});
      return true;
    } on FirebaseAuthException catch (e){
      if (e.code == 'invalid-credential' || e.code == 'wrong-password'){
        final providers = await _getProvidersFromFirestore(email);
        if(providers.contains('google') && !providers.contains('password')){
          state = state.copyWith(
            errorMessage: 'This account uses Google sign-in only. '
                'Tap "Continue with Google", or add a password from Profile → Security.',
          );
        } else {
          state = state.copyWith(errorMessage: 'Incorrect email or password. Please try again.');
        }

      }
      else {
        state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      }
      return false;

    }
    catch (_) {
      state = state.copyWith(errorMessage: 'Something went wrong. Please try again.');
      return false;
    }
    finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final google = await _getGoogleCredential();
      final providers = await _getProvidersFromFirestore(google.email);

      if (providers.isEmpty) {
        return await _completeGoogleSignIn(
          google.credential, google.email, google.displayName, google.photoUrl,
          isNew : true,
        );
      }
      if (providers.contains('google')) {
        return await _completeGoogleSignIn(
          google.credential, google.email, google.displayName, google.photoUrl,
          isNew: false,
        );
      }

      _pendingGoogleCrendential = google.credential;
      _pendingGoogleEmail = google.email;
      _pendingGooglePhoto = google.photoUrl;

      state = state.copyWith(
        needsGoogleLinkPassword: true,
        pendingGoogleEmail: google.email,
        errorMessage: 'An account with this email already exists using a password. '
            'Enter that password to link Google sign-in.',
      );
      return false;
    } on GoogleSignInException catch(e) {
      if(e.code.name == 'canceled') return false;
      state = state.copyWith(errorMessage: _mapGoogleSignInError(e.code.name));
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } catch (e) {
      final msg = e.toString();
      state = state.copyWith(errorMessage: msg.contains('not supported') ? msg: 'Google sign-in failed. Please try again.', );
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> _completeGoogleSignIn(
      AuthCredential credential,
      String googleEmail,
      String googleName,
      String googlePhoto, {
        required bool isNew,
  }) async {
    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user!;

    if(isNew) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? googleName,
        'email': user.email ?? googleEmail,
        'photoUrl': user.photoURL ?? googlePhoto,
        'providers': ['google'],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } else {
      await _firestore
          .collection('users').doc(user.uid)
          .update({'lastLogin' : FieldValue.serverTimestamp()});
    }
    return true;
  }

  Future<bool> completeGoogleLinkWithPassword({
    required String email,
    required String password,
}) async {
    final pending = _pendingGoogleCrendential;
    if(pending == null){
      state = state.copyWith(errorMessage: 'No pending Google sign-in. Please try again.');
      return false;
    }
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final userCred =
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      final user = userCred.user!;
      
      final alreadyLinked = user.providerData.any((p) => p.providerId == 'google.com');
      if(!alreadyLinked){
        await user.linkWithCredential(pending);
      }
      await _firestore.collection('users').doc(user.uid).update({
        'providers' : FieldValue.arrayUnion(['google']),
        'photoUrl': user.photoURL ?? _pendingGooglePhoto ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
      });

      _pendingGoogleCrendential = null;
      _pendingGoogleEmail = null;
      _pendingGooglePhoto = null;
      state= state.copyWith(needsGoogleLinkPassword: false);
      return true;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'provider-already-linked'){
        state = state.copyWith(needsGoogleLinkPassword: false);
        return true;
      }
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> _linkPasswordToExistingAccount({
    required String email,
    required String password,
    required String name,
}) async {
    try{
      final google = await _getGoogleCredential();
      if(google.email.toLowerCase() != email.toLowerCase()){
        state = state.copyWith(errorMessage: 'The Google account selected does not match the email entered.');
        return false;
      }
      final userCred = await _auth.signInWithCredential(google.credential);
      final user = userCred.user!;
      
      final alreadyHasPassword = user.providerData.any((p) => p.providerId == 'password');
      if(!alreadyHasPassword){
        final emailCred = EmailAuthProvider.credential(email: email, password: password);
        await user.linkWithCredential(emailCred);
      }

      await _firestore.collection('users').doc(user.uid).update({
        'providers': FieldValue.arrayUnion(['password']),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled') return false;
      state = state.copyWith(errorMessage: _mapGoogleSignInError(e.code.name));
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') return true;
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Google verification failed. Please try again.');
      return false;
    }
  }

  Future<bool> sendPasswordReset(String emailAddress) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final providers = await _getProvidersFromFirestore(emailAddress);
      if (providers.contains('google') && !providers.contains('password')) {
        state = state.copyWith(
          errorMessage: 'This account uses Google sign-in. Tap "Continue with Google".',);
        return false;
      }
      await _auth.sendPasswordResetEmail(email: emailAddress.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signOut() async {
    try{
      await _googleSignIn.signOut();
    } catch (_){}
    await _auth.signOut();
  }

  Future<bool> updateProfile({required String name}) async {
    try{
      state = state.copyWith(isLoading: true);
      final user = _auth.currentUser;
      if(user == null) return false;
      await Future.wait([
        _firestore.collection('users').doc(user.uid).update({'name': name.trim()}),
        user.updateDisplayName(name.trim()),
      ]);
      state = state.copyWith(displayName: name.trim());
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> addPasswordToAccount({required String password}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(errorMessage: 'No user signed in.');
        return false;
      }
      
      await user.reload();
      final freshUser = _auth.currentUser!;
      final alreadyLinked = freshUser.providerData.any((p) => p.providerId == 'password');
      if(alreadyLinked){
        try{
          await freshUser.updatePassword(password);
        } on FirebaseAuthException catch (e) {
          if(e.code == 'requires-recent-login') {
            if(state.hasGoogle){
              final google = await _getGoogleCredential();
              await freshUser.reauthenticateWithCredential(google.credential);
              await _auth.currentUser!.updatePassword(password);
            } else {
              state = state.copyWith(
                errorMessage: 'For security, please sign out and sign in again '
                    'before changing your password.',
              );
              return false;
            }
          } else {
            rethrow;
          }
        }
      } else {
        final emailCred = EmailAuthProvider.credential(email: freshUser.email!, password: password);
        await freshUser.linkWithCredential(emailCred);
        await _firestore.collection('users').doc(freshUser.uid).update({
          'providers': FieldValue.arrayUnion(['password']),
        });
      }
      state = state.copyWith(hasPassword: true);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled') return false;
      state = state.copyWith(errorMessage: _mapGoogleSignInError(e.code.name));
      return false;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: _mapFirebaseError(e.code));
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to set password. Please try again.');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  String _mapFirebaseError(String code) {
    switch(code){
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'provider-already-linked':
        return 'This sign-in method is already linked.';
      case 'requires-recent-login':
        return 'Please sign in again before making this change.';
      case 'credential-already-in-use':
        return 'This Google account is already linked to another user.';
      default:
        return 'Something went wrong. Please try again.';
    }

  }

String _mapGoogleSignInError(String codeName) {
    switch(codeName){
      case 'canceled':
        return '';
      case 'interrupted':
        return 'Sign-in was interrupted. Please try again.';
      case 'clientConfigurationError':
        return 'Google Sign-In configuration error.';
      default:
        return 'Google sign-in failed. Please try again.';

    }
}

}