INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang:13.0:12.4

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets

LockWidgets_FILES = Tweak.xm LockWidgetsManager.m
LockWidgets_CFLAGS = -fobjc-arc
LockWidgets_LIBRARIES = lockwidgets

include $(THEOS_MAKE_PATH)/tweak.mk
