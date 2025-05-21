import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medycall/home/home_screen.dart';

class OtpNumber extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpNumber({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpNumber> createState() => _OtpNumberState();
}

class _OtpNumberState extends State<OtpNumber> {
  final List<TextEditingController> _otpControllers = List.generate(
    6, // Changed to 6 digits
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  ); // Changed to 6 digits

  bool _isLoading = false;
  String _errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Verify the OTP code and sign in with phone credential
  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Combine the 6 digit OTP
      String smsCode = _otpControllers.fold(
        '',
        (previousValue, controller) => previousValue + controller.text,
      );

      // Create a PhoneAuthCredential with the verification ID and OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Navigate to home screen on successful authentication
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Invalid OTP. Please try again.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
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
                        const Text(
                          'Verify your Account',
                          style: TextStyle(
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
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Timer and Reset OTP row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Reset OTP in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF086861),
                              ),
                            ),
                            TweenAnimationBuilder<Duration>(
                              duration: const Duration(minutes: 1),
                              tween: Tween(
                                begin: const Duration(minutes: 1),
                                end: Duration.zero,
                              ),
                              onEnd: () {
                                print('Timer ended');
                              },
                              builder: (
                                BuildContext context,
                                Duration value,
                                Widget? child,
                              ) {
                                final seconds = value.inSeconds % 60;
                                return Text(
                                  '00: ${seconds.toString().padLeft(2, '0')} seconds',
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

                        const SizedBox(height: 36),

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
                              elevation: 3,
                            ),
                            onPressed: _isLoading ? null : _verifyOTP,
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Verify Now',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),
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
