#!/bin/bash

# GNOME
watch="type=signal,interface=org.gnome.ScreenSaver"
screen_locked_signal="boolean true"
screen_unlocked_signal="boolean false"

# PulseAudio: use pactl
_get_default_sink() {
    pactl info | sed -n 's/^Default Sink: \(.*\)/\1/p'
}

_get_default_source() {
    pactl info | sed -n 's/^Default Source: \(.*\)/\1/p'
}

_set_default_sink() {
    pactl set-default-sink "$1"
}

_set_default_source() {
    pactl set-default-source "$1"
}

last_sink=$(_get_default_sink)
last_source=$(_get_default_source)
echo "sink is $last_sink; source is $last_source"

# Watch for screensaver D-Bus signals
dbus-monitor --session "$watch" | ( \
    while read signal; do
        if [[ "$signal" =~ "$screen_locked_signal" ]]; then
            # Screen locked: remember the current default sink and source
            last_sink=$(_get_default_sink)
            last_source=$(_get_default_source)
            echo "Screen Locked; sink was $last_sink; source was $last_source"
        elif [[ "$signal" =~ "$screen_unlocked_signal" ]]; then
            # Screen unlocked: restore the last default sink and source
            _set_default_sink "$last_sink"
            _set_default_source "$last_source"
            echo "Screen Unlocked; sink is $(_get_default_sink); source is $(_get_default_source)"
        fi
    done)
