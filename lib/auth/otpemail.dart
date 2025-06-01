import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/models/user_model.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:medycall/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; // Import for Timer

class OtpEmail extends StatefulWidget {
  final String email;
  final String name;
  final bool
  isSignUp; // New parameter to distinguish between sign up and sign in

  const OtpEmail({
    super.key,
    required this.email,
    required this.name,
    this.isSignUp = true, // Default to sign up for backward compatibility
  });

  @override
  State<OtpEmail> createState() => _OtpEmailState();
}

class _OtpEmailState extends State<OtpEmail> {
  bool _isLoading = false;
  String? _errorMessage;
  String _otp = '';
  final _supabase = Supabase.instance.client;

  // Timer state variables
  Timer? _timer;
  int _secondsRemaining = 60; // Initial time for the timer
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  // Method to start the timer
  void _startTimer() {
    _secondsRemaining = 60; // Reset timer duration
    _canResend = false; // Disable resend button initially
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true; // Enable resend when timer reaches 0
        });
        timer.cancel(); // Stop the timer
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AuthResponse response;
      if (widget.isSignUp) {
        // Sign up verification
        response = await _supabase.auth.verifyOTP(
          email: widget.email,
          token: _otp,
          type: OtpType.signup,
        );
      } else {
        // Sign in verification
        response = await _supabase.auth.verifyOTP(
          email: widget.email,
          token: _otp,
          type: OtpType.email,
        );
      }

      if (response.session != null && response.user != null) {
        // Store the Supabase authentication token
        await _storeAuthToken(response.session!.accessToken);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userService = UserService(); // Instantiate UserService

        // Set auth token in provider (optional, as Supabase client handles it)
        userProvider.setAuthToken(response.session!.accessToken);

        // Attempt to fetch the full user profile from your backend
        UserModel? fullUserProfile;
        try {
          // UserService.getUserProfile() uses Supabase.instance.client.auth.currentUser,
          // which should now be populated after a successful verifyOTP.
          print(
            "OtpEmail: Attempting to fetch user profile for ${response.user!.id}",
          );
          fullUserProfile = await userService.getUserProfile();
          if (fullUserProfile != null) {
            print(
              "OtpEmail: Full user profile fetched successfully: ${fullUserProfile.name}",
            );
          } else {
            print(
              "OtpEmail: User profile not found on backend or error during fetch for existing user.",
            );
          }
        } catch (e) {
          print("OtpEmail: Error fetching full user profile after login: $e");
          // Decide how to handle this error.
          // For now, we'll proceed with basic info if fetch fails.
        }

        if (fullUserProfile != null) {
          // Full profile fetched successfully from your backend
          userProvider.setUser(fullUserProfile);
        } else {
          // Profile not found on backend (e.g., new user who hasn't submitted forms)
          // or an error occurred during fetching.
          // Create a basic UserModel with info from Supabase.
          final userName =
              widget.isSignUp
                  ? widget
                      .name // Use name provided during sign-up
                  : (response
                          .user!
                          .userMetadata?['name'] ?? // Check user_metadata
                      response.user!.email?.split(
                        '@',
                      )[0] ?? // Fallback to part of email
                      'User'); // Default fallback

          final basicUser = UserModel(
            id: response.user!.id, // CRITICAL: Use the Supabase User ID
            name: userName,
            email: widget.email,
            // Initialize other UserModel fields as nullable or with defaults
            // as per your UserModel definition if they are not fetched.
          );
          userProvider.setUser(basicUser);
          print(
            "OtpEmail: Set basic user. Name: ${basicUser.name}, Email: ${basicUser.email}, ID: ${basicUser.id}",
          );

          if (widget.isSignUp ||
              (fullUserProfile == null && !widget.isSignUp)) {
            // This condition means it's a new signup, or it's a sign-in but the profile
            // couldn't be fetched (either doesn't exist yet or error).
            // Your app should guide the user to the profile completion flow if necessary.
            print(
              "OtpEmail: New signup or existing user profile not found/fetch failed. User may need to complete profile.",
            );
          }
        }

        // Navigate to home screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid verification code. Please try again.';
          if (response.session == null)
            print("OtpEmail: Verification response session is null");
          if (response.user == null)
            print("OtpEmail: Verification response user is null");
        });
      }
    } catch (e) {
      setState(() {
        if (e is AuthException) {
          // More specific Supabase error handling
          print(
            "OtpEmail: AuthException: ${e.message}, statusCode: ${e.statusCode}",
          );
          if (e.message.toLowerCase().contains('token has expired') ||
              e.statusCode == 401 ||
              e.statusCode == 403) {
            _errorMessage =
                'Verification code has expired or is invalid. Please request a new one.';
          } else if (e.message.toLowerCase().contains('invalid token') ||
              e.message.toLowerCase().contains('otp mismatch')) {
            _errorMessage = 'Invalid verification code. Please try again.';
          } else {
            _errorMessage = 'Verification failed: ${e.message}';
          }
        } else {
          print("OtpEmail: Non-AuthException: ${e.toString()}");
          _errorMessage = 'An unexpected error occurred: ${e.toString()}';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print("OtpEmail: Auth token stored in SharedPreferences.");
  }

  Future<void> _resendOTP() async {
    if (!_canResend && _secondsRemaining > 0) {
      // Prevent resending if the timer is still running
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _canResend = false; // Disable resend immediately upon trying
    });

    try {
      await _supabase.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser:
            false, // Important: don't create a new user if resending
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A new verification code has been sent to your email.',
            ),
            backgroundColor: Color(0xFF086861),
          ),
        );
        _startTimer(); // Restart the timer on successful resend
      }
    } catch (e) {
      setState(() {
        if (e is AuthException) {
          _errorMessage = 'Failed to resend OTP: ${e.message}';
        } else {
          _errorMessage = 'Failed to resend OTP: ${e.toString()}';
        }
        print("OtpEmail: Error resending OTP: $e");
        // If resend fails, we might want to re-enable resend or handle appropriately
        _canResend = true; // Re-enable resend if it failed
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to format time as MM:SS
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
            // Adjusted Positioned widget for 12px from right as previously requested
            Positioned(
              top: 120,
              right: 12,
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
                          Text(
                            widget.isSignUp
                                ? 'Verify Account'
                                : 'Enter Verification Code',
                            style: const TextStyle(
                              fontSize: 28, // Adjusted for consistency
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF086861),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'We have sent a verification code to\n${widget.email}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // OTP Input Field
                          // Adjusted fieldWidth to fix RenderFlex overflow in the internal Row
                          OtpTextField(
                            numberOfFields: 6,
                            borderColor: const Color(0xFF086861),
                            focusedBorderColor: const Color(0xFF086861),
                            showFieldAsBox: true,
                            borderWidth: 2.0,
                            fieldWidth:
                                35, // Reduced field width to prevent overflow <sup data-citation="1"><a href="https://stackoverflow.com/questions/74564092/how-to-avoid-renderflow-error-when-keyboard-appears-in-flutter" target="_blank" title="How to avoid RenderFlow error when keyboard appears in ...">1</a></sup>
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF086861),
                            ),
                            //runs when a code is typed in
                            onCodeChanged: (String code) {
                              setState(() {
                                _errorMessage =
                                    null; // Clear error when user types
                                _otp = code; // Keep track of OTP as it's typed
                              });
                            },
                            //runs when every textfield is filled
                            onSubmit: (String verificationCode) {
                              setState(() {
                                _otp = verificationCode;
                              });
                              _verifyOTP(); // Call verify OTP when all fields are filled
                            },
                          ),
                          const SizedBox(height: 20), // Space below OTP fields
                          // Timer and Resend Option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Reset OTP in",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              // Show timer if remaining seconds > 0, otherwise show Resend link
                              if (_secondsRemaining > 0)
                                Text(
                                  _formatTime(_secondsRemaining),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF086861),
                                  ),
                                ),
                              if (_secondsRemaining <= 0)
                                GestureDetector(
                                  onTap:
                                      _isLoading || !_canResend
                                          ? null
                                          : _resendOTP,
                                  child: Text(
                                    'Resend',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _isLoading || !_canResend
                                              ? Colors.grey
                                              : const Color(0xFF086861),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 40),

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading || _otp.length != 6
                                      ? null
                                      : _verifyOTP, // Disable if loading or OTP not full
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF086861),
                                shape: const StadiumBorder(),
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.8),
                                disabledBackgroundColor: Colors.grey[400],
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
                                      : Text(
                                        widget.isSignUp
                                            ? 'Verify & Sign Up'
                                            : 'Verify & Sign In',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
