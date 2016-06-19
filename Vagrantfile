$che_version = "latest"
$ip          = "192.168.28.100"
$port        = 8080

Vagrant.configure(2) do |config|
  config.vm.box = "boxcutter/centos72-docker"
  config.vm.box_download_insecure = true
  config.ssh.insert_key = false
  config.vm.network :private_network, ip: $ip
  config.vm.network "forwarded_port", guest: $port, host: $port
  config.vm.synced_folder ".", "/home/user/che"
  config.vm.define "che" do |che|
  end

  config.vm.provider "virtualbox" do |vb|
	vb.name = "Eclipse Che"
    vb.memory = "4096"
	vb.cpus = 4
  end

  $script = <<-SHELL
    CHE_VERSION=$1
    IP=$2
    PORT=$3
    echo 'y' | sudo yum update docker-engine &>/dev/null &
    PROC_ID=$!
    while kill -0 "$PROC_ID" >/dev/null 2>&1; do
      sleep 10
    done

    usermod -aG docker vagrant &>/dev/null
    sudo chmod 777 /var/run/docker.sock &>/dev/null
    docker pull codenvy/che:${CHE_VERSION} &>/dev/null &
    PROC_ID=$!
 
    while kill -0 "$PROC_ID" >/dev/null 2>&1; do
      sleep 10
    done

    docker run --net=host --name=che --restart=always --detach `
              `-v /var/run/docker.sock:/var/run/docker.sock `
              `-v /home/user/che/lib:/home/user/che/lib-copy `
              `-v /home/user/che/workspaces:/home/user/che/workspaces `
              `-v /home/user/che/storage:/home/user/che/storage `
              `-v /home/user/che/conf:/container `
              `-e CHE_LOCAL_CONF_DIR=/container `
              `codenvy/che:${CHE_VERSION} --remote:${IP} --port:${PORT} run &>/dev/null
  SHELL

  config.vm.provision "shell" do |s| 
    s.inline = $script
    s.args = [$che_version, $ip, $port]
  end

  $script2 = <<-SHELL
    IP=$1
    PORT=$2
    while [ true ]; do
      curl -v http://${IP}:${PORT}/dashboard &>/dev/null
      exitcode=$?
      if [ $exitcode == "0" ]; then
        echo "ECLIPSE CHE: http://${IP}:${PORT}"
        exit 0             
      fi 
      sleep 10
    done
  SHELL

  config.vm.provision "shell", run: "always" do |s|
    s.inline = $script2
    s.args = [$ip, $port]
  end

end