ifeq ($(CIBUILD),1)
export TARGET = iphone:clang:12.4:12.4
export ARCHS = arm64 arm64e
SDKVERSION = 12.4
SYSROOT = $(THEOS)/sdks/iOS-SDKs-master/iPhoneOS12.4.sdk
else
export TARGET = iphone:clang:13.0:11.2
export ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LockWidgetsPrefs

$(BUNDLE_NAME)_FILES = LockWidgetsPrefsRootListController.m LockWidgetsPrefsSelectListController.m FallingSnow/UIView+XMASFallingSnow.m FallingSnow/XMASFallingSnowView.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences AppSupport
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS += Cephei CepheiPrefs
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Wdeprecated-declarations -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)