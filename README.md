# Quick and easy provisioning for my Raspberry Pi

This is a simple ansible setup (not even using roles!) for provisioning. First a Shell script prepares the SD card in the reader. Then plugged into the RPI, the ansible script provisions my setup for development and automation.  

## References

https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html


## Final Setup

The installation uses a folder *secret* containing the credential files. *secret* is not checked in, and needs to be provided manually as shown below.

For my embedded automation controller I use the following setup:

- **dhcp client** on wlan0 (with configured wpa_supplicant from *secret*)
- **dhcp server** (dnsmasq) running on eth0
- rootfs expanded to the entire SD card
- Serial console login enabled
- Early output on serial enabled
- Bluetooth disabled to make console print readable (RPI issue)
- SSH daemon enabled
- Locale US_en.UTF-8
- screen using CTRL-b (emacs user)
- vimrc, emacsrc, mc, bashrc, etc. environment settings
- Camera (legacy) enabled, setup for motion (useful to remote observe LEDs blinking)
- Login: u: pi / p: xdr5XDR%  or auto-login


## 1. Preparation

On host PC  

```
$ pip3 install --user ansible
```

Edit /etc/ansible/hosts  

## SD card: Prepare SD card

Raspi OS image for Raspi 3b [64 bit], plug SD card in reader  
```
$ cd /tmp
$ wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz
$ export RASPIMG=2022-09-22-raspios-bullseye-arm64-lite.img.xz
$ unxz "$RASPIMG"
$ lsblk
   ...
   -> /dev/sdj
   ...
$ sudo dd if="$RASPIMG" of=/dev/sdj bs=4M conv=fdatasync status=progress
$ cd -
```


## SD card: Prepare Secrets and Credentials

Prepare a folder ``secret`` as follows  
```
$ tree ./secret/ -a
./secret/
    ├── etc
    │   ├── network
    │   │   └── interfaces
    │   └── wpa_supplicant
    │       └── wpa_supplicant.conf
    └── home
        └── pi
            ├── .gitconfig
            └── .ssh
                ├── id_ed25519
                └── known_hosts
```

## Setup SD card

Plug card into card reader.  
```
$ lsblk
   -> /dev/sdi

$ ./setup.sh /dev/sdi
```


## Provisioning

Take out SD card, plug it into the RPI and power the board. When it is up and running.  

Optionally verify the board is up.  
```
$ cd ./ansible
$ ansible all -m ping
```

Optionally update ssh known_hosts  
```
$ ssh-keygen -f "/home/user/.ssh/known_hosts" -R "10.1.10.203"
$ ssh-keyscan 10.1.10.203 >> ~/.ssh/known_hosts
```

Execute ansible provisioning  
```
$ ansible-playbook ./setup.yml
```


## Issues

upgrade ansible  

```
$ pip3 install --upgrade --user ansible
$ pip3 show ansible
```


*issue*: ping fails  
```
$ ansible raspi -m ping
10.1.10.200 | UNREACHABLE! => {
    "changed": false,
	    "msg": "Failed to connect to the host via ssh: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\r\n@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @\r\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\r\nIT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!\r\nSomeone could be eavesdropping on you right now (man-in-the-middle attack)!\r\nIt is also possible that a host key has just been changed.\r\nThe fingerprint for the ED25519 key sent by the remote host is\nSHA256:vH4JKH+RXxG85SiYz26U7xX7aCgZ1a/YqF5Ip643vVQ.\r\nPlease contact your system administrator.\r\nAdd correct host key in /home/user/.ssh/known_hosts to get rid of this message.\r\nOffending ECDSA key in /home/user/.ssh/known_hosts:78\r\n  remove with:\r\n  ssh-keygen -f \"/home/user/.ssh/known_hosts\" -R \"10.1.10.200\"\r\nHost key for 10.1.10.203 has changed and you have requested strict checking.\r\nHost key verification failed.",
		    "unreachable": true
			}
```
*fix*: adjust .ssh/known_hosts  
```
ssh-keygen -f "/home/user/.ssh/known_hosts" -R "10.1.10.203"
```


*issue*: login failed, no login possible  

*fix*: provide a /boot/userconf.txt file, e.g. when SD card is mounted  
```
$ echo -n "pi:" > ./boot/userconf.txt
$ echo 'mypassword' | openssl passwd -6 -stdin >> /boot/userconf.txt
```
