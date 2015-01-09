#!/bin/bash
#
# This script creates a base Vagrant box for building Galileo Firmware Images
#

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

case $( uname -s ) in
    Linux)
        VBOX_HOME=$HOME/.config/VirtualBox
        VBOX_BASE=$HOME/VirtualBox\ VMs
        ;;
    Darwin)
        VBOX_HOME=$HOME/Library/VirtualBox
        VBOX_BASE=$HOME/VirtualBox\ VMs
        ;;
    *)
        { echo >&2 "This operating system is not supported, you need Mac OS X or Linux" ; exit 1 ; }
        ;;
esac

function check_binary ()
{
    command -v $1 >/dev/null 2>&1 || { echo >&2 "I require $2 but it's not installed. Aborting."; exit 1; }
}

function check_config_file ()
{
    [ -f $DIR/config.sh ] || { echo >&2 "$DIR/config.sh does not exist.  Copy config.sh.example to config.sh and customize it."; exit 1; }
}

function sanity_check ()
{
    check_binary VBoxManage VirtualBox
    check_binary vagrant Vagrant
    check_binary wget wget
    check_config_file
}

function web_server_check ()
{
    echo "Testing 1,2,3" > $DIR/web_test_in.txt
    cp $DIR/web_test_in.txt $PRESEED_PATH
    wget ${PRESEED_URL}web_test_in.txt 2>/dev/null -O - > $DIR/web_test_out.txt
    diff -q $DIR/web_test_in.txt $DIR/web_test_out.txt 2>&1 >/dev/null || WEB_FAIL=1
    rm -rf $DIR/web_test* $PRESEED_PATH/web_test_out.txt
    if [ $WEB_FAIL ] ; then
        echo $WEB_FAIL
        echo >&2 "Web server not configured properly, please check your config.sh and web server configuration."
        exit 1
    fi
}

function parse_templates ()
{
    sed -e s/@BASE_BOX_HOST@/$BASE_BOX_HOST/g -e s/@BASE_BOX_DOMAIN@/$BASE_BOX_DOMAIN/g -e s#@PRESEED_URL@#$PRESEED_URL#g $DIR/templates/preseed.cfg.templ > $DIR/TFTP/Ubuntu12.04/boot-screens/preseed.cfg
    sed -e s/@BASE_BOX_HOST@/$BASE_BOX_HOST/g -e s/@BASE_BOX_DOMAIN@/$BASE_BOX_DOMAIN/g -e s/@BASE_BOX_USER@/$BASE_BOX_USER/g -e s/@BASE_BOX_PASSWORD@/$BASE_BOX_PASSWORD/g $DIR/templates/preseed.txt.templ > $DIR/preseed/preseed.txt
}

function apply_configuration ()
{
    ln -sf $DIR/preseed/preseed.txt $PRESEED_PATH
    ln -sf $DIR/TFTP $VBOX_HOME/TFTP
}

function create_vm ()
{
    echo "Creating Virtual Box VM"
    VBoxManage createvm --name "$BASE_BOX_NAME" --ostype Ubuntu_64 --basefolder "$VBOX_BASE" --register
    VBoxManage modifyvm "$BASE_BOX_NAME" --memory 2048 --acpi on --ioapic on --cpus 2
    VBoxManage modifyvm "$BASE_BOX_NAME" --boot1 disk --boot2 net --boot3 none --boot4 none
    VBoxManage modifyvm "$BASE_BOX_NAME" --nic1 nat --nictype1 82540EM --nattftpfile1 "Ubuntu12.04/pxelinux.0"
    VBoxManage modifyvm "$BASE_BOX_NAME" --rtcuseutc on --usb on --usbehci on --mouse usbtablet

    echo "Creating and attaching storage"
    VDI_PATH="${VBOX_BASE}/${BASE_BOX_NAME}/${BASE_BOX_NAME}.vdi"
    VBoxManage createhd --filename "$VDI_PATH" --size 65535
    VBoxManage storagectl "$BASE_BOX_NAME" --name "SATA Controller" --add sata
    VBoxManage storageattach "$BASE_BOX_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_PATH"

}

function provision_vm ()
{
    echo Provisioning Virtual Machine
}

sanity_check
source $DIR/config.sh
web_server_check

parse_templates
apply_configuration
create_vm
provision_vm

