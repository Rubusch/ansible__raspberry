[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Raspberry Pi Provisioning Setup


## References

https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html


## Final Setup

The installation uses a folder *secret* containing the credential files. *secret* is not checked in, and needs to be provided manually as shown below.  

For my embedded automation controller I use the following setup:  

- **dhcp client** on wlan0 (with configured wpa_supplicant from *secret*), as uplink
- **dhcp server** (dnsmasq) running on eth0 to manage the DUTs
- rootfs expanded to the entire SD card
- Serial console login enabled
- Early output on serial enabled
- Bluetooth disabled to make console print readable (RPI issue)
- SSH daemon enabled
- Locale US_en.UTF-8
- screen using CTRL-b (emacs user)
- vimrc, emacsrc, mc, bashrc, etc. environment settings
- Camera (legacy) enabled, setup for motion (useful to remote observe LEDs blinking)
- ~/.local is a symlink to /usr/local i.e. actually a one-user-system
- Login: u: pi / p: xdr5XDR%  or auto-login

Additional Ansible upgrades ("roles") will be  

- Installation of labgrid inside a python virtualenv, to be enabled
- Installation of pyrelayctl and script relctl.py for sainsmart 4-way-relay


login: pi / xdr5XDR%  


## Preparation

On host PC  

```
$ pip3 install --user ansible
```

## Download RPI/OS image (64 bit)

Raspi OS image for Raspi 3b [64 bit], plug SD card in reader  
```
$ mkdir ./sd/download
$ cd ./sd/download
$ wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64-lite.img.xz
$ unxz 2023-05-03-raspios-bullseye-arm64-lite.img.xz
```

## SD card: Prepare Secrets

Prepare a folder ``secret`` and provide content as follows  
```
$ mkdir ./sd/secret
$ cd ./sd/secret
...
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

Example: interfaces, e.g. could be extended with further network connections to work, and corresponding wpa_supplicant entries.  
```
$ cat ./secret/etc/network/interfaces
    # interfaces(5) file used by ifup(8) and ifdown(8)
    # Include files from /etc/network/interfaces.d:
    source /etc/network/interfaces.d

    auto lo
    iface lo inet loopback

    auto eth0
    allow-hotplug eth0

    ## dnsmasq as dhcp own server on eth
    iface eth0 inet static
    address 10.1.10.203
    netmask 255.0.0.0

    auto wlan0
    allow-hotplug wlan0
    iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
    #wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
    wireless-power off

    ## home wifi
    iface home inet dhcp

    ## demo: dynamic and static setup
    #iface demosetup inet dhcp
    #
    #iface demosetup inet static
    #    address 192.168.1.222
    #    netmask 255.255.255.0
```

## SD card: Flash the minimal Setup

Plug card into card reader. In case configure ./setup.sh to use the 64-bit or the 32-bit Pi OS image.   
```
$ lsblk
   -> /dev/sdi

$ cd ./sd
$ ./setup.sh /dev/sdi
```

## Raspberry: Prepare the Ansible setup

- Configure the expected target IP in ``./ansible/hosts``. For example, if the RPI will show up on IP **10.1.10.203 (static)**.
- Configure the ssh key to use in ``./ansible.cfg``, under ``private_key_file``.


## Raspberry: Automized Setup

Plug the card into the RPI. Connect ethernet connection to the RPI. Verify the board is up and connection works out.  
```
$ cd ./ansible
$ ansible all -m ping
    10.1.10.203 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python"
        },
        "changed": false,
        "ping": "pong"
    }
```

(Optionally) update ssh ``known_hosts``  
```
$ ssh-keygen -f ~/.ssh/known_hosts -R "10.1.10.203"
$ ssh-keyscan 10.1.10.203 >> ~/.ssh/known_hosts
    # 10.1.10.203:22 SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1
    # 10.1.10.203:22 SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1
    # 10.1.10.203:22 SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1
    # 10.1.10.203:22 SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1
    # 10.1.10.203:22 SSH-2.0-OpenSSH_8.4p1 Debian-5+deb11u1

```

Execute ansible provisioning, login a user eligible for sudo rights  
```
$ cd ./ansible
$ ansible-playbook -K ./rpi-conf.yml
    BECOME password:
```

In case this will need several restarts, if the provisioning runs into load issues..  


## Usage

NB: there are still certain fixes to be done, see TODOs  

```
$ ssh pi@10.1.10.203
    login: pi
    password: xdr5XDR%
    (but should use certificate!)

