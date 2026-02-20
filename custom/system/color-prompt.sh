#!/usr/bin/bash

if [ "$PS1" ]; then
    if [ "$TERM" != "dumb" ]; then
        PS1='[\[\e[0;32m\]\u@\h\[\e[0m\] \[\e[0;34m\]\W\[\e[0m\]]\$ '
    fi
fi
