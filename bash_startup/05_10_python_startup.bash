# Put ~/.python_startup on PYTHONPATH so its sitecustomize.py is auto-imported by
# every python (used to default DimOS native modules to rebuild). See the file.
# Idempotent: only prepend if not already present (startup may be sourced twice).
case ":${PYTHONPATH}:" in
    *":$HOME/.python_startup:"*) ;;
    *) export PYTHONPATH="$HOME/.python_startup${PYTHONPATH:+:$PYTHONPATH}" ;;
esac
