ifeq ($(SIMJECT),1)
export TARGET = simulator:clang:12.1:10.0
export ARCHS = x86_64 i386
else
export TARGET = iphone:clang:12.1.2:10.0
export ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets
BUNDLE_NAME = lockwidgets_prefs

lockwidgets_prefs_FILES = LockWidgetsPrefsRootListController.m
lockwidgets_prefs_INSTALL_PATH = /Library/PreferenceBundles
lockwidgets_prefs_FRAMEWORKS = UIKit
lockwidgets_prefs_PRIVATE_FRAMEWORKS = Preferences
lockwidgets_prefs_CFLAGS = -fobjc-arc
lockwidgets_prefs_EXTRA_FRAMEWORKS += Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/lockwidgets_prefs.plist$(ECHO_END)