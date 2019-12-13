ifeq ($(CIBUILD),1)
export TARGET = iphone:clang:12.1:12.1
export ARCHS = arm64 arm64e
SDKVERSION = 12.1
SYSROOT = $(THEOS)/sdks/iPhoneOS12.1.sdk
else
export TARGET = iphone:clang:13.0:11.2
export ARCHS = arm64 arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets

LockWidgets_FILES = Tweak.xm LockWidgetsManager.m
LockWidgets_CFLAGS = -fobjc-arc -Wno-unused-variable -Wdeprecated-declarations -Wno-deprecated-declarations
LockWidgets_FRAMEWORKS += UIKit
LockWidgets_PRIVATE_FRAMEWORKS += AppSupport
LockWidgets_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lockwidgets_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
