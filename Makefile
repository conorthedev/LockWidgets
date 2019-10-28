TARGET = simulator:clang::10.0
ARCHS = x86_64 i386

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets

LockWidgets_FILES = Tweak.x
LockWidgets_CFLAGS = -fobjc-arc -Wno-unused-variable
LockWidgets_FRAMEWORKS += UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
