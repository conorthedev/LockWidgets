INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets

LockWidgets_FILES = Tweak.xm LockWidgetsManager.m
LockWidgets_CFLAGS = -fobjc-arc -Wno-unused-variable -Wdeprecated-declarations -Wno-deprecated-declarations
LockWidgets_FRAMEWORKS += UIKit
LockWidgets_PRIVATE_FRAMEWORKS += AppSupport
LockWidgets_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
