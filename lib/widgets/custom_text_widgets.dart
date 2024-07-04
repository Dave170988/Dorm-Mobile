import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text blackHelveticaBold(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? overflow,
    FontStyle? fontStyle,
    TextDecoration? textDecoration}) {
  return helveticaText(label,
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      textAlign: textAlign,
      fontStyle: fontStyle,
      overflow: overflow);
}

Text whiteHelveticaBold(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? overflow,
    FontStyle? fontStyle,
    TextDecoration? textDecoration}) {
  return helveticaText(label,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      textAlign: textAlign,
      fontStyle: fontStyle,
      overflow: overflow);
}

Text blackHelveticaRegular(String label,
    {double? fontSize,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? overflow,
    FontStyle? fontStyle,
    TextDecoration? textDecoration}) {
  return helveticaText(label,
      color: Colors.black,
      fontSize: fontSize,
      textAlign: textAlign,
      fontStyle: fontStyle,
      overflow: overflow);
}

Text helveticaText(String label,
    {double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    FontStyle? fontStyle,
    TextOverflow? overflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: overflow,
    style: GoogleFonts.arimo(
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color),
  );
}
