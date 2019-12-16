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

SUBPROJECTS += Tweak Prefs LockWidgetsExtension liblockwidgets

include $(THEOS_MAKE_PATH)/aggregate.mk
