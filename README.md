# RSX Redux for MacOS

This is the desktop wrapper for https://github.com/annethereshewent/rsx-redux. To install: 

1. Clone the repository with `git clone --recurse-submodules`.
2. Change the directory to `external/rsx-redux/macos`
3. run the compile.sh script by running `./compile.sh`
4. You may need to add rsx-redux to Xcode as a package dependency if it's not already there. If the project builds in Xcode without issues, then skip step 5. Otherwise, continue to step 5.
5. Open the project in Xcode, then add rsx-redux as a package dependency by going to File -> Add Package Dependencies -> Add local. Go to external/rsx-redux/macos, and select "PSXMacEmulator" and hit ok.
6. Go to Product -> Run. (Or Product -> build if you want to build and compile instead)

You should now be able to run the emulator!
   
   
