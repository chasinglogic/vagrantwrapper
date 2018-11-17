#!/bin/sh
# Copyright 2018 Mathew Robinson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [[ -x $(which curl) ]]; then
    DOWNLOAD_CMD="curl"
else
    DOWNLOAD_CMD="wget"
fi

echo "Using $DOWNLOAD_CMD"

if [[ -z INSTALL_DIR ]]; then
    INSTALL_DIR="$HOME/.local/bin"
    echo "INSTALL_DIR was not set. Installing into the default $INSTALL_DIR"
fi

VAGRANTW_SCRIPT="https://raw.githubusercontent.com/chasinglogic/vagrantwrapper/master/vagrantw"

echo "Installing into $INSTALL_DIR"
mkdir -p $INSTALL_DIR
$DOWNLOAD_CMD -o $INSTALL_DIR/vagrantw $VAGRANTW_SCRIPT
chmod 0755 $INSTALL_DIR/vagrantw    