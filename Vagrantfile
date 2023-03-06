$os_packages_update = <<SCRIPT
echo "Update OS packages"
apt update && apt upgrade -y
SCRIPT

$user_setup = <<SCRIPT
#!/bin/bash

function create_user {
  USER_EXISTS=0
  USERS=`getent passwd | cut -d":" -f1`
  
  for USER in $USERS;
  do
    if [[ $1 == $USER ]]; then
      echo "$1 user exists"
      USER_EXISTS=1
    fi
  done

  if [[ $USER_EXISTS -eq 0 ]]; then
    echo "Creating user: $1"
    adduser --disabled-password --gecos "" $1
  fi
}

function set_authorized_keys_cicd {
  if [[ ! -d /home/$1/.ssh ]]; then
    echo "Creating .ssh folder for $1 ssh access"
    mkdir /home/$1/.ssh
  fi

  if [[ ! -f /vagrant/apps/jenkins/configs/id_rsa.pub ]]; then
    echo "Make sure the vagrant folder is mounted and/or the file test exists!"
    exit 1
  fi
  
  cat /vagrant/apps/jenkins/configs/id_rsa.pub > /home/$1/.ssh/id_rsa.pub

  if [[ ! -f /vagrant/apps/jenkins/configs/id_rsa ]]; then
    echo "Make sure the vagrant folder is mounted and/or the file test exists!"
    exit 1
  fi
  
  cat /vagrant/apps/jenkins/configs/id_rsa > /home/$1/.ssh/id_rsa

  chown -R $1:$1 /home/$1/.ssh
  chmod 755 /home/$1/.ssh/id_rsa.pub
  chmod 600 /home/$1/.ssh/id_rsa

  echo "StrictHostKeyChecking no" >> /home/$1/.ssh/config

}

function set_authorized_keys {
  if [[ ! -d /home/$1/.ssh ]]; then
    echo "Creating .ssh folder for $1 ssh access"
    mkdir /home/$1/.ssh
  fi
  
  if [[ ! -f /vagrant/apps/jenkins/configs/id_rsa.pub ]]; then
    echo "Make sure the vagrant folder is mounted and/or the file test exists!"
    exit 1
  fi
  
  cat /vagrant/apps/jenkins/configs/id_rsa.pub > /home/$1/.ssh/authorized_keys

  chown -R $1:$1 /home/$1/.ssh
  chmod 600 /home/$1/.ssh/authorized_keys
}

function add_to_sudoers {

  if [ ! -f /etc/sudoers.d/$1 ]; then
    echo "Granting sudo access for user: $1"
    echo "$1 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$1
  else
    echo "User has been already added to sudoers"
  fi
}

if [ `hostname` == "cicd" ]; then
  create_user "cicd"
  set_authorized_keys_cicd "cicd"
  add_to_sudoers "cicd"
else
  create_user "environment"
  set_authorized_keys "environment"
  add_to_sudoers "environment"
fi

SCRIPT

$install_docker_engine = <<SCRIPT
#!/bin/bash

echo "-----> Uninstall old versions of Docker"
sudo apt-get remove docker docker-engine docker.io containerd runc

echo "-----> Set up the repository"
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

echo "-----> Add Docker official GPG key:"
sudo mkdir -m 0755 -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "-----> Set up the repository:"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "-----> Install Docker Engine:"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

SCRIPT

$install_jenkins = <<SCRIPT
#!/bin/bash

echo "-----> Install Jenkins docker container"

if [[ $(sudo docker images -q robertmrb/jenkins:v1) ]]; then
  echo "Image already exists. Starting container..."
  sudo docker run -d -p 8080:8080 --name jenkins robertmrb/jenkins:v1
else
  echo "Pulling image..."
  sudo docker pull robertmrb/jenkins:v1
  echo "Starting container..."
  sudo docker run -d -p 8080:8080 --name jenkins robertmrb/jenkins:v1
fi

SCRIPT


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.define "cicd" do |ci|
    ci.vm.hostname = "cicd"
    ci.vm.network "private_network", ip: "192.168.56.10"
    ci.vm.provider "virtualbox" do |vb|
      vb.cpus = "2"
      vb.memory = "2048"
    end
    ci.vm.provision "shell", :inline => $os_packages_update
    ci.vm.provision "shell", :inline => $user_setup
    ci.vm.provision "shell", :inline => $install_docker_engine
    ci.vm.provision "shell", :inline => $install_jenkins
  end
  config.vm.define "environment" do |en|
    en.vm.hostname = "environment"
    en.vm.network "private_network", ip: "192.168.56.11"
    en.vm.provision "shell", :inline => $os_packages_update
    en.vm.provision "shell", :inline => $user_setup
    en.vm.provision "shell", :inline => $install_docker_engine
    en.vm.provider "virtualbox" do |vb|
      vb.cpus = "2"
      vb.memory = "4096"
    end
  end
end