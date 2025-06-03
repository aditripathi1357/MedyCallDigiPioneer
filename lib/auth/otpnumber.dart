import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/services/user_service.dart'; // Import UserService
import 'package:provider/provider.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:medycall/models/user_model.dart';

class OtpNumber extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String userName;
  final bool
  isSignUp; // Add this parameter to differentiate between sign up and sign in

  const OtpNumber({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.userName,
    this.isSignUp = true, // Default to true for backward compatibility
  });

  @override
  State<OtpNumber> createState() => _OtpNumberState();
}

class _OtpNumberState extends State<OtpNumber> with TickerProviderStateMixin {
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService(); // Instance of UserService

  // Timer related variables
  late AnimationController _timerController;
  int _timerSeconds = 60;
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

  Future<void> _resendOTP() async {
    if (!_canResendOTP) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to resend OTP: ${e.message}';
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
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
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
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

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        final firebaseUserId = firebaseUser.uid;

        // Save/update user data to your backend via UserService
        try {
          UserModel? backendUser;

          if (widget.isSignUp) {
            // For sign up: create new user with provided name
            backendUser = await _userService.saveInitialFirebaseUser(
              firebaseUid: firebaseUserId,
              name: widget.userName,
              phone: widget.phoneNumber,
              email: firebaseUser.email,
            );
          } else {
            // For sign in: try to get existing user or handle sign in logic
            // You might want to check if user exists first, then sign them in
            // For now, using the same method but you can modify based on your backend logic
            backendUser = await _userService.signInWithFirebase(
              firebaseUid: firebaseUserId,
              phone: widget.phoneNumber,
            );

            // If user not found in backend but Firebase auth succeeded,
            // it might be a user who signed up through a different method
            if (backendUser == null) {
              setState(() {
                _errorMessage = 'Account not found. Please sign up first.';
                _isLoading = false;
              });
              return;
            }
          }

          if (!mounted) return;

          if (backendUser != null) {
            // Update UserProvider with the comprehensive UserModel from backend
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).setUser(backendUser);

            // Store primary auth identifier
            await _userService.setPrimaryAuthId(
              firebaseUserId,
              'firebase',
              backendUser.email,
              widget.phoneNumber,
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          } else {
            setState(() {
              _errorMessage =
                  widget.isSignUp
                      ? 'Failed to create account. Please try again.'
                      : 'Sign in failed. Please try again.';
            });
          }
        } catch (e) {
          if (!mounted) return;
          setState(() {
            if (e.toString().contains('User not found') && !widget.isSignUp) {
              _errorMessage = 'Account not found. Please sign up first.';
            } else {
              _errorMessage = 'Backend Error: ${e.toString()}';
            }
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Firebase authentication failed.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.code == 'invalid-verification-code') {
          _errorMessage = 'Invalid OTP. Please check and try again.';
        } else if (e.code == 'session-expired') {
          _errorMessage = 'OTP has expired. Please request a new one.';
        } else {
          _errorMessage = e.message ?? 'Invalid OTP. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
      });
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
          // Background decorative elements
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
                height: 570, // Increased height to accommodate 6 digits
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
                                    widget.phoneNumber,
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
                        // OTP input fields - now in a single horizontal line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width:
                                  42, // Adjusted width to fit all 6 boxes in one line
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ), // Added small margin between boxes
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
                        // Timer and Reset OTP row
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
                        // Verify button
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
