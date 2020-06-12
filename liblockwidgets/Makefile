ARCHS = arm64 arm64e
TARGET = iphone:clang:13.0:12.4

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = liblockwidgets

liblockwidgets_FILES = LockWidgetsView.mm LockWidgetsConfig.m MRYIPCCenter.m
liblockwidgets_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/library.mk

after-all::
	mkdir -p $(THEOS)/include/liblockwidgets
	cp *.h $(THEOS)/include/liblockwidgets
	cp ../.theos/obj/debug/liblockwidgets.dylib $(THEOS)/lib/liblockwidgets.dylib