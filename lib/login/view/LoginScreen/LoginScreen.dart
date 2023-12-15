import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sangathanmvvm/utils/commonButton.dart';
import 'package:sangathanmvvm/login/view/VerifyOtp/VerifyOtp.dart';
import '../../../utils/indicator.dart';
import '../../viewModal/LoginViewModal.dart';
import '../../../utils/textForm.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final loginViewModel = context.read<LoginViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/images/login_image.png",
                      height: 200,
                    ),
                  ),
                  const SizedBox(
                    height: 33,
                  ),
                  Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Enter your mobile number, we will send you OTP to verify later',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: formKey,
                    child: TextFormFieldLogin(
                      formKey: formKey,
                      onTapDone: () {
                        focusNode.unfocus();
                      },
                      controller: mobileNumController,
                      focusNode: focusNode,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  StreamBuilder(
                    stream: loginViewModel.isLoading.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data == true) {
                        return const SpinKitFadingCircle(
                          color: Colors.orange,
                          size: 27,
                        );
                      } else {
                        return CommonButton(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await loginViewModel.loginUser(
                                  mobileNumber: mobileNumController.text);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyOtpScreen(
                                    number: mobileNumController.text,
                                  ),
                                ),
                              );
                            }
                          },
                          padding: const EdgeInsets.all(12),
                          title: 'Login',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

