#!/bin/bash
#toggles the ready-led on (GPIO27)
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

/usr/bin/python3 $PATHDATA/toggle_gpio.py 18 y
