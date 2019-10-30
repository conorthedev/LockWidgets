ifeq ($(SIMJECT),1)
export TARGET = simulator:clang:12.1:10.0
export ARCHS = x86_64 i386
else
export TARGET = iphone:clang:12.1.2:10.0
export ARCHS = arm64 arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockWidgets

LockWidgets_FILES = Tweak.xm
LockWidgets_CFLAGS = -fobjc-arc -Wno-unused-variable -Wdeprecated-declarations -Wno-deprecated-declarations
LockWidgets_FRAMEWORKS += UIKit
LockWidgets_PRIVATE_FRAMEWORKS += AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += lockwidgets_prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
