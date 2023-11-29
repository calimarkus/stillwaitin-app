//
// SWColors.h
// Still Waitin
//

#import <CoreFoundation/CoreFoundation.h>

#import "DebtDirection.h"

CF_EXTERN_C_BEGIN

// helper
UIColor *colorWithLightAndDarkVersion(UIColor *lightColor, UIColor *darkColor);
UIColor *colorWithLightAndDarkVersionForTraitCollection(UITraitCollection *traitCollection, UIColor *lightColor, UIColor *darkColor);

// backgrounds
UIColor *SWNavbarBackgroundColor(void);
UIColor *SWColorGrayWash(void);
UIColor *SWColorContentCellBackground(void);
UIColor *SWColorContentCellSeparator(void);
UIColor *SWColorSelectedContentCellBackground(void);
UIColor *SWColorGreenMain(void);
UIColor *SWColorGreenSecondary(void);
UIColor *SWColorPhotoViewerBackground(void);
UIColor *SWColorKeyboardBackground(void);
UIColor *SWColorValueLabelBackground(void);

// text colors
UIColor *SWColorLowContrastTextColor(void);
UIColor *SWColorHighContrastTextColor(void);
UIColor *SWColorEmptyListInfoTextColor(void);
UIColor *SWColorSettingsTextColor(void);
UIColor *SWColorKeyboardTextColor(void);
UIColor *SWColorKeyboardDoneButtonColor(void);

// tint/signal colors
UIColor *SWColorGreenContrastTintColor(void);
UIColor *SWColorIndicatorGreen(void);
UIColor *SWColorIndicatorRed(void);
UIColor *SWIndicatorColorForDebtDirection(DebtDirection debtDirection);
UIColor *SWColorListFilterControlTintColor(void);

CF_EXTERN_C_END
