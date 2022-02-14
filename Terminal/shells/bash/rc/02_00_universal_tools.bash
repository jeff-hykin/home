# needs: perl, sed, awk

if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MAC=true
    IS_LINUX=false
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    IS_MAC=false
    IS_LINUX=true
fi

# create a verbal alias
alias previous_succeed='[ $? -eq 0 ]'

escape_shell_argument () {
    arg1="$1"
    double_quote='"'
    printf '%s' "'$(sed "s/'/'$double_quote'$double_quote'/g"<<<"$arg1")'"
}
escape_shell_arguments () {
    # create command string
    __temp_var__command_string=""
    for arg in "$@"
    do
        # escape the arguments
        double_quote='"'
        __temp_var__escaped_arg="'$(sed "s/'/'$double_quote'$double_quote'/g"<<<"$arg")'"
        # add a space in front of each argument
        __temp_var__command_string=" $__temp_var__escaped_arg"
    done
    printf '%s' "$__temp_var__command_string"
}

print () {
    printf '%s' "$1"
}

# 
# sudo replacement (avoids 'command not found' issues)
# 
# 
# sudo alternative (avoids 'command not found' issues)
# 
doit () {
    sudo -E env "PATH=$PATH" "$@"
}

# 
# sudo replacement
# 

# FIXME: need argument parsing to match sudo's argument parsing
# # if the var is empty
# if [[ -z "$__XD_SUDO_PATH" ]]
# then
#     # create it
#     __XD_SUDO_PATH="$(which sudo)"
#     # create then use it to make a command that preserves env 
#     doit () {
#         "$__XD_SUDO_PATH" -E env "PATH=$PATH" "$@"
#     }
# fi


# 
# mkdir
#
if [[ -z "$__XD_builtin_mkdir" ]]
then
    __XD_builtin_mkdir="$(which mkdir)"
fi 
mkdir () {
    # always use the -p option
    "$__XD_builtin_mkdir" -p "$@"
}

# 
# touch
# 
if [[ -z "$__XD_builtin_touch" ]]
then
    __XD_builtin_touch="$(which touch)"
fi
touch () {
    # make any parent folders
    mkdir -p "$(dirname "$1")" 
    "$__XD_builtin_touch" "$1"
}

# 
# rm
# 
if [[ -z "$__XD_builtin_rm" ]]
then
    __XD_builtin_rm="$(which rm)"
fi
rm () {
    # if folder then delete recursively
    if [[ -d "$1" ]]
    then
        "$__XD_builtin_rm" -rf "$1"
    else
        "$__XD_builtin_rm" "$@"
    fi
}

is_command () {
    command -v "$@" >/dev/null 2>&1
}

edit () {
    is_command "$EDITOR" && $EDITOR "$@" || is_command 'nano' && nano "$@" || vim "$@"
}

resume () {
    if [[ -z "$1" ]]
    then
        which_process="%1"
    else
        which_process="$1"
    fi
    kill -s CONT "$which_process"
    fg "$which_process"
}

