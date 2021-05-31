DOWNLOAD_URLS=$(curl -sL https://api.github.com/repos/OLSF/libra/releases/latest | jq -r '.assets[].browser_download_url')

for b in $DOWNLOAD_URLS ; do \
  echo $b ; \
  echo $b | rev | cut -d"/" -f1 | rev ; \
  curl  --progress-bar --create-dirs -o ~/bin/$(echo $b | rev | cut -d"/" -f1 | rev) -L $b ; \
  echo 'downloaded to /usr/local/bin/' ; \
  chmod 755 ~/bin/$(echo $b | rev | cut -d"/" -f1 | rev) ;\
done

mkdir -p ~/.0L/web-monitor
tar -xf ~/bin/web-monitor.tar.gz -d ~/.0L/web-monitor/
