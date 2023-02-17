# check if file exists
if [ -f "/opt/ros/noetic/setup.bash" ]
then
    builtin cd /opt/ros/noetic/
    source /opt/ros/noetic/setup.bash
    builtin cd - &>/dev/null
fi