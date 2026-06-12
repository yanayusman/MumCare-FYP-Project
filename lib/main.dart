import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:mumcare_app/models/maternal_health.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/appointment.dart';
import 'screens/explorer.dart';
import 'screens/health.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/profile.dart';
import 'services/auth_service.dart';
import 'screens/register_email.dart';
import 'screens/register_profile_setup.dart';
import 'screens/login_email.dart';
import 'screens/reset_password.dart';
import 'screens/medical_history.dart';
import 'screens/personal_info.dart';
import 'screens/healthcare_provider.dart';
import 'screens/privacy_security.dart';
import 'screens/help_support.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await dotenv.load(fileName: '.env.local');

	final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? dotenv.env['NEXT_PUBLIC_SUPABASE_URL'];
	final supabasePublishableKey = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['NEXT_PUBLIC_SUPABASE_ANON_KEY'];

	if (supabaseUrl == null || supabasePublishableKey == null) {
		throw StateError('Missing Supabase configuration in .env.local.');
	}

	await Supabase.initialize(
		url: supabaseUrl,
		publishableKey: supabasePublishableKey,
	);
	await AuthService.instance.initialize();

	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'MumCare',
			theme: ThemeData(
				primarySwatch: Colors.pink,
			),
			home: const AuthGate(),
			routes: {
				'/login': (context) => const Login(),
				'/register': (context) => const Register(),
				'/home': (context) => const Home(),
				'/appointment': (context) => const Appointment(),
				'/health': (context) => const Health(),
				'/explorer': (context) => const Explorer(),
				'/profile': (context) => const Profile(),
        '/email-register': (context) => const RegisterEmail(),
				'/profile-setup': (context) => const RegisterProfileSetup(),
				'/email-login': (context) => const LoginEmail(),
        '/reset-password': (context) => const ResetPassword(),
				'/medical-history': (context) => const MedicalHistoryScreen(),
				'/personal-info': (context) => const PersonalInfoScreen(),
				'/healthcare-provider': (context) => const HealthcareProvider(),
				'/privacy-security': (context) => const PrivacySecurity(),
				'/help-support': (context) => const HelpSupport(),
			},
		);
	}
}

class AuthGate extends StatelessWidget {
	const AuthGate({super.key});

	@override
	Widget build(BuildContext context) {
		final auth = Supabase.instance.client.auth;

		return StreamBuilder<AuthState>(
			stream: auth.onAuthStateChange,
			builder: (context, snapshot) {
        debugPrint('Auth event: ${snapshot.data?.event}, session: ${snapshot.data?.session != null}');
				final event = snapshot.data?.event;
				final session = snapshot.data?.session ?? auth.currentSession;

				if (event == AuthChangeEvent.passwordRecovery) {
					return const ResetPassword();
				}

				if (session == null) {
					return const Login();
				}

				return const Home();
			},
		);
	}
}

