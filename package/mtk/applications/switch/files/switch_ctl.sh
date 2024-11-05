#!/bin/sh

[ ! -x /usr/sbin/switch ] && return

# determine switch type
get_switch_type() {
    if [ -e /proc/air_sw/device ] && grep -q "an8855" /proc/air_sw/device; then
        echo "an8855"
    else
        echo "mt753x"
    fi
}

SWITCH_TYPE=$(get_switch_type)

# set register address via switch type
# TODO: do noting in an8855 now
# since we dont know whats changed in an8855

REG_ADDR=0

#if [ "$SWITCH_TYPE" = "an8855" ]; then
#    REG_ADDR=1
#else
#    REG_ADDR=0
#fi

# shutdown ports
# $1 port lists，eg："1 2 3"
sw_poweroff_ports() {
    local ori_value
    local set_value
    [ -z "$1" ] && return 1
    for p in $1; do
        # read original value of register
        ori_value=$(switch phy cl22 r $p $REG_ADDR | awk -F'=' '{print $3}')

        # set power down control (bit 11) to 1
        set_value=$(($ori_value | 0x800))
        switch phy cl22 w $p $REG_ADDR $set_value >/dev/null 2>&1
    done
}

# power on ports
# $1 port lists，eg："1 2 3"
sw_poweron_ports() {
    local ori_value
    local set_value
    [ -z "$1" ] && return 1
    for p in $1; do
        # read original value of register
        ori_value=$(switch phy cl22 r $p $REG_ADDR | awk -F'=' '{print $3}')

        # clear power down control (bit 11)
        set_value=$(($ori_value & ~0x800))
        switch phy cl22 w $p $REG_ADDR $set_value >/dev/null 2>&1
    done
}

# auto negotiate port restart
sw_restart_port() {
    local ori_value
    local set_value
    [ -z "$1" ] && return 1
    for p in $1; do

        ori_value=$(switch phy cl22 r $p $REG_ADDR | awk -F'=' '{print $3}')

        # set auto negotiate bit (bit 9) to 1
        set_value=$(($ori_value | 0x200))
        switch phy cl22 w $p $REG_ADDR $set_value >/dev/null 2>&1
    done
}
