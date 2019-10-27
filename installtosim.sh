make
rm -rf /opt/simject/LockWidgets.*
cp .theos/obj/iphone_simulator/debug/x86_64/LockWidgets.dylib /opt/simject/LockWidgets.dylib
cp LockWidgets.plist /opt/simject/LockWidgets.plist
/Users/conor/simject/bin/resim
