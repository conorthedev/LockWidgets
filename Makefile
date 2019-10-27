TARGET = simulator:clang::12.0
ARCHS = i386 arm64 armv7 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets

LockWidgets_FILES = Tweak.x
LockWidgets_CFLAGS = -fobjc-arc
LockWidgets_FRAMEWORKS += UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
