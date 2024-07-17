#!/bin/bash
case $- in
    *i*) ;;
    *) return ;;
esac

bind_command_alt_r() {
    psh main
}

bind_command_ctrl_n() {
	psh note:modify
}

bind_command_ctrl_t() {
	psh note:tomorrow
}

# Check if Alt+r is already bound and bind it if not
if ! bind -p | grep -q '"\er"'; then
    bind -x '"\er": bind_command_alt_r'
fi

if ! bind -p | grep -q '"\C-n"'; then
    bind -x '"\C-n": bind_command_ctrl_n'
fi

if ! bind -p | grep -q '"\C-t"'; then
    bind -x '"\C-t": bind_command_ctrl_t'
fi