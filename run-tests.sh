#!/bin/sh

set -Ceu

# Work from project root
cd "$(dirname "$0")"

# Use build for build and test tools
mkdir -p build

# Ensure vimlparser and vimlint are available
if ! [ -d build/vim-vimlparser ]; then
	git clone --depth 1 https://github.com/ynkdir/vim-vimlparser build/vim-vimlparser
fi

if ! [ -d build/vim-vimlint ]; then
	git clone --depth 1 https://github.com/syngan/vim-vimlint build/vim-vimlint
fi

# Run vimlint
./build/vim-vimlint/bin/vimlint.sh -l build/vim-vimlint -p build/vim-vimlparser -v .

# Ensure vint is available, then run it
if command -v vint >/dev/null; then
	vint -s .
elif command -v python3 >/dev/null; then
	if ! [ -d build/venv3 ]; then
		python3 -m venv build/venv3
	fi
	if ! [ -x build/venv3/bin/vint ]; then
		# Note: --no-binary vim-vint is used to work around Kuniwak/vint#287
		./build/venv3/bin/pip3 install --no-binary vim-vint
	fi
	./build/venv3/bin/vint -s .
elif command -v virtualenv >/dev/null; then
	if ! [ -d build/venv2 ]; then
		virtualenv build/venv2
	fi
	if ! [ -x build/venv2/bin/vint ]; then
		# Note: --no-binary vim-vint is used to work around Kuniwak/vint#287
		./build/venv2/bin/pip install --no-binary vim-vint
	fi
	./build/venv2/bin/vint -s .
else
	echo 'Warning: Skipping vint.' >&2
fi

# Ensure vader.vim is available
if ! [ -d build/vader.vim ]; then
	git clone --depth 1 https://github.com/junegunn/vader.vim.git build/vader.vim
fi

# Run Vader tests
exec vim -i NONE -u test-vimrc -U NONE -V1 -nNeXs "$@" -c 'Vader! test/*.vader'
