# RSX Redux for MacOS

This is the desktop wrapper for https://github.com/annethereshewent/rsx-redux. A release is now available in the [releases](https://github.com/annethereshewent/rsx-redux-macos/releases) section. To compile: 

1. Install swift-bridge-cli with the following command: `cargo install -f swift-bridge-cli`
2. Clone the repository with `git clone --recurse-submodules`.
3. Change the directory to `external/rsx-redux/macos`
4. run the compile.sh script by running `./compile.sh`
5. You may need to add rsx-redux to Xcode as a package dependency if it's not already there. If the project builds in Xcode without issues, then skip to step 7. Otherwise, continue to step 6.
6. Open the project in Xcode, then add rsx-redux as a package dependency by going to File -> Add Package Dependencies -> Add local. Go to external/rsx-redux/macos, and select "PSXMacEmulator" and hit ok.
7. Go to Product -> Run. (Or Product -> build if you want to build and compile instead)

You should now be able to run the emulator!

## Features

This emulator has the following features:

* Save states, including quick save states with function keys
* Waveform visualizer
* Controller support
* Keyboard support with mappable controls
* Vibration support with compatible controllers
* Support for multiple memory cards (up to 5)

Coming soon:

* Cloud saves
   
## Controls

Controls are mappable under settings for the keyboard. For controllers like Dualshock 4 and Dualsense, mappings should be exactly the same as the PSX. for controllers like the Xbox 360, they translate very similar, such as:

- **A button** -> cross button
- **B button** -> circle button
- **Y button** -> triangle button
- **X button** ->  square button

shoulder buttons, triggers, directional pad, start and select should all be practically the same as the PS1.
