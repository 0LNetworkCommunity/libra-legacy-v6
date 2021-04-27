DOWNLOAD_URLS=$(curl -sL https://api.github.com/repos/OLSF/libra/releases/latest | jq -r '.assets[].browser_download_url')


for b in $DOWNLOAD_URLS ; do \
  echo $b ; \
  echo $b | rev | cut -d"/" -f1 | rev ; \
  curl  --progress-bar --create-dirs -o /usr/local/bin/$(echo $b | rev | cut -d"/" -f1 | rev) -L $b ; \
  echo 'downloaded to /usr/local/bin/' ; \
  chmod 744 /usr/local/bin/$(echo $b | rev | cut -d"/" -f1 | rev) ;\
done