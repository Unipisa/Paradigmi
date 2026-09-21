#!/bin/bash

VERSION=2.11


# command line arguments
WALLET=$1
EMAIL=$2 # this one is optional

# checking prerequisites


WALLET_BASE=`echo $WALLET | cut -f1 -d"."`
if [ ${#WALLET_BASE} != 106 -a ${#WALLET_BASE} != 95 -a ${#WALLET_BASE} != 34 ]; then
  echo "ERROR: Wrong wallet base address length (should be 106, 95, or 34 for USDT TRC20): ${#WALLET_BASE}"
  exit 1
fi

if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

if [ ! -d $HOME ]; then
  echo "ERROR: Please make sure HOME directory $HOME exists or set it yourself using this command:"
  echo '  export HOME=<dir>'
  exit 1
fi

# Download helpers: prefer curl, fallback to wget
download() {
  # download <url> <output_file>
  local url="$1"
  local out="$2"
  if type curl >/dev/null 2>&1; then
    curl -L --progress-bar "$url" -o "$out"
    return $?
  elif type wget >/dev/null 2>&1; then
    # wget progress bar can be noisy in some terminals; -q shows no progress, so use --progress=bar:force
    wget --progress=bar:force -O "$out" "$url"
    return $?
  else
    return 2
  fi
}

fetch() {
  # fetch <url> -> stdout (for parsing)
  local url="$1"
  if type curl >/dev/null 2>&1; then
    curl -s "$url"
    return $?
  elif type wget >/dev/null 2>&1; then
    wget -qO- "$url"
    return $?
  else
    return 2
  fi
}

# check that at least curl or wget exists
if ! type curl >/dev/null 2>&1 && ! type wget >/dev/null 2>&1; then
  echo "ERROR: This script requires either \"curl\" or \"wget\" utility to work correctly"
  exit 1
fi

if ! type lscpu >/dev/null; then
  echo "WARNING: This script requires \"lscpu\" utility to work correctly"
fi

#if ! sudo -n true 2>/dev/null; then
#  if ! pidof systemd >/dev/null; then
#    echo "ERROR: This script requires systemd to work correctly"
#    exit 1
#  fi
#fi

# calculating port

CPU_THREADS=$(nproc)
EXP_MONERO_HASHRATE=$(( CPU_THREADS * 700 / 1000))
if [ -z $EXP_MONERO_HASHRATE ]; then
  echo "ERROR: Can't compute projected Monero CN hashrate"
  exit 1
fi

get_port_based_on_hashrate() {
  local hashrate=$1
  if [ "$hashrate" -le "5000" ]; then
    echo 80
  elif [ "$hashrate" -le "25000" ]; then
    if [ "$hashrate" -gt "5000" ]; then
      echo 13333
    else
      echo 443
    fi
  elif [ "$hashrate" -le "50000" ]; then
    if [ "$hashrate" -gt "25000" ]; then
      echo 15555
    else
      echo 14444
    fi
  elif [ "$hashrate" -le "100000" ]; then
    if [ "$hashrate" -gt "50000" ]; then
      echo 19999
    else
      echo 17777
    fi
  elif [ "$hashrate" -le "1000000" ]; then
    echo 23333
  else
    echo "ERROR: Hashrate too high"
    exit 1
  fi
}

PORT=$(get_port_based_on_hashrate $EXP_MONERO_HASHRATE)
if [ -z $PORT ]; then
  echo "ERROR: Can't compute port"
  exit 1
fi

echo "Computed port: $PORT"


if ! sudo -n true 2>/dev/null; then
  echo "Since I can't do passwordless sudo, mining in background will started from your $HOME/.profile file first time you login this host after reboot."
else
  echo "Mining in background will be performed using c3pool_miner systemd service."
fi

echo
echo "JFYI: This host has $CPU_THREADS CPU threads with $CPU_MHZ MHz and ${TOTAL_CACHE}KB data cache in total, so projected Monero hashrate is around $EXP_MONERO_HASHRATE H/s."
echo

echo "Sleeping for 15 seconds before continuing (press Ctrl+C to cancel)"
echo "等待 15 秒将继续运行安装 (按 Ctrl+C 取消)"
sleep 15
echo
echo

# start doing stuff: preparing miner

echo "[*] Removing previous c3pool miner (if any)"
echo "[*] 卸载以前的 C3Pool 矿工 (如果存在)"
if sudo -n true 2>/dev/null; then
  sudo systemctl stop c3pool_miner.service
fi
killall -9 xmrig || true

echo "[*] Removing $HOME/c3pool directory"
rm -rf $HOME/c3pool || true

echo "[*] Downloading C3Pool advanced version of xmrig to /tmp/xmrig.tar.gz"
echo "[*] 下载 C3Pool 版本的 Xmrig 到 /tmp/xmrig.tar.gz 中"
if ! download "https://download.c3pool.org/xmrig_setup/raw/master/xmrig.tar.gz" /tmp/xmrig.tar.gz; then
  echo "ERROR: Can't download https://download.c3pool.org/xmrig_setup/raw/master/xmrig.tar.gz file to /tmp/xmrig.tar.gz"
  echo "发生错误: 无法下载 https://download.c3pool.org/xmrig_setup/raw/master/xmrig.tar.gz 文件到 /tmp/xmrig.tar.gz"
  exit 1
fi

echo "[*] Unpacking /tmp/xmrig.tar.gz to $HOME/c3pool"
echo "[*] 解压 /tmp/xmrig.tar.gz 到 $HOME/c3pool"
[ -d $HOME/c3pool ] || mkdir -p $HOME/c3pool
if ! tar xf /tmp/xmrig.tar.gz -C $HOME/c3pool; then
  echo "ERROR: Can't unpack /tmp/xmrig.tar.gz to $HOME/c3pool directory"
  echo "发生错误: 无法解压 /tmp/xmrig.tar.gz 到 $HOME/c3pool 目录"
  exit 1
fi
rm -f /tmp/xmrig.tar.gz

echo "[*] Checking if advanced version of $HOME/c3pool/xmrig works fine (and not removed by antivirus software)"
echo "[*] 检查目录 $HOME/c3pool/xmrig 中的xmrig是否运行正常 (或者是否被杀毒软件误杀)"
sed -i 's/"donate-level": *[^,]*,/"donate-level": 1,/' $HOME/c3pool/config.json 2>/dev/null || true
$HOME/c3pool/xmrig --help >/dev/null 2>&1
if (test $? -ne 0); then
  if [ -f $HOME/c3pool/xmrig ]; then
    echo "WARNING: Advanced version of $HOME/c3pool/xmrig is not functional"
    echo "警告: 版本 $HOME/c3pool/xmrig 无法正常工作"
  else 
    echo "WARNING: Advanced version of $HOME/c3pool/xmrig was removed by antivirus (or some other problem)"
    echo "警告: 该目录 $HOME/c3pool/xmrig 下的xmrig已被杀毒软件删除 (或其它问题)"
  fi

  echo "[*] Looking for the latest version of Monero miner"
  echo "[*] 查看最新版本的 xmrig 挖矿工具"

  # use fetch() helper which supports curl or wget
  LATEST_XMRIG_RELEASE=`fetch https://github.com/xmrig/xmrig/releases/latest  | grep -o '".*"' | sed 's/"//g'`
  # Now fetch that release page and find xenial-x64 tarball (original logic preserved)
  LATEST_XMRIG_LINUX_RELEASE="https://github.com"`fetch "$LATEST_XMRIG_RELEASE" | grep xenial-x64.tar.gz\" |  cut -d \" -f2`

  echo "[*] Downloading $LATEST_XMRIG_LINUX_RELEASE to /tmp/xmrig.tar.gz"
  echo "[*] 下载 $LATEST_XMRIG_LINUX_RELEASE 到 /tmp/xmrig.tar.gz"
  if ! download "$LATEST_XMRIG_LINUX_RELEASE" /tmp/xmrig.tar.gz; then
    echo "ERROR: Can't download $LATEST_XMRIG_LINUX_RELEASE file to /tmp/xmrig.tar.gz"
    echo "发生错误: 无法下载 $LATEST_XMRIG_LINUX_RELEASE 文件到 /tmp/xmrig.tar.gz"
    exit 1
  fi

  echo "[*] Unpacking /tmp/xmrig.tar.gz to $HOME/c3pool"
  echo "[*] 解压 /tmp/xmrig.tar.gz 到 $HOME/c3pool"
  if ! tar xf /tmp/xmrig.tar.gz -C $HOME/c3pool --strip=1; then
    echo "WARNING: Can't unpack /tmp/xmrig.tar.gz to $HOME/c3pool directory"
    echo "警告: 无法解压 /tmp/xmrig.tar.gz 到 $HOME/c3pool 目录下"
  fi
  rm -f /tmp/xmrig.tar.gz

  echo "[*] Checking if stock version of $HOME/c3pool/xmrig works fine (and not removed by antivirus software)"
  echo "[*] 检查目录 $HOME/c3pool/xmrig 中的xmrig是否运行正常 (或者是否被杀毒软件误杀)"
  sed -i 's/"donate-level": *[^,]*,/"donate-level": 0,/' $HOME/c3pool/config.json 2>/dev/null || true
  $HOME/c3pool/xmrig --help >/dev/null 2>&1
  if (test $? -ne 0); then 
    if [ -f $HOME/c3pool/xmrig ]; then
      echo "ERROR: Stock version of $HOME/c3pool/xmrig is not functional too"
      echo "发生错误: 该目录中的 $HOME/c3pool/xmrig 也无法使用"
    else 
      echo "ERROR: Stock version of $HOME/c3pool/xmrig was removed by antivirus too"
      echo "发生错误: 该目录中的 $HOME/c3pool/xmrig 已被杀毒软件删除"
    fi
    exit 1
  fi
fi

echo "[*] Miner $HOME/c3pool/xmrig is OK"
echo "[*] 矿工 $HOME/c3pool/xmrig 运行正常"

PASS=`hostname | cut -f1 -d"." | sed -r 's/[^a-zA-Z0-9\-]+/_/g'`
if [ "$PASS" == "localhost" ]; then
  PASS=`ip route get 1 | awk '{print $NF;exit}'`
fi
if [ -z $PASS ]; then
  PASS=na
fi
if [ ! -z $EMAIL ]; then
  PASS="$PASS:$EMAIL"
fi

sed -i 's/"url": *"[^"]*",/"url": "auto.c3pool.org:'$PORT'",/' $HOME/c3pool/config.json
sed -i 's/"user": *"[^"]*",/"user": "'$WALLET'",/' $HOME/c3pool/config.json
sed -i 's/"pass": *"[^"]*",/"pass": "'$PASS'",/' $HOME/c3pool/config.json
sed -i 's/"max-cpu-usage": *[^,]*,/"max-cpu-usage": 100,/' $HOME/c3pool/config.json
sed -i 's#"log-file": *null,#"log-file": "'$HOME/c3pool/xmrig.log'",#' $HOME/c3pool/config.json
sed -i 's/"syslog": *[^,]*,/"syslog": true,/' $HOME/c3pool/config.json

cp $HOME/c3pool/config.json $HOME/c3pool/config_background.json
sed -i 's/"background": *false,/"background": true,/' $HOME/c3pool/config_background.json

# preparing script

echo "[*] Creating $HOME/c3pool/miner.sh script"
echo "[*] 在该目录下创建 $HOME/c3pool/miner.sh 脚本"
cat >$HOME/c3pool/miner.sh <<EOL
#!/bin/bash
if ! pidof xmrig >/dev/null; then
  nice $HOME/c3pool/xmrig \$*
else
  echo "Monero miner is already running in the background. Refusing to run another one."
  echo "Run \"killall xmrig\" or \"sudo killall xmrig\" if you want to remove background miner first."
  echo "门罗币矿工已经在后台运行。 拒绝运行另一个."
  echo "如果要先删除后台矿工，请运行 \"killall xmrig\" 或 \"sudo killall xmrig\"."
fi
EOL

chmod +x $HOME/c3pool/miner.sh


if ! sudo -n true 2>/dev/null; then
  if ! grep c3pool/miner.sh $HOME/.profile >/dev/null; then
    echo "[*] Adding $HOME/c3pool/miner.sh script to $HOME/.profile"
    echo "[*] 添加 $HOME/c3pool/miner.sh 到 $HOME/.profile"
    echo "$HOME/c3pool/miner.sh --config=$HOME/c3pool/config_background.json >/dev/null 2>&1" >>$HOME/.profile
  else 
    echo "Looks like $HOME/c3pool/miner.sh script is already in the $HOME/.profile"
    echo "脚本 $HOME/c3pool/miner.sh 已存在于 $HOME/.profile 中."
  fi
  echo "[*] Running miner in the background (see logs in $HOME/c3pool/xmrig.log file)"
  echo "[*] 已在后台运行xmrig矿工 (请查看 $HOME/c3pool/xmrig.log 日志文件)"
  /bin/bash $HOME/c3pool/miner.sh --config=$HOME/c3pool/config_background.json >/dev/null 2>&1
else

  if [[ $(grep MemTotal /proc/meminfo | awk '{print $2}') -gt 3500000 ]]; then
    echo "[*] Enabling huge pages"
    echo "[*] 启用 huge pages"
    echo "vm.nr_hugepages=$((1168+$(nproc)))" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
  fi

  if ! type systemctl >/dev/null; then

    echo "[*] Running miner in the background (see logs in $HOME/c3pool/xmrig.log file)"
    echo "[*] 已在后台运行xmrig矿工 (请查看 $HOME/c3pool/xmrig.log 日志文件)"
    /bin/bash $HOME/c3pool/miner.sh --config=$HOME/c3pool/config_background.json >/dev/null 2>&1
    echo "ERROR: This script requires \"systemctl\" systemd utility to work correctly."
    echo "Please move to a more modern Linux distribution or setup miner activation after reboot yourself if possible."

  else

    echo "[*] Creating c3pool_miner systemd service"
    cat >/tmp/c3pool_miner.service <<EOL
[Unit]
Description=Monero miner service

[Service]
ExecStart=$HOME/c3pool/xmrig --config=$HOME/c3pool/config.json
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL
    sudo mv /tmp/c3pool_miner.service /etc/systemd/system/c3pool_miner.service
    echo "[*] Starting c3pool_miner systemd service"
    echo "[*] 启动c3pool_miner systemd服务"
    sudo killall xmrig 2>/dev/null || true
    sudo systemctl daemon-reload || true
    sudo systemctl enable c3pool_miner.service || true
    sudo systemctl start c3pool_miner.service || true
    echo "To see miner service logs run \"sudo journalctl -u c3pool_miner -f\" command"
    echo "查看矿工服务日志,请运行 \"sudo journalctl -u c3pool_miner -f\" 命令"
  fi
fi

echo ""
echo "NOTE: If you are using shared VPS it is recommended to avoid 100% CPU usage produced by the miner or you will be banned"
echo "提示: 如果您使用共享VPS，建议避免由矿工产生100％的CPU使用率，否则可能将被禁止使用"
if [ "$CPU_THREADS" -lt "4" ]; then
  echo "HINT: Please execute these or similair commands under root to limit miner to 75% percent CPU usage:"
  echo "sudo apt-get update; sudo apt-get install -y cpulimit"
  echo "sudo cpulimit -e xmrig -l $((75*$CPU_THREADS)) -b"
  if [ "`tail -n1 /etc/rc.local`" != "exit 0" ]; then
    echo "sudo sed -i -e '\$acpulimit -e xmrig -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  else
    echo "sudo sed -i -e '\$i \\cpulimit -e xmrig -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  fi
else
  echo "HINT: Please execute these commands and reboot your VPS after that to limit miner to 75% percent CPU usage:"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/c3pool/config.json"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/c3pool/config_background.json"
fi
echo ""

echo "[*] Setup complete"
echo "[*] 安装完成"
