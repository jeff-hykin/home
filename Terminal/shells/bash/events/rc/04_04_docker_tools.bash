# 
# docker tools
# 
function docker-rmi {
    docker ps -a | grep $1 | ruby -e '
        img=ARGV[0]
        ARGV.clear
        # find all the images
        for each_line in $<.read.split("\n")
            if each_line =~ /^(\w+)\s+#{img}/
                each_container_id = $1
                puts "killing container: each_container_id"
            else
                next
            end
            # kill/stop/remove
            system("docker", "container", "kill", each_container_id, :err=>"/dev/null")
            system("docker", "container", "stop", each_container_id, :err=>"/dev/null")
            system("docker", "container", "rm", each_container_id, :err=>"/dev/null")
        end
        # remove the image
        system("docker", "image", "rm", img, :err=>"/dev/null")
    '  $1
}