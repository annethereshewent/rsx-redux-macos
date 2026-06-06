# RSX Redux for MacOS

This is the desktop wrapper for https://github.com/annethereshewent/rsx-redux. To install: 

1. Install swift-bridge-cli with the following command: `cargo install -f swift-bridge-cli`
2. Clone the repository with `git clone --recurse-submodules`.
3. Change the directory to `external/rsx-redux/macos`
4. run the compile.sh script by running `./compile.sh`
5. You may need to add rsx-redux to Xcode as a package dependency if it's not already there. If the project builds in Xcode without issues, then skip step 5. Otherwise, continue to step 5.
6. Open the project in Xcode, then add rsx-redux as a package dependency by going to File -> Add Package Dependencies -> Add local. Go to external/rsx-redux/macos, and select "PSXMacEmulator" and hit ok.
7. Go to Product -> Run. (Or Product -> build if you want to build and compile instead)

You should now be able to run the emulator!

## Features

This emulator has the following features:

* Save states, including quick save states with function keys
* Waveform visualizer
* Controller support
* Keyboard support
* Vibration support with compatible controllers

Coming soon:

* Cloud saves
* Ability to switch controller ports
* Customizable controls
   
## Controls

See https://github.com/annethereshewent/rsx-redux for keyboard mappings. Controls on controllers are effectively the same mappings as on the playstation 1 controller for DualShock 3, 4 and Dualsense controllers. For Xbox controllers, mappings are the equivalent version (ie: "A" maps to "Cross," "B" maps to "Circle," and so on)
