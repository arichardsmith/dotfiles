if hash pbcopy 2>/dev/null; then
	# Darwin
	pbcopy
elif hash xclip 2>/dev/null; then
	# Linux
	xclip -selection clipboard
elif hash putclip 2>/dev/null; then
	# Windows
	putclip
else
	echo "No clipboard command available on this system" >&2
	exit 1
fi
