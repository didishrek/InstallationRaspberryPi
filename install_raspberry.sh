#! /bin/bash

COLOR_DEFAULT="\e[39m"
COLOR_CYAN="\e[36m"
COLOR_YELLOW="\e[33m"
COLOR_RED="\e[31m"
PACKETTOINSTALL=(
    "git"
    "make"
    "cmake"
    "gcc"
    "g++"
    "clang"
    "emacs24"
    "valgind"
    "terminator"
    "libudev-dev"
    "libusb-1.0-0-dev"
    "autotools-dev"
    "autoconf"
    "automake"
    "libtool"
    "libudev1"
    "pkg-config"
)

function display_info() {
    echo -e ${COLOR_YELLOW}"${1}"${COLOR_DEFAULT}
}

function display_title() {
    echo -e ${COLOR_CYAN}"${1}"${COLOR_DEFAULT}
}

function display_error() {
    echo -e ${COLOR_RED}"${1}"${COLOR_DEFAULT} 1>&2
}

function test_error(){
    if [ "$?" != 0 ]; then
	display_error "Failed"
	exit 1
    fi
}

function install_packages(){
    display_info "INSTALLATION DES PAQUETS"
    for i in "${PACKETTOINSTALL[@]}"
    do
	display_info "Installation de $i"
	apt-get install $i -y
    done
}

function update_upgrade(){
    display_info "UPDATE"
    apt-get update
    test_error
    display_info "UPGRADE"
    apt-get upgrade -y
    test_error
}

function test_sudo(){
    if [ "$(id -u)" != "0" ]; then
	display_error "Ce script doit etre lance en root"
	exit 1
    fi
}

function install_hidapi(){
    display_info "Installation d'Hidapi"
    if ls /usr/local/lib/libhidapi* >1 /dev/null 2>&1; then
	display_info "Hidapi est deja installe"
    else
	cd /tmp && pwd
	git clone https://github.com/signal11/hidapi.git
	test_error
	cd hidapi && pwd
	./bootstrap
	test_error
	./configure
	test_error
	make
	test_error
	make install
	test_error
    fi
    rm 1
    display_info "Installation d'Hidapi termine"
}

function install_tempered(){
    display_info "Installation de TEMPered"
    if ls /usr/local/lib/libtempered* >1 /dev/null 2>&1; then
	display_info "TEMPered est deja installe"
    else
	cd /tmp && pwd
	git clone https://github.com/edorfaus/TEMPered.git
	test_error
	cd TEMPered && pwd
	cmake .
	test_error
	make install
	test_error
    fi
    rm 1
    display_info "Installation de TEMPered termine"
}

start_time=`date +%s`
display_title "INSTALATION RASPBERRY"
test_sudo
update_upgrade
install_packages
install_hidapi
install_tempered

end_time=`date +%s`
execution_time=`expr $end_time - $start_time` 
display_info "Installation termine en $execution_time secondes"
