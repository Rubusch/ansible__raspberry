# Configuration Management for my Raspi / Notes

## References

https://www.raspberry-pi-geek.de/ausgaben/rpg/2018/04/raspberry-pi-farm-mit-ansible-automatisieren/



## Preparation

On host PC  

```
$ sudo apt-add-repository -y ppa:ansible/ansible
$ sudo apt-get update
$ sudo apt-get install -y ansible
```

edit /etc/ansible/hosts  
```
[raspi]
10.1.10.222
```


Raspi OS image for Raspi 3b [64 bit]  
```
$ wget https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz
$ tar xJf 2022-09-22-raspios-bullseye-arm64-lite.img.xz
```

(legacy) Raspi OS image for Raspi 3b [32 bit]  
```
$ wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-09-26/2022-09-22-raspios-bullseye-armhf-lite.img.xz
$ tar xJf raspios_lite_armhf-2022-09-26/2022-09-22-raspios-bullseye-armhf-lite.img.xz$
```

prepare SD card  
```
$ lsblk
   -> /dev/sdd
$ sudo dd if=./2017-04-10-raspbian-jessie-lite.img of=/dev/sdd
```

individualization  
TODO: copy config to /boot/config.txt  
TODO: setup user pi  
TODO: setup ssh keys  
TODO: setup individualized configs (.gitconfig)  

Install SD card, and configure networking on the board.  

TODO: set up networking (fix ip 10.1.10.222/8) w/ running dnsmasq on eth0  
TODO: let dhcp client running on wlan0  


Now the device should be available via ssh.   
```
$ ansible all -m ping
```



## Manual Device Management

```
$ ansible raspi -s -m shell -a 'apt-get update'
$ ansible raspi -s -m apt -a 'pkg=nginx state=installed update_cache=true'
```



## Playbook Device Management

```
$ ansible-playbook -s raspi_notes.yml
```

TODO write ``rapsi_notes.yml`` playbook

