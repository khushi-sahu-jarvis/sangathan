import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sangathanmvvm/login/viewModal/LoginViewModal.dart';
import '../../../utils/commonButton.dart';
import '../../../utils/indicator.dart';
import '../../../utils/otpField.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({Key? key, required this.number}) : super(key: key);
  final String number;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController otpFieldController = TextEditingController();
  String otpText = '';

  @override
  void initState() {
    final viewModel = context.read<LoginViewModel>();
    if (viewModel.timer?.isActive ?? false) {
      viewModel.timer?.cancel();
    }
    viewModel.count.add(60);
    viewModel.startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 6,
                ),
                IconButton(
                  onPressed: (() {
                    viewModel.disposeTimer();
                    Navigator.pop(context);
                  }),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 28,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.13,
                ),
                Text(
                  'Verify Otp',
                  style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w500),
                )
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/login_image.png',
                          height: 200,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Enter Otp',
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '6 digit code has been sent\n+91 ${widget.number}',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    ///OTP Text Field
                    CustomOtpTextField(
                      controller: otpFieldController,
                      onChange: ((value) {
                        otpText = value;
                        viewModel.errorText.add('');
                        print('onChange=$otpText');
                      }),
                      onComplete: ((v) async {
                        otpText = v;
                        if (otpText.isNotEmpty && otpText.length >= 6) {
                          if (context.mounted) {
                            await viewModel.submitOTP(
                                otp: otpText, context: context);
                          }
                        } else {}

                        print('onComplete=$otpText');
                      }),
                    ),

                    /// SUBMIT OTP BUTTON

                    StreamBuilder<bool>(
                      stream: viewModel.isLoading.stream,
                      builder: (context, snapshot) {
                        bool isLoading = snapshot.data ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (viewModel.errorText.valueOrNull != null)
                              Text(
                                viewModel.errorText.value!,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.red,
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            CommonButton(
                              onTap: () async {
                                if (otpText.isNotEmpty && otpText.length >= 6) {
                                  viewModel.errorText.add('');
                                  await viewModel.submitOTP(
                                      otp: otpText, context: context);
                                } else {
                                  EasyLoading.showError('Please Enter OTP');
                                }
                              },
                              isUseWidget: true,
                              borderRadius: 10,
                              padding: const EdgeInsets.all(10),
                              widget: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLoading)
                                    const SpinKitFadingCircle(
                                      color: Colors.white,
                                      size: 27,
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    isLoading ? 'Verifying' : 'Verify',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    /// RESEND OTP BUTTON

                    StreamBuilder(
                      stream: viewModel.count.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data! == 0) {
                          return InkWell(
                            onTap: () async {
                              otpFieldController.clear();
                              viewModel.resendOTP();
                              viewModel.resetTimer();
                            },
                            child: const Center(
                              child: Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'Resend OTP in ${snapshot.data} seconds',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
