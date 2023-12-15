
import 'dart:io';
import 'package:keyboard_actions/keyboard_actions.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sangathanmvvm/login/viewModal/LoginViewModal.dart';

class TextFormFieldLogin extends StatefulWidget {
  TextFormFieldLogin(
      {Key? key,
        required this.controller,
        required this.focusNode,
        this.onTapDone,
        required this.formKey})
      : super(
    key: key,
  );
  final GlobalKey<FormState> formKey;

  final TextEditingController controller;
  final FocusNode focusNode;
  final GestureTapCallback? onTapDone;

  @override
  State<TextFormFieldLogin> createState() => _TextFormFieldLoginState();
}

class _TextFormFieldLoginState extends State<TextFormFieldLogin> {
  int remainingCount = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(updateCount);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void updateCount() {
    setState(() {
      remainingCount = 0 + widget.controller.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(

      autoScroll: false,
      enable: Platform.isIOS ? true : false,
      config: KeyboardActionsConfig(actions: [
        KeyboardActionsItem(
            focusNode: widget.focusNode,
            displayArrows: false,
            displayActionBar: false,
            footerBuilder: ((context) => CustomKeyBoardDoneButton(
              onTapDone: widget.onTapDone,
            )))
      ]),
      child: TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.left,
          controller: widget.controller,
          focusNode: widget.focusNode,
          maxLength: 10,
          validator: ((value) {
            if (value!.isEmpty) {
              return 'Enter 10 digit number';
            } else if (value.length != 10) {
              return 'Enter 10 digit number';
            } else if (RegExp(r'0000000000').hasMatch(value)) {
              return 'Not Valid Number';
            } else if (value[0] == "1" ||value[0] == "0" ||
                value[0] == "2" ||
                value[0] == "3" ||
                value[0] == "4") {
              return 'Not Valid Number';
            }
            return null;
          }),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
              counterText: '$remainingCount/10',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 8, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        '+91',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              contentPadding: const EdgeInsets.all(3),
              prefixIconConstraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.15),
              errorStyle: const TextStyle(color: Colors.red),
              hintText: '000-000-00-00',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (term) async {
            widget.focusNode.unfocus();
            if (widget.formKey.currentState!.validate()) {
              if (context.mounted) {
                // await context.read<LoginViewModel>().loginUser(
                //   mobileNumber: widget.controller.text,
                // );
              }
            }
          }),
    );
  }
}
class CustomKeyBoardDoneButton extends StatelessWidget
    implements PreferredSizeWidget {
  CustomKeyBoardDoneButton({Key? key,  this.onTapDone})
      : super(key: key);
  final GestureTapCallback? onTapDone;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTapDone,
        child: const Text(
          'Done',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
