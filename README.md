# LockWidgets

Show your favourite widget on your lock screen

Developed by [ConorTheDev](https://twitter.com/ConorTheDev) and [EvenDev](https://twitter.com/even_dev)!

## Supported Devices

All iOS Devices between iOS 11 and iOS 13 are supported

## For Developers

### Setting up

#### All users:

- Install [theos](https://github.com/theos/theos), make sure you have the patched SDKs. [opa334's SDKs](https://github.com/opa334/sdks) are recommended for simulator users. People who test on physical devices can use [DavidSkrundz's SDKs](https://github.com/DavidSkrundz/sdks).

### Compilng

#### Compiling for iPhone

- Before running `make` run the following command in terminal: `export SIMEJCT=0`

#### Compiling for the simulator

- Before running `make` run the following command in terminal: `export SIMEJCT=1`
- To install the tweak and preference bundle to the simulator run the following command: `./installtosim.sh`
