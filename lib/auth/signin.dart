import 'package:flutter/material.dart';
import 'package:medycall/auth/signupnumber.dart';
import 'package:medycall/auth/otpemail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool showPhoneLogin = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // In your SignInPage, update the _handleEmailSignIn method:

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Send OTP for sign in (not magic link)
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, // This prevents magic link generation
        shouldCreateUser: false, // Don't create user if doesn't exist
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent to your email'),
            backgroundColor: Color(0xFF086861),
          ),
        );

        // Navigate to OTP verification page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpEmail(
                  email: email,
                  name: '', // Empty name for sign in
                  isSignUp: false, // This is sign in, not sign up
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('User not found')) {
          _errorMessage =
              'No account found with this email. Please sign up first.';
        } else {
          _errorMessage = 'Failed to send verification code: ${e.toString()}';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePhoneSignIn() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your phone number';
      });
      return;
    }

    if (phone.length != 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // For phone sign in, you would implement your phone OTP logic here
      // This is a placeholder - implement according to your phone auth provider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone sign in not implemented yet')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to send OTP: ${e.toString()}';
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
      backgroundColor: const Color(0xFF086861), // Main background color
      body: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 90,
            left: 0,
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
            top: 140,
            right: 10,
            child: Transform.rotate(
              angle: -90 * (3.1415926535 / 180),
              child: Image.asset('assets/Vector.png'),
            ),
          ),
          Positioned(
            right: -30,
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: Image.asset('assets/Vector.png'),
          ),
          Positioned(
            bottom: 30,
            left: -15,
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

          // Main content
          Center(
            child: SizedBox(
              width: 364,
              height: 515, // Fixed height for white card
              child: Card(
                color: Colors.white, // Solid white background
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      const Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF086861),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Toggle between phone and email
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      showPhoneLogin
                                          ? Colors.white
                                          : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPhoneLogin = true;
                                    _errorMessage = null;
                                  });
                                },
                                child: Text(
                                  'Phone',
                                  style: TextStyle(
                                    color:
                                        showPhoneLogin
                                            ? const Color(0xFF086861)
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      !showPhoneLogin
                                          ? Colors.white
                                          : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    showPhoneLogin = false;
                                    _errorMessage = null;
                                  });
                                },
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    color:
                                        !showPhoneLogin
                                            ? const Color(0xFF086861)
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Conditional input field
                      showPhoneLogin
                          ? TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 8,
                                  top: 14,
                                  bottom: 14,
                                ),
                                child: Text(
                                  '+91',
                                  style: TextStyle(
                                    color: Color(0xFF086861),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              hintText: 'Enter 10-digit mobile number',
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
                                horizontal: 8,
                                vertical: 14,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 16),
                            maxLength: 10,
                            buildCounter:
                                (
                                  context, {
                                  required currentLength,
                                  required isFocused,
                                  maxLength,
                                }) => null,
                          )
                          : TextField(
                            controller: _emailController,
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
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 16),
                          ),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF086861),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    if (showPhoneLogin) {
                                      _handlePhoneSignIn();
                                    } else {
                                      _handleEmailSignIn();
                                    }
                                  },
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
                                  : Text(
                                    showPhoneLogin
                                        ? 'Get OTP'
                                        : 'Get verification code',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Divider with "or" text
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFF086861))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or continue with',
                              style: TextStyle(color: Color(0xFF086861)),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFF086861))),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Social login options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton('assets/google.png', () {}),
                          _buildSocialButton('assets/facebook.png', () {}),
                          _buildSocialButton('assets/whatsapp.png', () {}),
                          _buildSocialButton('assets/twitter.png', () {}),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Sign up text
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Signupnumber(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(text: 'Don\'t have an account? '),
                              TextSpan(
                                text: 'Sign up',
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
        ],
      ),
    );
  }

  // Helper method to build social login buttons (PNG version)
  Widget _buildSocialButton(String assetPath, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }
}
