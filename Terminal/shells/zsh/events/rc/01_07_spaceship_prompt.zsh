SPACESHIP_VENV_SYMBOL="🐍$(python -V 2>&1 | sed -E 's/Python//g' )"
SPACESHIP_VENV_PREFIX=""
SPACESHIP_VENV_GENERIC_NAMES="."
SPACESHIP_VENV_COLOR="green"
SPACESHIP_NODE_COLOR="yellow"
SPACESHIP_PROMPT_ORDER=(
    time          # Time stampts section
    user          # Username section
    dir           # Current directory section
    host          # Hostname section
    git           # Git section (git_branch + git_status)
    hg            # Mercurial section (hg_branch  + hg_status)
    package       # Package version
    node          # Node.js section
    ruby          # Ruby section
    elm           # Elm section
    elixir        # Elixir section
    xcode         # Xcode section
    swift         # Swift section
    golang        # Go section
    php           # PHP section
    rust          # Rust section
    haskell       # Haskell Stack section
    julia         # Julia section
    docker        # Docker section
    aws           # Amazon Web Services section
    venv          # virtualenv section
    conda         # conda virtualenv section
    pyenv         # Pyenv section
    dotnet        # .NET section
    ember         # Ember.js section
    terraform     # Terraform workspace section
    exec_time     # Execution time
    line_sep      # Line break
    battery       # Battery level and status
    vi_mode       # Vi-mode indicator
    jobs          # Background jobs indicator
    exit_code     # Exit code section
    char          # Prompt character
    # for some reasons these cause errors inside vs code: 
    # ibmcloud      # IBM Cloud section
    # gradle        # Gradle section
    # maven         # Maven section
    # gcloud        # Google Cloud Platform section
    # kubectl       # Kubectl context section
)

__temp_var__plugin_name="spaceship"
__temp_var__z_functions_folder="$SHELL_STANDARD_ENV_SOURCE/shells/zsh/zfunctions"

# add functions folder so that spaceship is accessible
fpath=(
    $fpath
    "$__temp_var__z_functions_folder"
)

# make sure spaceship prompt is in the functions folder
# link it into the functions folder
if ! [ -e "$__temp_var__z_functions_folder/prompt_spaceship_setup" ]
then
    ln -sf ../../../plugins/spaceship-prompt/spaceship.zsh  "$__temp_var__z_functions_folder/prompt_spaceship_setup"
fi

# Set Spaceship ZSH as a prompt
autoload -U promptinit; promptinit
prompt "$__temp_var__plugin_name" &>/dev/null

unset __temp_var__plugin_name
unset __temp_var__z_functions_folder
