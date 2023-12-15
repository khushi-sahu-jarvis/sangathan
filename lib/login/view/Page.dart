import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewModal/LoginViewModal.dart';

class PageOne extends StatefulWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginViewModel>();
    return Scaffold(body: Center(child: Text(viewModel.userModel.value ?? 'Not available')));
  }
}
