#!/usr/bin/env nu

# load the dorothy defaults
source ~/.local/share/dorothy/config/interactive.nu


# add snap bin to path, if snap is installed
const snap_bin = "/snap/bin"
if ($snap_bin | path exists) {
	$env.PATH = ($env.PATH | split row (char esep) | prepend $snap_bin)
} else {
	# remove snap from path, if snap is not installed
	echo "skip: snap not installed"
}

# add linuxbrew bin to path, if linuxbrew is installed
const linuxbrew_bin = "/home/linuxbrew/.linuxbrew/bin"
if ($linuxbrew_bin | path exists) {
	$env.PATH = ($env.PATH | split row (char esep) | prepend $linuxbrew_bin)
} else {
	# remove linuxbrew from path, if linuxbrew is not installed
	echo "skip: linuxbrew not installed"
}

$env.DOROTHY_THEME = 'starship'

$env.config.completions.algorithm = 'fuzzy'
$env.config.history.file_format = 'sqlite'
$env.config.show_banner = false

mise activate nu |  save --force ~/.config/dorothy/config/mise.nu
source ~/.config/dorothy/config/mise.nu
