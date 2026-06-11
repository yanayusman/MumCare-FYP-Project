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

	Future<void> signOut() async {
		await Supabase.instance.client.auth.signOut();
		await GoogleSignIn.instance.signOut();
	}
}