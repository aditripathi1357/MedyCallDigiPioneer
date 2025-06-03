import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String name; // Name is primarily for new sign-ups
  final bool isSignUp;

  const OtpEmail({
    super.key,
    required this.email,
    required this.name, // Expect name to be passed, especially for signup
    this.isSignUp = true,
  });

  @override
  State<OtpEmail> createState() => _OtpEmailState();
}

class _OtpEmailState extends State<OtpEmail> with TickerProviderStateMixin {
  // Changed to match OtpNumber structure
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  String _errorMessage = '';
  final _supabase = Supabase.instance.client;

  // Timer related variables - changed to match OtpNumber
  late AnimationController _timerController;
  int _timerSeconds = 120; // Keep 120 seconds as in original
  bool _canResendOTP = false;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: Duration(seconds: _timerSeconds),
      vsync: this,
    );
    _startTimer();
  }

  void _startTimer() {
    _timerController.reset();
    _timerController.forward();
    setState(() {
      _canResendOTP = false;
    });

    Future.delayed(Duration(seconds: _timerSeconds), () {
      if (mounted) {
        setState(() {
          _canResendOTP = true;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _storeAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print("OtpEmail: Auth token stored in SharedPreferences.");
  }

  Future<void> _resendOTP() async {
    if (!_canResendOTP) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // For resending OTP, shouldCreateUser should generally be false,
      // as the intent is to get a new token for an existing auth attempt.
      await _supabase.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser:
            widget
                .isSignUp, // if it's a signup flow, allow user creation if somehow the first attempt failed pre-OTP
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Clear existing OTP
        for (var controller in _otpControllers) {
          controller.clear();
        }

        // Restart timer
        _startTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Color(0xFF086861),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to resend OTP: ${e.toString()}';
      });
    }
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      String smsCode = _otpControllers.fold(
        '',
        (previousValue, controller) => previousValue + controller.text,
      );

      if (smsCode.length != 6) {
        setState(() {
          _errorMessage = 'Please enter complete 6-digit OTP';
          _isLoading = false;
        });
        return;
      }

      AuthResponse response;
      if (widget.isSignUp) {
        response = await _supabase.auth.verifyOTP(
          email: widget.email,
          token: smsCode,
          type: OtpType.signup, // Use signup for new user creation flow
        );
      } else {
        response = await _supabase.auth.verifyOTP(
          email: widget.email,
          token: smsCode,
          type: OtpType.email, // Use email for existing user sign-in
        );
      }

      if (!mounted) return; // Check mounted status after async call

      if (response.session != null && response.user != null) {
        await _storeAuthToken(response.session!.accessToken);

        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userService = UserService();

        final supabaseUserId = response.user!.id;
        final userEmail = widget.email; // Email used for OTP
        final userNameFromSignupForm = widget.name; // Name from signup form

        // Set primary auth ID immediately for subsequent service calls
        await userService.setPrimaryAuthId(
          supabaseUserId,
          'supabase',
          userEmail,
          null,
        );
        print(
          "OtpEmail: Primary Auth ID set - UID: $supabaseUserId, Method: supabase, Email: $userEmail",
        );

        UserModel? userToSetInProvider;

        if (widget.isSignUp) {
          print(
            "OtpEmail: SignUp flow. Attempting to save initial user data to backend.",
          );
          try {
            userToSetInProvider = await userService.saveInitialSupabaseUser(
              supabaseUid: supabaseUserId,
              name: userNameFromSignupForm, // Use name from the signup form
              email: userEmail,
            );
            if (userToSetInProvider != null) {
              print(
                "OtpEmail: Initial Supabase user data saved and retrieved: Name: ${userToSetInProvider.name}, Email: ${userToSetInProvider.email}, SupabaseUID: ${userToSetInProvider.supabaseUid}, DB ID: ${userToSetInProvider.id}",
              );
            } else {
              // This case implies saveInitialSupabaseUser returned null without error,
              // which it shouldn't if the API call was successful but returned no user.
              // The service method should throw an exception if user data isn't returned.
              _errorMessage =
                  "Failed to create user profile on the server (no data returned).";
              print(
                "OtpEmail: saveInitialSupabaseUser returned null. This is unexpected on success.",
              );
            }
          } catch (e) {
            print(
              "OtpEmail: Error saving initial Supabase user to backend: $e",
            );
            _errorMessage =
                "Failed to create your profile: ${e.toString().split(':').last.trim()}";
          }
        } else {
          // This is a Sign-In flow
          print("OtpEmail: SignIn flow. Attempting to fetch user profile.");
          try {
            userToSetInProvider =
                await userService
                    .getUserProfile(); // Relies on setPrimaryAuthId
            if (userToSetInProvider != null) {
              print(
                "OtpEmail: User profile fetched successfully for sign-in: ${userToSetInProvider.name}",
              );
            } else {
              print(
                "OtpEmail: User profile not found on backend for existing Supabase user OR error during fetch returned null.",
              );
              // Create a basic local user model if profile not found on backend.
              // The name could be derived from Supabase user metadata if available.
              final fallbackName =
                  response.user!.userMetadata?['full_name'] ??
                  response.user!.userMetadata?['name'] ??
                  userEmail.split('@')[0]; // Fallback name

              userToSetInProvider = UserModel(
                // id: null, // Let backend assign ID if this were a save operation
                supabaseUid: supabaseUserId,
                name: fallbackName,
                email: userEmail,
              );
              _errorMessage =
                  "Profile not found. You may need to complete your profile."; // Inform user
              print(
                "OtpEmail: Set basic user locally for sign-in with no backend profile. Name: ${userToSetInProvider.name}",
              );
              // Potentially, you could attempt to save this basic info if the user doesn't exist in your DB.
              // For now, just sets locally and informs user.
            }
          } catch (e) {
            print("OtpEmail: Error fetching user profile during sign-in: $e");
            _errorMessage =
                "Failed to load your profile: ${e.toString().split(':').last.trim()}";
          }
        }

        if (!mounted) return;

        if (userToSetInProvider != null) {
          userProvider.setUser(userToSetInProvider);
          print(
            "OtpEmail: User set in provider. Name: ${userToSetInProvider.name}, Email: ${userToSetInProvider.email}",
          );

          if (_errorMessage.isEmpty) {
            // Navigate only if no critical errors that prevented profile creation/retrieval
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else {
            // If there was an error message (e.g. profile not found for sign-in, or save failed for sign-up)
            // we might not navigate, or navigate with a flag for the HomeScreen to show a message.
            // For now, if an error message is set, we stay on the OTP screen to show it.
            print(
              "OtpEmail: Error message is set: $_errorMessage. Staying on OTP screen.",
            );
          }
        } else {
          // If userToSetInProvider is null, and no _errorMessage was set from try-catch blocks.
          if (_errorMessage.isEmpty) {
            _errorMessage = "An unknown error occurred during profile setup.";
          }
          print(
            "OtpEmail: User to set in provider is null. Error: $_errorMessage. Staying on OTP screen.",
          );
        }
      } else {
        // response.session or response.user is null
        _errorMessage =
            'Invalid verification code or session. Please try again.';
        if (response.session == null)
          print("OtpEmail: Verification response session is null");
        if (response.user == null)
          print("OtpEmail: Verification response user is null");
      }
    } catch (e) {
      if (!mounted) return;
      print("OtpEmail: Error during OTP verification process: $e");
      if (e is AuthException) {
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
        _errorMessage =
            'An unexpected error occurred: ${e.toString().split(':').last.trim()}';
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF086861),
      body: Stack(
        children: [
          // Background decorative elements - matching OtpNumber exactly
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
            bottom: -20,
            right: -20,
            child: Transform.rotate(
              angle: -320 * (3.1415926535 / 180),
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
          Positioned(
            bottom: 40,
            left: -30,
            child: Transform.rotate(
              angle: 160 * (3.1415926535 / 180),
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
              child: Container(
                width: 400,
                height: 570, // Same height as OtpNumber
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(58),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          widget.isSignUp
                              ? 'Verify your Account'
                              : 'Sign In Verification',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF086861),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // OTP description and icon
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Enter 6-digit OTP\nthat you received on',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.email,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              'assets/otpnumber.png',
                              height: 90,
                              width: 90,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // OTP input fields - matching OtpNumber exactly
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 42, // Same width as OtpNumber
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ), // Same margin as OtpNumber
                              child: TextField(
                                controller: _otpControllers[index],
                                focusNode: _otpFocusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF086861),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.length == 1 && index < 5) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_otpFocusNodes[index + 1]);
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_otpFocusNodes[index - 1]);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        // Error message display
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Timer and Reset OTP row - matching OtpNumber exactly
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _canResendOTP ? _resendOTP : null,
                              child: Text(
                                _canResendOTP ? 'Resend OTP' : 'Reset OTP in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _canResendOTP
                                          ? Color(0xFF086861)
                                          : Colors.grey,
                                ),
                              ),
                            ),
                            if (!_canResendOTP)
                              AnimatedBuilder(
                                animation: _timerController,
                                builder: (context, child) {
                                  int remainingSeconds =
                                      (_timerSeconds *
                                              (1 - _timerController.value))
                                          .round();
                                  return Text(
                                    '${remainingSeconds}s',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF086861),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Verify button - matching OtpNumber exactly
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF086861),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 5,
                            ),
                            onPressed: _isLoading ? null : _verifyOTP,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      widget.isSignUp
                                          ? 'Verify & Create Account'
                                          : 'Verify & Sign In',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
