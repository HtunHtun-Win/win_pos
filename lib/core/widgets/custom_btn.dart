import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  const CustomBtn({
    super.key,
    required this.fun,
    required this.lable,
    this.textColor,
    this.bgColor,
    this.borderColor,
  });
  final Function fun;
  final String lable;
  final Color? textColor;
  final Color? bgColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: TextButton(
        onPressed: () => fun(),
        child: Text(
          lable,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
