 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  // Common spacing values
  static double get spacing4 => 4.h;
  static double get spacing8 => 8.h;
  static double get spacing12 => 12.h;
  static double get spacing16 => 16.h;
  static double get spacing20 => 20.h;
  static double get spacing24 => 24.h;
  static double get spacing32 => 32.h;
  static double get spacing40 => 40.h;
  static double get spacing48 => 48.h;
  static double get spacing60 => 60.h;
  static double get spacing80 => 80.h;

  // Common width values
  static double get width8 => 8.w;
  static double get width12 => 12.w;
  static double get width16 => 16.w;
  static double get width24 => 24.w;
  static double get width32 => 32.w;
  static double get width40 => 40.w;
  static double get width80 => 80.w;
  static double get width120 => 120.w;

  // Common radius values
  static double get radius4 => 4.r;
  static double get radius8 => 8.r;
  static double get radius12 => 12.r;
  static double get radius16 => 16.r;
  static double get radius20 => 20.r;
  static double get radius40 => 40.r;
  static double get radius60 => 60.r;

  // Common font sizes
  static double get fontSize12 => 12.sp;
  static double get fontSize14 => 14.sp;
  static double get fontSize16 => 16.sp;
  static double get fontSize18 => 18.sp;
  static double get fontSize20 => 20.sp;
  static double get fontSize24 => 24.sp;
  static double get fontSize28 => 28.sp;

  // Common icon sizes
  static double get iconSize16 => 16.sp;
  static double get iconSize18 => 18.sp;
  static double get iconSize20 => 20.sp;
  static double get iconSize24 => 24.sp;
  static double get iconSize40 => 40.sp;
  static double get iconSize50 => 50.sp;
  static double get iconSize60 => 60.sp;
  static double get iconSize120 => 120.sp;

  // Common padding values
  static EdgeInsets get paddingAll24 => EdgeInsets.all(24.w);
  static EdgeInsets get paddingAll16 => EdgeInsets.all(16.w);
  static EdgeInsets get paddingAll12 => EdgeInsets.all(12.w);
  static EdgeInsets get paddingAll8 => EdgeInsets.all(8.w);

  static EdgeInsets get paddingHorizontal16 =>
      EdgeInsets.symmetric(horizontal: 16.w);
  static EdgeInsets get paddingHorizontal24 =>
      EdgeInsets.symmetric(horizontal: 24.w);
  static EdgeInsets get paddingVertical16 =>
      EdgeInsets.symmetric(vertical: 16.h);
  static EdgeInsets get paddingVertical12 =>
      EdgeInsets.symmetric(vertical: 12.h);

  static EdgeInsets paddingSymmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal?.w ?? 0,
      vertical: vertical?.h ?? 0,
    );
  }

  // Common text styles
  static TextStyle get titleLarge => TextStyle(
        fontSize: fontSize28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: fontSize24,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: fontSize20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: fontSize16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: fontSize14,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: fontSize12,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get buttonText => TextStyle(
        fontSize: fontSize16,
        fontWeight: FontWeight.w600,
      );

  // Common border radius
  static BorderRadius get borderRadius8 => BorderRadius.circular(radius8);
  static BorderRadius get borderRadius12 => BorderRadius.circular(radius12);
  static BorderRadius get borderRadius16 => BorderRadius.circular(radius16);
  static BorderRadius get borderRadius20 => BorderRadius.circular(radius20);

  // Common container sizes
  static Size get logoSize => Size(width40, width40);
  static Size get avatarSize => Size(width80, width80);
  static Size get iconButtonSize => Size(width32, width32);

  // Screen breakpoints
  static bool get isTablet => ScreenUtil().screenWidth > 600;
  static bool get isDesktop => ScreenUtil().screenWidth > 1024;
  static bool get isMobile => ScreenUtil().screenWidth <= 600;

  // Responsive multipliers based on screen size
  static double get responsiveMultiplier {
    if (isDesktop) return 1.2;
    if (isTablet) return 1.1;
    return 1.0;
  }
}
