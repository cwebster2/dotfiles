#!/usr/bin/env bash




#########################################################
## Keys
#########################################################

_keysToLoadHelp () {
echo '

Error:  Missing KEYME_KEYS_TO_LOAD Environment

Syntax:
  $last_pass_id<space>$friendly_name_on_your_disk

Example:

export KEYME_KEYS_TO_LOAD="
4318234233850238648 example1
8764128140835055732 example2
5866756601936395183 id_rsa
"
'

}

_lastPassUserHelp () {
echo '

Error:  Missing bitwarden Environment

Syntax:
  export BW_CLIENTID="user.guid"
  export BW_CLIENTSECRET="secret"

You should probably set this in your bashrc or zshrc
'
}

_purgeIfEmpty () {
  CHECK=$(cat $1)
  if [ -z "${CHECK}" ]; then
    echo Removing Empty: $1
    rm "$1"
  fi
}

_chmod () {
  [ -f "$2" ] && chmod $1 "$2"
}

TMP_SSH_KEY_DIR="/run/user/$(id -u)/.ssh"

add_key () {
  echo Installing Key: $2
  echo Fix for bitwarden use
  #lpass show "$1" --field "Private Key" > "${TMP_SSH_KEY_DIR}/$2"
  #lpass show "$1" --field "Public Key" > "${TMP_SSH_KEY_DIR}/$2.pub"
  #_purgeIfEmpty "${TMP_SSH_KEY_DIR}/$2"
  #_purgeIfEmpty "${TMP_SSH_KEY_DIR}/$2.pub"
  #_chmod 400 "${TMP_SSH_KEY_DIR}/$2"
  #_chmod 400 "${TMP_SSH_KEY_DIR}/$2.pub"
  #ssh-add "${TMP_SSH_KEY_DIR}/$2"
}

keyme () {
  [ -z "${KEYME_KEYS_TO_LOAD}" ] && _keysToLoadHelp && return
  [ -z "${BW_CLIENTID}" ] && _keysToLoadHelp && return
  [ -z "${BW_CLIENTSECRET}" ] && _keysToLoadHelp && return
  echo Bitwarden login...
  _bw_get_session
  echo Purging "${TMP_SSH_KEY_DIR}"
  [ -d "${TMP_SSH_KEY_DIR}" ] && rm -rf "${TMP_SSH_KEY_DIR}"
  echo Making tmp dir "${TMP_SSH_KEY_DIR}"...
  mkdir -p "${TMP_SSH_KEY_DIR}" 2> /dev/null
  chown $USER:$USER "${TMP_SSH_KEY_DIR}"
  chmod 700 "${TMP_SSH_KEY_DIR}"
  if [ ! -f "${TMP_SSH_KEY_DIR}"/config ]; then
    echo "Installing ssh config"
    bw --session $BW_SESSION get item "${KEYME_SSH_CONFIG_ID}" | jq --raw-output .notes > "${TMP_SSH_KEY_DIR}"/config
    chmod 600 "${TMP_SSH_KEY_DIR}"/config
  fi
  echo Purging "${HOME}/.ssh"
  [ -d $HOME/.ssh ] && rm -rf $HOME/.ssh
  ln -s "${TMP_SSH_KEY_DIR}" "${HOME}/.ssh"
  IFS=$'\n'
  for key_and_name in $(echo "${KEYME_KEYS_TO_LOAD}"); do
    local id=$(echo $key_and_name | awk '{print $1}')
    local name=$(echo $key_and_name | awk '{print $2}')
    add_key "${id}" "${name}"
  done
  SSHPDIR=${HOME}/.ssh-persistant
  if [ ! -d "${SSHPDIR}" ]; then
    echo Making tmp dir "${SSHPDIR}"...
    mkdir -p "${SSHPDIR}" 2> /dev/null
    chown $USER:$USER "${SSHPDIR}"
    chmod 700 "${SSHPDIR}"
  fi
}

agentme () {
  kill -9 $(pidof scdaemon) >/dev/null 2>&1 || true
  kill -9 $(pidof gpg-agent) >/dev/null 2>&1 || true
  gpg-connect-agent /bye >/dev/null 2>&1 || true
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1 || true
}
