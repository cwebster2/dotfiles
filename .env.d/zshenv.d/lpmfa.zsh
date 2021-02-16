############################################################################
## How to use:
##
## - Create a new private note in lastpass
## - Make the note a json with the following form:
##   {
##     "Provider":"MFA Secret"
##   }
## - Save private note
## - Set the following environment variable to the ID of the lastpass note:
##   export LASTPASS_MFA_SECRETS_ID="Your Secret Note ID"
## - Source this file
## - Run `mfa`
##
## This tool will use the keys from the note and let you select which code
## you want to grab.  This will automatically copy the code to your clipboard
############################################################################

[[ -o interactive ]] && echo "+ lpass mfa helper"

function _which() {
  which $1 > /dev/null
}

function _punt() {
  echo "$1"
  exit 1
}

function _lpmfamessage() {
local account="$1"
local code="$2"
cat << EOF
Code copied to your clipboard
  Account: ${account}
  Code   : ${code}
EOF
}

function mfa() {
  LASTPASS_MFA_SECRETS_ID="${LASTPASS_MFA_SECRETS_ID:-294da919-8090-4813-b193-acd1015916df}"

  _which bw || _punt "You need to install the bitwarden cli"
  _which oathtool || _punt "You need to install oathtool"

  2>&1 bw login --check > /dev/null || bw login --apikey
  2>&1 bw unlock --check > /dev/null || export BW_SESSION=$(bw unlock --raw)

  MFA_SECRETS=$(bw get item "${LASTPASS_MFA_SECRETS_ID}" | jq --raw-output .notes)

  select account in $(echo "${MFA_SECRETS}" | jq -cr 'keys[]'); do
    local secret=$(echo "${MFA_SECRETS}" | jq -r ".${account}")
    local code=$(oathtool -b --totp "${secret}")
    _which xsel && echo -n "${code}" | xsel --primary --input
    _which xsel && echo -n "${code}" | xsel --clipboard --input
    _which pbcopy && echo -n "${code}" | pbcopy
    _lpmfamessage "${account}" "${code}"
    break;
  done
}

    bw get item "${KEYME_SSH_CONFIG_ID}" | jq --raw-output .notes > "${TMP_SSH_KEY_DIR}"/config
