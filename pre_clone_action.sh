#!/usr/bin/env bash
#
# Copyright (C) 2025 ZqinKing
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

set -e

BASE_PATH=$(cd $(dirname $0) && pwd)

Dev=$1

CONFIG_FILE="$BASE_PATH/deconfig/$Dev.config"
INI_FILE="$BASE_PATH/compilecfg/$Dev.ini"

if [[ ! -f $CONFIG_FILE ]]; then
    echo "Config not found: $CONFIG_FILE"
    exit 1
fi

if [[ ! -f $INI_FILE ]]; then
    echo "INI file not found: $INI_FILE"
    exit 1
fi

read_ini_by_key() {
    local key=$1
    awk -F"=" -v key="$key" '$1 == key {print $2}' "$INI_FILE"
}

REPO_URL=$(read_ini_by_key "REPO_URL")
REPO_BRANCH=$(read_ini_by_key "REPO_BRANCH")
REPO_BRANCH=${REPO_BRANCH:-main}
BUILD_DIR="$BASE_PATH/action_build"

echo $REPO_URL $REPO_BRANCH
echo "$REPO_URL/$REPO_BRANCH" >"$BASE_PATH/repo_flag"
git clone --depth 1 -b $REPO_BRANCH $REPO_URL $BUILD_DIR

# GitHub Action 移除国内下载源
PROJECT_MIRRORS_FILE="$BUILD_DIR/scripts/projectsmirrors.json"

if [ -f "$PROJECT_MIRRORS_FILE" ]; then
    sed -i '/.cn\//d; /tencent/d; /aliyun/d' "$PROJECT_MIRRORS_FILE"
fi



#新增
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
LATEST_TAG=$(uclient-fetch -O - https://api.github.com/repos/hudra0/qosmate/releases/latest 2>/dev/null | grep -o '"tag_name":"[^"]*' | sed 's/"tag_name":"//') && \
uclient-fetch -O /etc/init.d/qosmate https://raw.githubusercontent.com/hudra0/qosmate/$LATEST_TAG/etc/init.d/qosmate && chmod +x /etc/init.d/qosmate && \
uclient-fetch -O /etc/qosmate.sh https://raw.githubusercontent.com/hudra0/qosmate/$LATEST_TAG/etc/qosmate.sh && chmod +x /etc/qosmate.sh && \
[ ! -f /etc/config/qosmate ] && uclient-fetch -O /etc/config/qosmate https://raw.githubusercontent.com/hudra0/qosmate/$LATEST_TAG/etc/config/qosmate; \
/etc/init.d/qosmate enable
LATEST_TAG=$(uclient-fetch -O - https://api.github.com/repos/hudra0/luci-app-qosmate/releases/latest 2>/dev/null | grep -o '"tag_name":"[^"]*' | sed 's/"tag_name":"//') && \
mkdir -p /www/luci-static/resources/view/qosmate /usr/share/luci/menu.d /usr/share/rpcd/acl.d /usr/libexec/rpcd && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/settings.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/settings.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/hfsc.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/hfsc.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/cake.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/cake.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/advanced.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/advanced.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/rules.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/rules.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/connections.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/connections.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/custom_rules.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/custom_rules.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/ipsets.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/ipsets.js && \
uclient-fetch -O /www/luci-static/resources/view/qosmate/statistics.js https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/htdocs/luci-static/resources/view/statistics.js && \
uclient-fetch -O /usr/share/luci/menu.d/luci-app-qosmate.json https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/root/usr/share/luci/menu.d/luci-app-qosmate.json && \
uclient-fetch -O /usr/share/rpcd/acl.d/luci-app-qosmate.json https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/root/usr/share/rpcd/acl.d/luci-app-qosmate.json && \
uclient-fetch -O /usr/libexec/rpcd/luci.qosmate https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/root/usr/libexec/rpcd/luci.qosmate && \
uclient-fetch -O /usr/libexec/rpcd/luci.qosmate_stats https://raw.githubusercontent.com/hudra0/luci-app-qosmate/$LATEST_TAG/root/usr/libexec/rpcd/luci.qosmate_stats && \
chmod +x /usr/libexec/rpcd/luci.qosmate && \
chmod +x /usr/libexec/rpcd/luci.qosmate_stats && \
/etc/init.d/rpcd restart && \
/etc/init.d/uhttpd restart
# End of command - Press Enter after pasting
/etc/init.d/qosmate start
