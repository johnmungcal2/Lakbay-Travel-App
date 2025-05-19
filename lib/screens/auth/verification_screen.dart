import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lesson_7/provider/auth/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationScreen extends HookConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmailSent = useState(false);
    final isLoading = useState(false);
    final lastResendAttempt = useState<DateTime?>(null);
    final verficationTimer = useRef<Timer?>(null);
    const resendCooldown = Duration(seconds: 30);

    Future<void> sendVerificationEmail(
      ValueNotifier<bool> isEmailSent,
      ValueNotifier<DateTime?> lastResendAttempt,
      WidgetRef ref,
    ) async {
      if (lastResendAttempt.value != null &&
          DateTime.now().difference(lastResendAttempt.value!) <
              resendCooldown) {
        final remaining = resendCooldown -
            DateTime.now().difference(lastResendAttempt.value!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait ${remaining.inSeconds} seconds before resending the email.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      try {
        await ref.read(authServiceProvider).sendEmailVerification();
        isEmailSent.value = true;
        lastResendAttempt.value = DateTime.now();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted) {
            isEmailSent.value = false;
          }
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<void> checkVerificationStatus(
      ValueNotifier<bool> isLoading,
      BuildContext context,
      WidgetRef ref,
    ) async {
      isLoading.value = true;
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified && context.mounted) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboardingComplete', false);
          context.go('/onboarding');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error checking verification status: ${e.toString()}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    void startVerificationTimer(
      ValueNotifier<bool> isEmailSent,
      BuildContext context,
      verficationTimerRef,
      WidgetRef ref,
    ) {
      verficationTimer.value = Timer.periodic(const Duration(seconds: 1), (_) {
        checkVerificationStatus(isLoading, context, ref);
      });
    }

    useEffect(() {
      sendVerificationEmail(isEmailSent, lastResendAttempt, ref);
      startVerificationTimer(isEmailSent, context, verficationTimer, ref);
      return () {
        verficationTimer.value?.cancel();
      };
    }, [context, ref]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                const Text(
                  'Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your inbox (${ref.read(authServiceProvider).currentUser?.email ?? ''}) and click the link to verify your account.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF808080),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Image.asset(
              'lib/assets/images/verification.png',
              height: 350,
              fit: BoxFit.contain,
            ),
            Column(
              children: [
                if (isEmailSent.value)
                  const Text(
                    'Verification email sent! Check your Inbox',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4644db),
                          Color(0xFF8e6eeb),
                          Color(0xFFe49efc),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () => sendVerificationEmail(
                        isEmailSent,
                        lastResendAttempt,
                        ref,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        foregroundColor: Colors.white,
                        overlayColor: Colors.white24,
                      ),
                      child: const Text(
                        'Resend Verification Email',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4644db),
                        Color(0xFF8e6eeb),
                        Color(0xFFe49efc),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
