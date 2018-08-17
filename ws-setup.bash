#!/bin/bash
DNF=$(which dnf)
APT=$(which apt)

if [[ ! -z $APT ]]; then
	sudo apt update -y
	sudo apt install -y vim git curl wget
	sudo apt install -y neovim python-pip python3-pip tmux
        sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system
        sudo apt install -y libguestfs-tools
elif [[ ! -z $DNF ]]; then
	sudo dnf update -y
	sudo dnf install -y vim git curl wget
	sudo dnf install -y neovim python-pip python3-pip tmux
	sudo dnf group install -y virtualization
else
	echo "unsupported package manager"
	exit 1;
fi

sudo gpasswd -a "${USER}" libvirt
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel nested=1

# Frankly I never remember which is right on which systems, so just set them both
echo "options kvm_intel nested=1" | \
  sudo tee /etc/modprobe.d/kvm.conf
echo "options kvm_intel nested=1" | \
  sudo tee /etc/modprobe.d/qemu-system-x86.conf

curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker jgriffith

wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile

sudo pip3 install neovim
sudo pip install neovim
pip3 install neovim --upgrade

###########
# vim-plug
###########
# curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
#    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim/
curl https://gist.githubusercontent.com/j-griffith/e70e6992ceea96f8fc393779caffd1b6/raw/81cc4dd33bab62dec51a6922efb31c20e3f2c44f/init.vim > ~/.config/nvim/init.vim

nvim +PlugInstall +qall
pip3 install neovim --upgrade

curl https://gist.githubusercontent.com/j-griffith/bfe1adcb0e0e4a78e7d50bc9fd154cf6/raw/dbcd5d1f139867fdd890491d831d1cb2283cf2cc/tmux.conf > ~/.tmux.conf

# finally let's add some things to our profile
cat <<EOT >> ~/.bashrc
# use nvim everywhere
alias vim="nvim"
alias vi="nvim"
alias oldvim="vim"

alias updatefork="git fetch upstream; git checkout master; git rebase upstream/master; git push"

# GoLang
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/local/go/bin
EOT