relative_path () {
    # both $1 and $2 are absolute paths beginning with /
    # $1 must be a canonical path; that is none of its directory
    # components may be ".", ".." or a symbolic link
    #
    # returns relative path to $2/$target from $1/$source
    source="$1"
    target="$2"

    common_part=$source
    result=

    while [ "${target#"$common_part"}" = "$target" ]; do
        # no match, means that candidate common part is not correct
        # go up one level (reduce common part)
        common_part=$(dirname "$common_part")
        # and record that we went back, with correct / handling
        if [ -z "$result" ]; then
            result=..
        else
            result=../$result
        fi
    done

    if [ "$common_part" = / ]; then
        # special case for root (no common path)
        result=$result/
    fi

    # since we now have identified the common part,
    # compute the non-common part
    forward_part=${target#"$common_part"}

    # and now stick all parts together
    if [ -n "$result" ] && [ -n "$forward_part" ]; then
        result=$result$forward_part
    elif [ -n "$forward_part" ]; then
        # extra slash removal
        result=${forward_part#?}
    fi

    printf '%s\n' "$result"
}

absolute_path () {
    echo "$(builtin cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

del () {
    arg1=$1
    args=$@
    # if exists
    if [[ -e $1 ]]
    then
        # if dir
        if [[ -d $1 ]]
        then
            rm -rf $1
        else
            rm $1
        fi
    fi
}

# 
# handy navigation
# 
cd () {
    new_directory="$*"
    if [ $# -eq 0 ]; then
        new_directory="$HOME"
    fi;
    builtin cd "$new_directory" 
    if [ $? -eq 0 ]
    then
        ll || ls -lAF
    fi
}

f ()  {
    args="$@"
    ls -lA | grep "$args"
}

flocal ()  {
    args="$@"
    find . -iname "$args"
}

__temp_set_exa_colors () {
    #
    # styles
    # 
    local bold=1
    local dim=2
    local underline=4
    # 
    # colors
    # 
    __temp_rgb_color () {
        printf "38;5;$1"
    }
    local red=31
    local green=32
    local yellow=33
    local blue=34
    local purple=35
    local cyan=36
    local white=37
    # 
    # groups (not part of exa, just manually created/used)
    # 
    local code_color="$green"
    local image_color="$cyan"
    local video_color="$yellow"
    local document_color="$purple"
    local config_color="$cyan"
    local read_color="$green"
    local write_color="$yellow"
    local execute_color="$red"
    local user_and_group_color="$cyan"
    local big_files="$green;$bold"
    local medium_files="$blue"
    local small_files="$white;$dim"
    
    # 
    # full names (defined by exa)
    # 
    local directories="di"
    local executable_files="ex"
    local regular_files="fi"
    local named_pipes="pi"
    local sockets="so"
    local block_devices="bd"
    local character_devices="cd"
    local symlinks="ln"
    local symlinks_with_no_target="or"
    local the_user_read_permission_bit="ur"
    local the_user_write_permission_bit="uw"
    local the_user_execute_permission_bit_for_regular_files="ux"
    local the_user_execute_for_other_file_kinds="ue"
    local the_group_read_permission_bit="gr"
    local the_group_write_permission_bit="gw"
    local the_group_execute_permission_bit="gx"
    local the_others_read_permission_bit="tr"
    local the_others_write_permission_bit="tw"
    local the_others_execute_permission_bit="tx"
    local setuid_setgid_and_sticky_permission_bits_for_files="su"
    local setuid_setgid_and_sticky_for_other_file_kinds="sf"
    local the_extended_attribute_indicator="xa"
    local the_numbers_of_a_files_size_sets_nb_nk_nm_ng_and_nh="sn"
    local the_numbers_of_a_files_size_if_it_is_lower_than_1_kb_or_kib="nb"
    local the_numbers_of_a_files_size_if_it_is_between_1_kb_or_ki_b_and_1_mb_or_mi_b="nk"
    local the_numbers_of_a_files_size_if_it_is_between_1_mb_or_mi_b_and_1_gb_or_gi_b="nm"
    local the_numbers_of_a_files_size_if_it_is_between_1_gb_or_gi_b_and_1_tb_or_ti_b="ng"
    local the_numbers_of_a_files_size_if_it_is_1_tb_or_ti_b_or_higher="nt"
    local the_units_of_a_files_size_sets_ub_uk_um_ug_and_uh="sb"
    local the_units_of_a_files_size_if_it_is_lower_than_1_kb_or_kib="ub"
    local the_units_of_a_files_size_if_it_is_between_1_kb_or_ki_b_and_1_mb_or_mi_b="uk"
    local the_units_of_a_files_size_if_it_is_between_1_mb_or_mi_b_and_1_gb_or_gi_b="um"
    local the_units_of_a_files_size_if_it_is_between_1_gb_or_gi_b_and_1_tb_or_ti_b="ug"
    local the_units_of_a_files_size_if_it_is_1_tb_or_ti_b_or_higher="ut"
    local a_devices_major_id="df"
    local a_devices_minor_id="ds"
    local a_user_thats_you="uu"
    local a_user_thats_someone_else="un"
    local a_group_that_you_belong_to="gu"
    local a_group_you_arent_a_member_of="gn"
    local a_number_of_hard_links="lc"
    local a_number_of_hard_links_for_a_regular_file_with_at_least_two="lm"
    local a_new_flag_in_git="ga"
    local a_modified_flag_in_git="gm"
    local a_deleted_flag_in_git="gd"
    local a_renamed_flag_in_git="gv"
    local a_modified_metadata_flag_in_git="gt"
    local punctuation_including_many_background_ui_elements="xx"
    local a_files_date="da"
    local a_files_inode_number="in"
    local a_files_number_of_blocks="bl"
    local the_header_row_of_a_table="hd"
    local the_path_of_a_symlink="lp"
    local an_escaped_character_in_a_filename="cc"
    local the_overlay_style_for_broken_symlink_paths="bO"
    
    # manual/raw
    export EXA_COLORS="reset:
    # 
    # file extensions
    #
        # hidden types
        :.*=$dim:
        # doc types 
        :*.pdf=$document_color:*.md=$document_color:*.html=$document_color:*.tex=$document_color:
        # config types
        :*.cfg=$config_color:*.json=$config_color:*.yaml=$config_color:*.toml=$config_color:*.xml:
        # image types
        :*.png=$image_color:*.gif=$image_color:*.jpg=$image_color:*.jpeg=$image_color:
        # video types
        :*.mov=$video_color:*.mp4=$video_color:*.avi=$video_color:
        # TODO audio types and more video types
        # code types
        :*.js=$code_color:*.py=$code_color:*.rb=$code_color:*.rs=$code_color:*.sh=$code_color:*.bash=$code_color:*.zsh=$code_color:*.c=$code_color:*.cpp=$code_color:*.coffee=$code_color:*.h=$code_color:*.lua=$code_color:*.java=$code_color:*.ts=$code_color:*.ps1=$code_color:*.pl=$code_color:*.jsx=$code_color:*.jl=$code_color:*.hs=$code_color:*.cr=$code_color:*.css=$code_color:*.sass=$code_color:*.less=$code_color:*.ipynb=$code_color:*.nix=$code_color:
        
    # file kind
    :$executable_files=$execute_color:
    :$the_path_of_a_symlink=$purple;$underline:
    
    # read
    :$the_user_read_permission_bit=$read_color;$dim:$the_group_read_permission_bit=$read_color;$dim:$the_others_read_permission_bit=$read_color;$dim:
    # write
    :$the_user_write_permission_bit=$write_color;$dim:$the_group_write_permission_bit=$write_color;$dim:$the_others_write_permission_bit=$write_color;$dim:
    # execute
    :$the_user_execute_permission_bit_for_regular_files=$execute_color;$dim:$the_user_execute_for_other_file_kinds=$execute_color;$dim:$the_group_execute_permission_bit=$execute_color;$dim:$the_others_execute_permission_bit=$execute_color;$dim:
    :$the_extended_attribute_indicator=$dim:
    
    # 
    # file sizes
    # 
        # small
        :$the_numbers_of_a_files_size_sets_nb_nk_nm_ng_and_nh=$small_files:$the_numbers_of_a_files_size_if_it_is_lower_than_1_kb_or_kib=$small_files:$the_numbers_of_a_files_size_if_it_is_between_1_kb_or_ki_b_and_1_mb_or_mi_b=$small_files:
        :$the_units_of_a_files_size_if_it_is_lower_than_1_kb_or_kib=$small_files:$the_units_of_a_files_size_if_it_is_between_1_kb_or_ki_b_and_1_mb_or_mi_b=$small_files:
        # medium
        :$the_numbers_of_a_files_size_if_it_is_between_1_mb_or_mi_b_and_1_gb_or_gi_b=$medium_files:
        :$the_units_of_a_files_size_if_it_is_between_1_mb_or_mi_b_and_1_gb_or_gi_b=$medium_files:
        # big
        :$the_numbers_of_a_files_size_if_it_is_between_1_gb_or_gi_b_and_1_tb_or_ti_b=$big_files:$the_numbers_of_a_files_size_if_it_is_1_tb_or_ti_b_or_higher=$big_files:
        :$the_units_of_a_files_size_if_it_is_between_1_gb_or_gi_b_and_1_tb_or_ti_b=$big_files:$the_units_of_a_files_size_if_it_is_1_tb_or_ti_b_or_higher=$big_files:
    
    # user
    :$a_user_thats_you=$user_group_color;$dim:$a_user_thats_someone_else=$user_group_color;$dim:$a_group_that_you_belong_to=$user_group_color;$dim:$a_group_you_arent_a_member_of=$user_and_group_color;$dim:
    
    # date
    :$a_files_date=$purple;$bold;$dim:
    "
}
__temp_set_exa_colors # done with a to () prevent large namespace pollution

unset ll &> /dev/null
unalias ll &> /dev/null
ll () {
    # if exa is not available, start going with backup plans
    if ! command -v "exa" &> /dev/null
    then
        # if mac
        if [[ "$OSTYPE" == "darwin"* ]] 
        then
            # otherwise make use of BSD version
            if ! command -v "gls" &> /dev/null
            then
                ls -lAFG "$@"
            # if gnu ls is available, use it
            else
                gls -lAF --group-directories-first --color "$@"
            fi
        # if not mac
        else
            ls -lAF --group-directories-first --color "$@"
        fi
    else
        # | tac # <- is for getting folders at the bottom
        exa --color=always -lF --sort extension --group-directories-first --git --all  "$@" | tac
    fi
}

# list out all the directories in $PATH
path ()  {
    echo $PATH | sed 's/:/\
/g'
}

# basically find everything in the current directory, seperate it with \0, and then make the paths relative
ls0 () {
    # escape the current directory for a regex search
    escaped_path="$(pliteral $PWD)"
    # list the dirs seperated by \0             then make each path relative    then remove the first line (its just the current directory)
    find "$PWD" -maxdepth 1 -print0 | perl -p -e 's/\0'$escaped_path'\//\0/g' | psub '^.+?\0' ''
}

# 
# regex
# 
escape_grep_regex () {
    sed 's/[][\.|$(){}?+*^]/\\&/g' <<< "$*"
}

psub ()  {
    perl -0pe 's/'"$1"'/'"$2"'/g'
}

# this allows strings to be interpolated with perl regex find
pliteral ()  {
    ESCAPED_FORWARDSLASHES=$(psub '\/' '\\\/' <<< $@)
    ESCAPED_DOLLARSIGN=$(psub '\$' '\\\$' <<< $ESCAPED_FORWARDSLASHES)
    ESCAPED_ATSYMBOL=$(psub '\@' '\\\@' <<< $ESCAPED_DOLLARSIGN)
    ESCAPED_ENDESCAPE=$(psub '\\E' '\\\\E' <<< $ESCAPED_ATSYMBOL)
    OUTPUT='\Q'$ESCAPED_ENDESCAPE'\E'
    echo $OUTPUT
}

# Split text up by a specific string or character
split_by ()  {
    sed 's/'"$@"'/\'$'\n''/g'
}

process_on_port () {
    lsof -i tcp:$@
}

most_recent_file () {
    ls -1rtp "$@" | egrep '.+[^/]$' | tail -1
}

#
#   Owners and Groups
#
all_users () {
    IS_MAC && dscacheutil -q user
    IS_LINUX && getent passwd
}

owner_of () {
    ls -ld "$@" | awk '{print $3}'
}

group_of () {
    ls -ld "$@" | awk '{print $4}'
}

set_group_of__file_to__group () {
    chgrp $2 $1
}

members_of () {
    awk -F':' '/'"$@"'/{print $4}' /etc/group
}

add__to__group () {
    usermod -a -G $2 $1
}

# 
# shells
# 
update_bash () {
    builtin cd
    source .bash_profile
    source .bashrc
    echo
    echo Bash Updated
}

update_zsh () {
    builtin cd
    source .zshrc
    echo
    echo Zsh Updated
}

desk () {
    cd "$HOME/Desktop"
}
