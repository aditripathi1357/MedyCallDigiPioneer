import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:medycall/home/home_screen.dart';
import 'package:medycall/models/user_model.dart';
import 'package:medycall/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpEmail extends StatefulWidget {
  final String email;
  final String name; // Added name parameter

  const OtpEmail({super.key, required this.email, required this.name});

  @override
  State<OtpEmail> createState() => _OtpEmailState();
}

class _OtpEmailState extends State<OtpEmail> {
  bool _isLoading = false;
  String? _errorMessage;
  String _otp = '';
  final _supabase = Supabase.instance.client;

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
      // Verify OTP
      final response = await _supabase.auth.verifyOTP(
        email: widget.email,
        token: _otp,
        type: OtpType.signup,
      );

      if (response.session != null) {
        // Ensure user data is stored in the provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(UserModel(name: widget.name, email: widget.email));

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
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: ${e.toString()}';
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
                            'Enter OTP',
                            style: TextStyle(
                              fontSize: 30,
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
                          OtpTextField(
                            numberOfFields: 6,
                            borderColor: const Color(0xFF086861),
                            focusedBorderColor: const Color(0xFF086861),
                            showFieldAsBox: true,
                            borderWidth: 2.0,
                            fieldWidth: 45,
                            //runs when a code is typed in
                            onCodeChanged: (String code) {
                              setState(() {
                                _errorMessage = null;
                              });
                            },
                            //runs when every textfield is filled
                            onSubmit: (String verificationCode) {
                              setState(() {
                                _otp = verificationCode;
                              });
                              _verifyOTP();
                            },
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          const SizedBox(height: 40),

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verifyOTP,
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
                                        'Verify',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Resend OTP option
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Didn't receive the code? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    _isLoading
                                        ? null
                                        : () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          try {
                                            await _supabase.auth.signInWithOtp(
                                              email: widget.email,
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'OTP resent successfully',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to resend OTP: ${e.toString()}',
                                                  ),
                                                ),
                                              );
                                            }
                                          } finally {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        },
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _isLoading
                                            ? Colors.grey
                                            : const Color(0xFF086861),
                                  ),
                                ),
                              ),
                            ],
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
