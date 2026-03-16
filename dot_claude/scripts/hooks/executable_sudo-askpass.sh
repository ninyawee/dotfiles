#!/bin/bash
# Zenity-based askpass for sudo - called by SUDO_ASKPASS
zenity --password --title="Claude Code: sudo password" --timeout=60 2>/dev/null
