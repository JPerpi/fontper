import 'package:flutter/material.dart';
import 'package:fontper/theme/theme_app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primario,
    onPrimary: Colors.white,
    secondary: AppColors.secundario,
    onSecondary: Colors.black,
    background: AppColors.fondo,
    onBackground: AppColors.texto,
    surface: AppColors.fondoTarjeta,
    onSurface: AppColors.texto,
    error: AppColors.error,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.fondo,
  cardColor: AppColors.fondoTarjeta,
  textTheme: GoogleFonts.urbanistTextTheme().apply(
    bodyColor: AppColors.textoOscuro,
    displayColor: AppColors.textoOscuro,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.urbanist(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.primario,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primario,
      foregroundColor: AppColors.textoBotonClaro,
      textStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primario,
      textStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
    ),
  ),
);

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppDarkColors.primario,
    onPrimary: Colors.white,
    secondary: AppDarkColors.secundario,
    onSecondary: Colors.black,
    background: AppDarkColors.fondo,
    onBackground: AppDarkColors.texto,
    surface: AppDarkColors.fondoTarjeta,
    onSurface: AppDarkColors.texto,
    error: AppDarkColors.error,
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: AppDarkColors.fondo,
  cardColor: AppDarkColors.fondoTarjeta,
  textTheme: GoogleFonts.urbanistTextTheme().apply(
    bodyColor: AppDarkColors.textoClaro,
    displayColor: AppDarkColors.textoClaro,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.urbanist(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppDarkColors.primario,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppDarkColors.primario,
      foregroundColor: AppDarkColors.textoBotonClaro,
      textStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppDarkColors.primario,
      textStyle: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
    ),
  ),
);