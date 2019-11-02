# Set SIMJECT variable
export SIMJECT=1

# Compile Tweak
make

# Remove old files
sudo rm -rf /opt/simject/LockWidgets.*
sudo rm -rf /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/Library/PreferenceBundles/lockwidgets_prefs.bundle
sudo rm /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/Library/PreferenceLoader/Preferences/lockwidgets_prefs.plist

# Copy compiled files
cp .theos/obj/iphone_simulator/debug/x86_64/LockWidgets.dylib /opt/simject/LockWidgets.dylib
cp LockWidgets.plist /opt/simject/LockWidgets.plist
sudo cp -r .theos/obj/iphone_simulator/debug/lockwidgets_prefs.bundle /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/Library/PreferenceBundles/lockwidgets_prefs.bundle
sudo cp ./lockwidgets_prefs/entry.plist /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/Library/PreferenceLoader/Preferences/lockwidgets_prefs.plist

# Respring Simulator
resim
