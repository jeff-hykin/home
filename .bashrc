# All bash startup logic lives in .bashenv
# See .bashenv for details on how to add shell config.
. "$HOME/.bashenv"

# Android SDK
export JAVA_HOME=~/java/jdk-17.0.13+11
export ANDROID_HOME=~/android-studio
export PATH=$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH
