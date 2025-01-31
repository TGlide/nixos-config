#!/usr/bin/env bash
echo hi &&
wpctl status |
    sed -n '/Sinks:/,/Sources:/p' |
    sd '├' '' |
    sd '─' '' |
    sd '│' '' |
    sd '└' '' |
    grep '\[vol:' |
    sd '\s*\[vol:.*$' '' |
    sd '^\s*(\d+)\.' '$1\t' |
    sd '.*?\*.*?(\d+).*?(\w.*$)' '<b>$1 $2 *</b>' |
    sd '[[:blank:]]+' ' ' |
    wofi --show=dmenu --hide-scroll --allow-markup |
    { read choice && wpctl set-default $(grep -o '^[0-9]\+' <<< "$choice"); }
