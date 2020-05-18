#echo "+ tools"

source ~/.nvm/nvm.sh

source ~/.fonts/fontawesome/*.sh

tabme() {
  if [ -n "$1" ]; then
    kitty @ new-window --new-tab --tab-title "${(@pj" ")@}"
  else
    kitty @ new-window --new-tab
  fi
}

app() {
  google-chrome --kiosk --app="$1"
}

#teams() {
#  app 'http://teams.microsoft.com'
#}

outlook() {
  app 'http://outlook.office365.com'
}

# doctl account get
# doctl compute ssh <DROPLET ID>
# doctl compute ssh-key import

##########################################################
## Get password from Lastpass and copy to clipboard
##########################################################
getpass () {
  IFS=$'\n'
  local account="$1"
  local lpass_entry=$(lpass ls | grep -i "${account}")
  local count=$(echo "${lpass_entry}" | wc -l)

  [ -z "${lpass_entry}" ] && return
  if [ "${count}" -gt 1 ]; then
    select lpass_entry in $(echo "${lpass_entry}"); do
      [ -n "${lpass_entry}" ] && break
    done
  fi
  echo "Copying Password To Clipboard: ${lpass_entry}"

  # Cuts the id out of something like:
  #  blah blah blah [id: 234234234234234322]
  local LPASS_ID=$(echo "${lpass_entry}" | perl -pe 's|.*?\s+(\d+)\]$|$1|')
  lpass show --password "${LPASS_ID}" | tr -d '\n' | xsel --clipboard --input \
    || lpass show --field=password "${LPASS_ID}" | tr -d '\n' | xsel --clipboard --input
}
