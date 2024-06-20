# USB SD MUX

## References

https://github.com/linux-automation/usbsdmux


## Usage

activate venv
```
$ source /opt/labgrid-venv/bin/activate
(venv) $
```

set to host
```
(venv) $ usbsdmux /dev/sg0 host
```

set to DUT
```
(venv) $ usbsdmux /dev/sg0 dut
```

get current state
```
(venv) $ usbsdmux /dev/sg0 get
```

turn off
```
(venv) $ usbsdmux /dev/sg0 off
```