$ screen

<open up some sessions>

$ source ./labgrid-venv/bin/activate
(labview-venv)$ ls /dev/usb-sd-mux/
    id-000000001444

(labview-venv)$ usbsdmux /dev/usb-sd-mux/id-000000001444 get
    dut

(labgrid-venv)$ usbsdmux /dev/usb-sd-mux/id-000000001444 host
(labgrid-venv)$ lsblk
     NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
     sda           8:0    1 29.8G  0 disk
     ├─sda1        8:1    1  256M  0 part
     └─sda2        8:2    1 29.6G  0 part

(labgrid-venv)$ sudo udisksctl mount -b /dev/sda1

<copy over what is needed>

(labgrid-venv)$ sync
(labgrid-venv)$ sudo udisksctl unmount -b /dev/sda1
```

switchover  
```
(labgrid-venv)$ usbsdmux /dev/usb-sd-mux/id-000000001444 dut
```

power the device  
TODO alternative GPIO triggered relay  
```
(labgrid-venv)$ relctl.py -d0 -t1
```

in another screen session e.g. open a terminal  
```
$ tio /dev/ttyUSB1
```

in another screen session e.g. run xvcpi server  
```
$ cd ./github__xvcpi
$ sudo xvcpi -v &
```


## Development

sd card mux  
ref: https://www.linux-automation.com/usbsdmux-M01/  

first usage, setup udevrule for usbsdcard mux  
```
$ git clone https://github.com/pengutronix/usbsdmux.git
$ sudo cp contrib/udev/99-usbsdmux.rules /etc/udev/rules.d/
$ sudo udevadm control --reload-rules
$ reboot
```
now, connect the usbsdmux device  

first usage, build xvcpi software on the RPI (arm toolchain)  
```
$ cd ./github__xvcpi
$ make
```


## TODOs

- Remove apache2 reliably, since we use lighttpd (`systemctl status` is degraded because of apache2)
- Fix ansible provisioning needs restarts (404 errors, and similar)
- Fix xvcpi JTAG forwareder not working


## Issues

*issue*: how to change hostname in sd setup  

fix: edit ``sd/rootfs/etc/hosts`` and ``sd/rootfs/etc/hostname``  

*issue*: ssh certificate falls back to password login  

fix: check ``/home/pi`` and ``/home/pi/.ssh`` folders need permissions *0700* (check systemctl log on the device why authentication failed)  

*issue*: prefer pip installed ansible?  

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

*issue*: when installing linux-image.deb error on the RPI `uses unknown compression for member 'control.tar.zst', giving up`  

*fix*: repack .zst to .xz, example linux-image (analogue for linux-libc and linux-headers)  
```
$ mkdir deb-temp
$ cd deb-temp
$ ar x ../linux-image-6.3.0-rc6-v8+_6.3.0-rc6-gbc5ee0e040c4-2_arm64.deb
$ zstd -d *.zst
$ rm *.zst
$ xz *.tar
$ mkdir ../repacked
$ ar r ../repacked/linux-image-6.3.0-rc6-v8+_6.3.0-rc6-gbc5ee0e040c4-2_arm64.deb  debian-binary control.tar.xz data.tar.xz
$ cd ..
```


*issue*: userspace application is (cross)compiled against wrong GLIBC version  
executing on the target shows the following error  
```
$ ./userland.elf 
    ./userland.elf: /lib/aarch64-linux-gnu/libc.so.6: version `GLIBC_2.34' not found (required by ./userland.elf)
$ /lib/aarch64-linux-gnu/libc.so.6 
    GNU C Library (Debian GLIBC 2.31-13+rpt2+rpi1+deb11u5) stable release version 2.31.
    Copyright (C) 2020 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions.
    There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
    PARTICULAR PURPOSE.
    Compiled by GNU CC version 10.2.1 20210110.
    libc ABIs: UNIQUE ABSOLUTE
    For bug reporting instructions, please see:
    <http://www.debian.org/Bugs/>.
```

fix: probably use build docker for ubuntu 20.04 instead of 22.04  


*issue*: while performing ansible provisioning, provisioning stops, with a huge red output ending with ``Temporary failure resolving 'deb.debian.org'"``  

fix: wait some seconds, restart ansible commissioning (...)   
