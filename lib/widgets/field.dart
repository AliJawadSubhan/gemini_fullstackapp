import 'package:flutter/material.dart';

// import '../utils/constants.dart';

Widget customTextField({
  bool isReadOnly = false,
  colorBorder = Colors.grey,
  required controller,
  String? suffixText = '',
  double fontSize = 14,
  double suffixfontSize = 14,
  Color suffixColor = Colors.white,
  FontWeight fontWeight = FontWeight.normal,
  double height = 50,
  String? hintText = "",
  double circularRadius = 10,
  bool isPassword = false,
  TextInputType keyBoard = TextInputType.text,
  Widget? prefixIcon,
  Widget? suffixIcon,
  int maxLines = 1,
  Color? color,
}) {
  return Container(
    height: height,
    decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(circularRadius),
        border: Border.all(
          color: colorBorder,
        )),
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
    ),
    child: TextField(
      // textAlignVertical: TextAlignVertical.center,
      textAlign: TextAlign.left,
      readOnly: isReadOnly,
      obscureText: isPassword,

      controller: controller,
      keyboardType: keyBoard,
      maxLines: maxLines,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),

      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        contentPadding: (prefixIcon != null || suffixIcon != null)
            ? const EdgeInsets.only(top: 15)
            : EdgeInsets.zero,
        suffixStyle: TextStyle(
          fontSize: suffixfontSize,
          fontWeight: fontWeight,
          color: suffixColor,
        ),
        hintStyle: TextStyle(
            fontSize: fontSize,
            color: const Color(
              0xFFABB3BB,
            )),
        hintText: hintText,
        border: InputBorder.none,
      ),
    ),
  );
}
