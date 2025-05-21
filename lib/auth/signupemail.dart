import 'package:flutter/material.dart';
import 'package:medycall/auth/otpemail.dart';
import 'package:medycall/auth/signin.dart';
import 'package:medycall/models/user_model.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signupemail extends StatefulWidget {
  const Signupemail({super.key});

  @override
  State<Signupemail> createState() => _SignUpemailState();
}

class _SignUpemailState extends State<Signupemail> {
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save user data to provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(UserModel(name: name, email: email));

      // Send OTP to the email through Supabase Auth API
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, // No redirect needed as we're using OTP
      );

      // Navigate to OTP verification screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpEmail(email: email, name: name),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send verification code: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF086861),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background decorative elements (same as before)
            Positioned(
              top: -30,
              left: 10,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/Vector.png'),
                  Padding(
                    padding: const EdgeInsets.only(right: 38),
                    child: Image.asset('assets/beat2.png', width: 100),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 120,
              right: 10,
              child: Transform.rotate(
                angle: -80 * (3.1415926535 / 180),
                child: Image.asset('assets/Vector.png'),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Transform.rotate(
                angle: -120 * (3.1415926535 / 180),
                child: Image.asset('assets/Vector.png'),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -30,
              child: Transform.rotate(
                angle: -160 * (3.1415926535 / 180),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/Vector.png'),
                    Padding(
                      padding: const EdgeInsets.only(right: 38),
                      child: Image.asset('assets/beat2.png', width: 100),
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SizedBox(
                  width: 364,
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF086861),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Name Field
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Image.asset('assets/person.png'),
                              ),
                              hintText: 'Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color(0xFF086861),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color(0xFF086861),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          TextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter your Email ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color(0xFF086861),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Color(0xFF086861),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              errorText: _errorMessage,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 60),

                          // Get Verification Code Button
                          SizedBox(
                            width: double.infinity,
                            height: 43,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendOTP,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF086861),
                                shape: const StadiumBorder(),
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.8),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        'Get Verification Code',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Continue as Guest Button
                          SizedBox(
                            width: double.infinity,
                            height: 43,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF086861),
                                ),
                                shape: const StadiumBorder(),
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.8),
                              ),
                              child: const Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF086861),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 70),

                          // Support text and button
                          const Text(
                            'Trouble signing up? Ask our support team.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF086861),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 43,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF086861),
                                ),
                                shape: const StadiumBorder(),
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.8),
                              ),
                              child: const Text(
                                'Ask Support Team',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF086861),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sign in option
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Color(0xFF086861),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                      color: Color(0xFF086861),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
