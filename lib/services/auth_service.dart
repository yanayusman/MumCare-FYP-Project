import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
	AuthService._();

	static final AuthService instance = AuthService._();

	bool _isGoogleInitialized = false;

	String? get _webClientId =>
		dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? dotenv.env['NEXT_PUBLIC_GOOGLE_WEB_CLIENT_ID'];

	Future<void> initialize() async {
		if (_isGoogleInitialized) {
			return;
		}

		final webClientId = _webClientId;
		if (webClientId == null || webClientId.isEmpty) {
			throw StateError(
				'Missing GOOGLE_WEB_CLIENT_ID in .env.local. Add your Google OAuth Web client ID.',
			);
		}

		await GoogleSignIn.instance.initialize(serverClientId: webClientId);
		_isGoogleInitialized = true;
	}

	Future<void> signInWithGoogle() async {
		await initialize();

		final account = await GoogleSignIn.instance.authenticate(scopeHint: const ['email']);
		final authTokens = account.authentication;
		final idToken = authTokens.idToken;

		if (idToken == null || idToken.isEmpty) {
			throw StateError(
				'Google sign-in did not return an ID token. Add GOOGLE_WEB_CLIENT_ID to .env.local and configure Google auth in Supabase.',
			);
		}

		await Supabase.instance.client.auth.signInWithIdToken(
			provider: OAuthProvider.google,
			idToken: idToken,
		);
	}

	Future<void> signInWithEmail(String email, String password) async {
		final response = await Supabase.instance.client.auth.signInWithPassword(
			email: email,
			password: password,
		);

		if (response.user == null) {
			throw StateError('Login failed. Please check your email and password.');
		}
	}

	Future<void> resetPassword(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.mumcare://reset-callback/',
    );
  }

  Stream<AuthState> get onAuthStateChange =>
      Supabase.instance.client.auth.onAuthStateChange;

  Future<void> signUpWithEmail(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
    );

    if (response.user == null) {
        throw StateError('Sign up failed. Please try again.');
    }
  }

  Future<bool> hasCompletedProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final result = await Supabase.instance.client
        .from('user_profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    return result != null;
  }

  // In auth_service.dart
  Future<bool> userExistsInDB() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final response = await Supabase.instance.client
        .from('user_profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle(); // returns null instead of throwing if not found

    return response != null;
  }

	Future<void> signOut() async {
		await Supabase.instance.client.auth.signOut();
		await GoogleSignIn.instance.signOut();
	}
}