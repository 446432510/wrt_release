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


# 集成 qosmate 插件（流量控制）
cd $GITHUB_WORKSPACE/immortalwrt/package
# 拉取 qosmate 源码（双镜像防失败）
git clone --depth 1 https://github.com/hudra0/qosmate.git luci-app-qosmate || git clone --depth 1 
# 清理冲突的 QoS 插件（避免编译冲突）
sed -i '/CONFIG_PACKAGE_luci-app-sqm/d' ../.config
sed -i '/CONFIG_PACKAGE_qos-scripts/d' ../.config
sed -i '/CONFIG_PACKAGE_luci-app-qos/d' ../.config
# 强制启用 qosmate 编译
echo 'CONFIG_PACKAGE_luci-app-qosmate=y' >> ../.config
# 安装依赖（确保编译不缺组件）
cd $GITHUB_WORKSPACE/immortalwrt
./scripts/feeds update -a && ./scripts/feeds install -y luci-app-qosmate



