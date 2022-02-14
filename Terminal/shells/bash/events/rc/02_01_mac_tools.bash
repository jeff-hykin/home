if [[ "$OSTYPE" == "darwin"* ]]; then
    function openhere  {
        open "$PWD"
    }
    
    # use the spotlight index to find stuff
    function qfind  {
        mdfind -name "$@" | sub '.+\.webhistory$\n' '' | sub '.+/Caches/.+\n' '' | sub '.+/Library/Frameworks/.+\n' '' | sub "$@"
    }
    
    # update the locate database
    function update_locate  {
        sudo /usr/libexec/locate.updatedb
    }
    
    function my_ip  {
        ifconfig | sub '[\w\W]*\nen0[\w\W]*inet ([\d\.]+) [\w\W]*' '\\1'
    }
    
    # list out a files attributes
    function info  {
        mdls "$@" | sub '^(_|)k(MDItem|)(FS|)' ''
    }
fi