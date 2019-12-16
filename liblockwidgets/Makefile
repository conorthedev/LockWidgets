include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = liblockwidgets

liblockwidgets_FILES = liblockwidgets.m
liblockwidgets_CFLAGS = -fobjc-arc
liblockwidgets_FRAMEWORKS += UIKit

include $(THEOS_MAKE_PATH)/library.mk

stage::
	mkdir -p $(THEOS)/include/liblockwidgets
	cp -r ./public/* $(THEOS)/include/liblockwidgets
	cp $(THEOS_STAGING_DIR)/usr/lib/liblockwidgets.dylib $(THEOS)/lib/liblockwidgets.dylib