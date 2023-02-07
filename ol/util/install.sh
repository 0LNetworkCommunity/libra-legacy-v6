apps=("db-backup" "db-backup-verify" "db-restore" "diem-node" "tower" "ol" "onboard" "txs")

for n in ${apps[@]}; do \
  curl  --progress-bar --create-dirs -o ~/bin/$n -L https://github.com/0LNetworkCommunity/libra/releases/latest/download/$n ; \
  echo $n '- downloaded to ~/bin/' ; \
  chmod 755 ~/bin/$n ;\
done

curl  --progress-bar --create-dirs -o ~/.0L/web-monitor.tar.gz -L https://github.com/0LNetworkCommunity/libra/releases/latest/download/web-monitor.tar.gz ; \
echo 'web-monitor.tar.gz - downloaded to ~/bin/' ; \

mkdir -p ~/.0L/web-monitor
tar -xf ~/.0L/web-monitor.tar.gz --directory ~/.0L/web-monitor/
