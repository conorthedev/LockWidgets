# LockWidgets

Show your favourite widget on your lock screen

Developed by [ConorTheDev](https://twitter.com/ConorTheDev) and [EvenDev](https://twitter.com/even_dev)!

## Supported Devices

All iOS Devices between iOS 10 and iOS 12 are supported

## For Developers

### Setting up

#### All users:

- Install [theos](https://github.com/theos/theos), make sure you have the patched SDKs. [opa334's SDKs](https://github.com/opa334/sdks) are recommended for simulator users. People who test on physical devices can use [DavidSkrundz's SDKs](https://github.com/DavidSkrundz/sdks).

#### Simulator Users:

- If you use a simulator, you need to do some aditional setup to compile, compile and install [simject](https://github.com/angelXwind/simject) (instructions in README), [make sure you also install substrate](https://github.com/angelXwind/simject#getting-cydia-substrate-to-function-properly-with-simject). If you want the preference bundle to load, compile [preferenceloader-sim](https://github.com/PoomSmart/preferenceloader-sim), make sure you run `make setup PL_SIMULATOR_VERSION=12.1` instead of `9.3`

### Compilng

#### Compiling for iPhone

- Before running `make` run the following command in terminal: `export SIMEJCT=0`

#### Compiling for the simulator

- Before running `make` run the following command in terminal: `export SIMEJCT=1`
- To install the tweak and preference bundle to the simulator run the following command: `./installtosim.sh`
