python () {
    python3 "$@"
}

pip () {
    python -m pip "$@"
}

__temp_var__startup_file="$HOME/.cache/python_start.py"
mkdir -p "$(dirname "$__temp_var__startup_file")"
echo 'import blissful_basics as bb;import numpy;import numpy as np;import torch;import os;import sys;import random;import time;from statistics import mean as average;A=numpy.array;T=torch.tensor' > "$__temp_var__startup_file"
alias p="PYTHONSTARTUP=""$__temp_var__startup_file"" python "
unset __temp_var__startup_file