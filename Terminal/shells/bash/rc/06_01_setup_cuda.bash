
# set PATH for cuda 10.1 installation so long as the folder exists
if [ -d "/usr/local/cuda-10.1/bin/" ]; then
    export PATH="$PATH:/usr/local/cuda-10.1/bin/"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-10.1/lib64"
fi