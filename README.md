# Configuration Management for my Raspi / Notes

## References

https://opensource.com/article/20/9/raspberry-pi-ansible


## 1. Preparation

On host PC  

```
$ pip3 install --user ansible
```

edit /etc/ansible/hosts   
```
$ cat /etc/ansible/hosts
[raspi]
10.1.10.222

[all:vars]
ansible_connection=ssh
ansible_user=pi
#ansible_ssh_pass=xdr5XDR%
```

## 2. Prepare SD card

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

individualization and adjust in case   
```
$ udisksctl mount -b /dev/sdj1
    Mounted /dev/sdj1 at /media/user/boot

$ meld ./rootfs/boot/config.txt /media/user/boot/config.txt

$ udisksctl unmount -b /dev/sdj1
```

mount rootfs and adjust configs in case   
```
$ udisksctl mount -b /dev/sdj2
    Mounted /dev/sdj2 at /media/user/rootfs
```

either copy the files over, or individually merge the contend over e.g. with meld  
```
$ sudo meld ./rootfs/etc /media/user/rootfs/etc
$ meld ./rootfs/home/pi /media/user/rootfs/home/pi
```

## 3. Secrets and Credentials

prepare a folder ``secret`` as follows  
```
$ tree ./secret/ -a
./secret/
    ├── etc
    │   ├── network
    │   │   └── interfaces
    │   └── wpa_supplicant
    │       └── wpa_supplicant.conf
    └── home
        └── pi
            ├── .gitconfig
            └── .ssh
                ├── authorized_keys
                ├── config
                ├── enclustra
                │   └── id_ed25519__enclustra__2022
                ├── id_ed25519__github2022
                ├── id_ed25519__github2022.pub
                ├── id_ed25519__rpi4
                ├── id_ed25519__rpi4.pub
                └── known_hosts

$ sudo cp -arf ./secret/etc/* /media/user/rootfs/etc/
$ cp -arf ./secret/home/pi /media/user/rootfs/home/

$ cd /media/user/rootfs/home/pi
$ ln -s /usr/local .local
$ sudo chown 1000:1000 -R ./
$ cd -

$ udisksctl unmount -b /dev/sdj2
```

## Provisioning

Install SD card, and configure networking on the board, expect raspi up and running on eth/10.1.10.222 or wlan/dhcp, in case check with nmap e.g. for some IP
expected in subnet 192.168.123.0/24   

```
$ nmap -sn 192.168.123.0/24
    ...
    -> something with Raspberry pi...
    ...
```

Now the device should be available via ssh  
```
$ cd ./ansible
$ ansible all -m ping
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
	    "msg": "Failed to connect to the host via ssh: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\r\n@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @\r\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\r\nIT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!\r\nSomeone could be eavesdropping on you right now (man-in-the-middle attack)!\r\nIt is also possible that a host key has just been changed.\r\nThe fingerprint for the ED25519 key sent by the remote host is\nSHA256:vH4JKH+RXxG85SiYz26U7xX7aCgZ1a/YqF5Ip643vVQ.\r\nPlease contact your system administrator.\r\nAdd correct host key in /home/user/.ssh/known_hosts to get rid of this message.\r\nOffending ECDSA key in /home/user/.ssh/known_hosts:78\r\n  remove with:\r\n  ssh-keygen -f \"/home/user/.ssh/known_hosts\" -R \"10.1.10.200\"\r\nHost key for 10.1.10.200 has changed and you have requested strict checking.\r\nHost key verification failed.",
		    "unreachable": true
			}
```
*fix*: adjust .ssh/known_hosts  
```
ssh-keygen -f "/home/user/.ssh/known_hosts" -R "10.1.10.200"
```

