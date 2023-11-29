//
// SWColors.m
// Still Waitin
//

#import "SWColors.h"

#import "RealmEntry.h"

UIColor *colorWithLightAndDarkVersion(UIColor *lightColor, UIColor *darkColor) {
  if (@available(iOS 13.0, *)) {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
      return colorWithLightAndDarkVersionForTraitCollection(traitCollection, lightColor, darkColor);
    }];
  } else {
    return lightColor;
  }
}

UIColor *colorWithLightAndDarkVersionForTraitCollection(UITraitCollection *traitCollection, UIColor *lightColor, UIColor *darkColor) {
  if (@available(iOS 13.0, *)) {
    switch (traitCollection.userInterfaceStyle) {
      case UIUserInterfaceStyleUnspecified:
      case UIUserInterfaceStyleLight:
        return lightColor;
      case UIUserInterfaceStyleDark:
        return darkColor;
    }
  } else {
    return lightColor;
  }
}

#pragma mark - Backgrounds

UIColor *SWNavbarBackgroundColor(void) {
  return [UIColor colorWithRed:0.05 green:0.07 blue:0.08 alpha:1.0];
}

UIColor *SWColorGrayWash(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0],
                                      [UIColor colorWithRed:0.05 green:0.07 blue:0.08 alpha:1.0]);
}

UIColor *SWColorContentCellBackground(void) {
  return colorWithLightAndDarkVersion([UIColor whiteColor],
                                      [UIColor colorWithRed:0.10 green:0.14 blue:0.16 alpha:1.0]);
}

UIColor *SWColorContentCellSeparator(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.85 green:0.89 blue:0.90 alpha:1.0],
                                      [UIColor colorWithRed:0.33 green:0.36 blue:0.38 alpha:1.0]);
}

UIColor *SWColorSelectedContentCellBackground(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithWhite:0.80 alpha:1.0],
                                      [UIColor colorWithRed:0.15 green:0.21 blue:0.24 alpha:1.0]);
}

UIColor *SWColorGreenMain(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.055 green:0.165 blue:0.20 alpha:1.0],
                                      [UIColor colorWithRed:0.027 green:0.082 blue:0.102 alpha:1.0]);
}

UIColor *SWColorGreenSecondary(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.267 green:0.349 blue:0.380 alpha:1.0],
                                      [UIColor colorWithRed:0.099 green:0.13 blue:0.143 alpha:1.0]);
}

UIColor *SWColorPhotoViewerBackground(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.188 green:0.255 blue:0.282 alpha:1.0],
                                      [UIColor colorWithRed:0.05 green:0.07 blue:0.08 alpha:1.0]);
}
UIColor *SWColorKeyboardBackground(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithWhite:0.72 alpha:1.0],
                                      [UIColor colorWithWhite:0.10 alpha:1.0]);
}

UIColor *SWColorValueLabelBackground(void) {
  return colorWithLightAndDarkVersion([UIColor whiteColor],
                                      [UIColor colorWithRed:0.055 green:0.173 blue:0.212 alpha:1.0]);
}

#pragma mark - Text colors

UIColor *SWColorLowContrastTextColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.45 green:0.49 blue:0.51 alpha:1.0],
                                      [UIColor colorWithRed:0.35 green:0.44 blue:0.49 alpha:1.0]);
}

UIColor *SWColorHighContrastTextColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.055 green:0.165 blue:0.20 alpha:1.0],
                                      [UIColor colorWithRed:0.45 green:0.60 blue:0.64 alpha:1.0]);
}

UIColor *SWColorEmptyListInfoTextColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.055 green:0.165 blue:0.20 alpha:1.0],
                                      [UIColor colorWithRed:0.20 green:0.61 blue:0.70 alpha:1.0]);
}

UIColor *SWColorSettingsTextColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.055 green:0.165 blue:0.20 alpha:1.0],
                                      [UIColor colorWithRed:0.35 green:0.44 blue:0.49 alpha:1.0]);
}

UIColor *SWColorKeyboardTextColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.055 green:0.165 blue:0.20 alpha:1.0],
                                      [UIColor colorWithRed:0.42 green:0.455 blue:0.48 alpha:1.0]);
}

UIColor *SWColorKeyboardDoneButtonColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithRed:0.13 green:0.40 blue:0.46 alpha:1.0],
                                      [UIColor colorWithRed:0.16 green:0.48 blue:0.56 alpha:1.0]);
}

#pragma mark - Tint/signal colors

UIColor *SWColorGreenContrastTintColor(void) {
  return [UIColor colorWithRed:0.20 green:0.61 blue:0.70 alpha:1.0];
}

UIColor *SWColorIndicatorGreen(void) {
  return [UIColor colorWithRed:0.48 green:0.80 blue:0.16 alpha:1.0];
}

UIColor *SWColorIndicatorRed(void) {
  return [UIColor colorWithRed:0.70 green:0.24 blue:0.14 alpha:1.0];
}

UIColor *SWIndicatorColorForDebtDirection(DebtDirection debtDirection) {
  return (debtDirection == DebtDirectionIn ? SWColorIndicatorGreen() : SWColorIndicatorRed());
}
UIColor *SWColorListFilterControlTintColor(void) {
  return colorWithLightAndDarkVersion([UIColor colorWithWhite:0.70 alpha:1.0],
                                      [UIColor colorWithWhite:0.20 alpha:1.0]);
}
