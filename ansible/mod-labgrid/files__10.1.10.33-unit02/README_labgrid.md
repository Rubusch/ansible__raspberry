# Labgrid Exporter



## References

https://labgrid.readthedocs.io/en/latest/

## Configuration

Check the following fields
- IP of the coordinator
- Attached devices, use `labgrid-suggest` for the .yaml config stance
- Hostname in some configs

Adjust at least the following files
- `/etc/labgrid/exporter.yml` by the files contained in `/etc/labgrid/exporter/`
- `/etc/systemd/system/labgrid-exporter.service`, adjust ExecStart for **hostname/IP** and **coordinator IP**

Don't forget to `systemctl daemon-reload` when systemd was modified.  

## Usage

Turn on labgrid-exporter, in case check state again after a while
```
$ sudo systemctl start labgrid-exporter
```

Stop the labgrid-exporter
```
$ sudo systemctl stop labgrid-exporter
```

Get the state or error log of labgrid-exporter
```
$ sudo systemctl status labgrid-exporter
$ sudo journalctl -xeu labgrid-exporter
```

## Misc

GPIO26 (e.g. used for power control of DUT)
```
$ sudo systemctl start gpio26
```
or
```
$ sudo systemctl stop gpio26
```
