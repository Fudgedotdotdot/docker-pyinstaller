#!/bin/bash

# Fail on errors.
set -e

# Make sure .bashrc is sourced
. /root/.bashrc

# Allow the workdir to be set using an env var.
# Useful for CI pipiles which use docker for their build steps
# and don't allow that much flexibility to mount volumes
WORKDIR=${SRCDIR:-/src}

#
# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.
#
if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    # the funky looking regexp just extracts the hostname, excluding port
    # to be used as a trusted-host.
    mkdir -p /wine/drive_c/users/root/pip
    echo "[global]" > /wine/drive_c/users/root/pip/pip.ini
    echo "index = $PYPI_URL" >> /wine/drive_c/users/root/pip/pip.ini
    echo "index-url = $PYPI_INDEX_URL" >> /wine/drive_c/users/root/pip/pip.ini
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /wine/drive_c/users/root/pip/pip.ini

    echo "Using custom pip.ini: "
    cat /wine/drive_c/users/root/pip/pip.ini
fi

cd $WORKDIR

if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt not found - skipping package install..."
fi 

if [[ -z "$1" ]]; then
	echo "Usage: <script to compile>"
	exit
fi

pyinstaller --onefile --clean -y --distpath ./dist --workpath /tmp $1
chown -R --reference=. ./dist/

