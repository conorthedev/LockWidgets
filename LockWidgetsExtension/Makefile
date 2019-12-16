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

LIBRARY_NAME = LockWidgetsExtension

LockWidgetsExtension_OBJC_FILES = TestExtensionWidgetView.m
LockWidgetsExtension_CFLAGS = -fobjc-arc -I./
LockWidgetsExtension_LIBRARIES += liblockwidgets

ADDITIONAL_CFLAGS = -Ipublic -Ioverlayheaders -I. -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk
