#!/usr/bin/env bash

# If you're not using Linux you'll need to adjust the `-configuration` option
# to point to the `config_mac' or `config_win` folders depending on your system.

function config_os() {
  local config_="config_"
  local os_type=$OSTYPE

  if [[ $os_type == darwin* ]]; then
    echo "${config_}mac"
    return 0
  elif [[ $os_type == msys* ]]; then
    echo "${config_}win"
    return 0
  fi

  echo "${config_}linux"
}

LOMBOK_VER="${2:-1.18.22}"
LOMBOK_DIR="$HOME/.m2/repository/org/projectlombok/lombok/${LOMBOK_VER}/lombok-${LOMBOK_VER}.jar"
LOMBOK_EXISTS=false
if [[ -f "$LOMBOK_DIR" ]]; then
  LOMBOK_EXISTS=true
fi

JAR="$HOME/.local/ls/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
# GRADLE_HOME=$HOME/.gradle
sh -c '$JAVA11_HOME/bin/java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.protocol=true \
  -Dlog.level=ALL \
  -Xms1g \
  -Xmx2G \
  '$([[ "$LOMBOK_EXISTS" == true ]] && echo "-javaagent:${LOMBOK_DIR}")' \
  '$([[ "$LOMBOK_EXISTS" == true ]] && echo "-Xbootclasspath/a:${LOMBOK_DIR}")' \
  --add-modules=ALL-SYSTEM \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  -jar '$(echo "$JAR")' \
  -configuration "$HOME/.config/nvim/pack/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/'$(config_os)'" \
  -data "'${1:-$HOME/.config/nvim/workspace}'"'
