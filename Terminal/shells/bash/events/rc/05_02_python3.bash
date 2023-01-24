python () {
    "$(which python3)" "$@"
}

pip () {
    python -m pip --disable-pip-version-check "$@"
}