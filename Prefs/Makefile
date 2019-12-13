include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LockWidgetsPrefs

$(BUNDLE_NAME)_FILES = LockWidgetsPrefsRootListController.m LockWidgetsPrefsSelectListController.m
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences AppSupport
$(BUNDLE_NAME)_EXTRA_FRAMEWORKS += Cephei CepheiPrefs
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc -Wdeprecated-declarations -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)