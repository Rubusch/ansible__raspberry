[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# Raspberry Pi Provisioning Setup


## References

https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html


## Setup

The installation needs a folder *secret* (not tracked) containing the credential files. *secret* is not checked in, and needs to be provided manually as shown below.  

For my embedded automation controller the following shows a final setup:  

- **dhcp client** on wlan0 (with configured `wpa_supplicant` from *secret*), as uplink
- **dhcp server** (dnsmasq) running on eth0 to manage the DUTs
- rootfs expanded to the entire SD card
- Serial console login enabled
- Early output on serial enabled
- Bluetooth disabled to make console print readable (RPI issue)
- SSH daemon enabled
- Locale `US_en.UTF-8`
- screen using CTRL-b (emacs user)
- vimrc, emacsrc, mc, bashrc, etc. environment settings
- ~/.local is a symlink to /usr/local i.e. actually a one-user-system
- (opt) Xilinx `hw_server` for JTAG over USB to a DUT
- (opt) Camera (legacy) enabled, setup for motion (useful to remote observe LEDs blinking)
- (opt) Pengutronix's labgrid-exporter exporting: console to DUT, ssh to CTRL, gpio26 for powercycle
- (opt) Pengugtronix's usbsdmux in virtualenv
- (opt) Pyrelayctl and script relctl.py for sainsmart 4-way-relay

Ideally an ansible "role" (i.e. a module) will drop its usage as README file in /home/pi.  

login: pi / xdr5XDR%  


## Preparation (first usage)

On host PC  

```
$ pip3 install --user ansible
```

### 1. Download RPI/OS image (64 bit)

Download a recent Raspi OS image for Raspi 4 or 3b [64 bit], plug SD card in reader  
```
$ mkdir ./downloads
$ cd ./downloads
$ wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2025-12-04/2025-12-04-raspios-trixie-arm64-lite.img.xz
$ unxz 2025-12-04-raspios-trixie-arm64-lite.img.xz
```

### 2. SD card: Prepare Secrets

Prepare the folder ``secret`` and provide content as follows. If several are prepared, usually link the correct "secret" folder to this possition.  
```
$ mkdir ./sd/secret
$ tree ./sd/secret/ -a
./secret/
    ├── etc
    │   ├── dnsmasq.conf
    │   ├── hostname
    │   ├── hosts
    │   ├── network
    │   │   └── interfaces
    │   └── wpa_supplicant
    │       └── wpa_supplicant.conf
    └── home
        └── pi
            ├── .gitconfig
            └── .ssh
                └── authorized_keys
```
Make sure that networking will work out for ansible, so typically provide:
- hosts
- ip address
- wifi access via `wpa_supplicant`
- `authorized_keys`
- hosts needs to be there, but hosts and hostname (in case created) will be updated to the arguments of the `setup.sh` script
- any further configurations

### 3. SD card: Flash the minimal Setup

Plug card into the card reader. In case configure ./setup.sh to use the 64-bit or the 32-bit Pi OS image.   
```
$ lsblk
   -> /dev/sdi

$ cd ./sd
$ ./setup.sh /dev/sdi place01 10.1.10.33
    ...
    READY.
$
```
NB: If there is no `READY.` the SD card setup failed.  

### 4. Prepare the Ansible setup

- Configure the expected target IP in `./ansible/hosts`. For example, if the RPI will show up on IP **10.1.10.203 (static)**.
- Configure the ssh key to use in `./ansible.cfg`, under `private_key_file`.
- Configure the `rpi-conf.yml` to select which "roles" (modules) shall be added

In case also configure
- The files in `./ansible/mod-labgrid/files/` according to the setup, i.e. hostname, `labgrid-coordinator` IP, CTRL IP, etc. (symlinked)

double-check, execute the following to find places to adjust to the current setup (ip and hostname), e.g.  
```
$ grep '10\.1\.10' -HIirn ./ansible
$ grep 'unit0' -HIirn ./ansible
```

#### 4.1 QUICKFIX: Manually Configure Network on the RPi

Since 2025 (end of 2024) `ifuptools2` is not installed anymore on Raspbian the default, also the `/etc/network/interfaces` may still block the `NetworkManager`, but cannot drive the interfaces as before (...)  

current QUICKFIX:  
=> Configure the network static ip address manually, e.g. ip 10.1.10.203/24
- Put the SD card into the RPI
- Connect serial and ethernet
- On the serial terminal login, and do the following
- Make sure `/etc/network/interfaces` does not contain entries for 'eth0'
- Make sure `/etc/network/interfaces` does not contain entries for 'wlan0'
```
$ sudo nmcli con del "Wired connection 1"
    Connection 'Wired connection 1' (211dbbb9-9bd1-3f7e-98a1-eefc05fbf30f) successfully deleted.
$ sudo nmcli con add con-name "eth0" ifname eth0 type ethernet ip4 10.1.10.203/24
    Connection 'eth0' (fc2ffed7-a14a-48aa-b77e-4dcb3faa1ffe) successfully added.
$ sudo nmcli con up "eth0"
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/4)
```

Then configure wireless for DHCP connection to local AP
```
$ sudo nmcli radio wifi on
$ sudo nmcli device set wlan0 managed yes
(in case check rfkill state, NB: when restarting networkmanager rfkill might be there again)
$ sudo nmcli con add con-name "wlan0" ifname wlan0 type wifi ssid 'MY_SSID'
$ sudo nmcli con modify wlan0 mode infrastructure
$ sudo nmcli con modify wlan0 wifi-sec.key-mgmt wpa-psk
$ sudo nmcli con modify wlan0 wifi-sec.psk "MY_PSK"
$ sudo nmcli con up wlan0

$ sudo reboot
```
The RPI should come up showing the correct ip address   

TODO: improve this situation by provided configs (sd/secret)

### 5. Raspberry: Automized Setup

Now Plug the card into the RPI. Connect ethernet to the RPI. Power the RPI.  
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

Verify the board is up and connection works out.  
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

Execute ansible provisioning, login a user eligible for sudo rights  
```
$ cd ./ansible
$ ansible-playbook -K ./rpi-conf.yml
    BECOME password:
```
- Enter user password
- Wait ~60 min

In case restart, if the provisioning runs into load issues..  


## Usage

NB: there are still certain fixes to be done, see TODOs  

```
$ ssh pi@10.1.10.203
    login: pi
    password: xdr5XDR%
    (but should use certificate!)
```

#### When working with screen

```
$ screen

<open up some sessions>
```

#### When working with Pengutronix labgrid

```
$ sudo systemctl status labgrid-exporter
```

Modify `/etc/labgrid/exporter.yaml` and `/etc/systemd/system/labgrid-exporter.service`, then
```
$ sudo systemctl start labgrid-exporter
```


#### When working with Pengutronix usbsdmux / labgrid

For the specific setting use `labgrid-suggest`...
```
$ source /opt/labgrid-venv/bin/activate
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

#### When working with pyrelayctl

power the device  
```
(labgrid-venv)$ relctl.py -d0 -t1
```

#### When using GPIO26 and any relay

power the device
```
$ sudo systemctl start gpio26
```

unpower the device
```
$ sudo systemctl stop gpio26
```

In case of labgrid this is to be forwarded, then `lc power on` (if `labgrid-client` aliased to `lc`) powers the device.


#### When working with serial connection

in another screen session e.g. open a terminal  
```
$ tio /dev/ttyUSB1
```

In case of labgrid this is to be forwareded, then `lc con` should provide the shell to the DUT.


#### When working with xvcpi server

in another screen session e.g. run xvcpi server  
```
$ cd ./github__xvcpi
$ sudo xvcpi -v &
```

#### When working with Xilinx `hw_server` (JTAG server)

```
$ sudo systemctl start hw_server
```

NB: the server is highly (more or less) dependent on the installed version of Xilinx Lab Edition, here the setup is provided for 2022.1, 2023.1 and 2024.1. In this case the specific
`Xilinx Vivado Lab Edition` for Linux has to be downloaded and placed into the `downloads` folder. Then `./ansible/mod-xilinxsrv/tasks/*` needs to be adjusted accordingly before
ansible installation.



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


## TODO

- quickfix: dnsmasq keeps IP as listen ip, when adjusting IP needs to be mentioned how & where to change, too
- quickfix: describe how and where to set hostname
- Fix xvcpi JTAG forwareder not working
- Provide README_<ansible mod>.md for each optionally selected ansible module to be placed into /home/pi


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
