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

echo "+ lpass mfa helper"

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
  LASTPASS_MFA_SECRETS_ID="${LASTPASS_MFA_SECRETS_ID:-2483405299151369756}"

  _which lpass || _punt "You need to install the lpass cli"
  _which oathtool || _punt "You need to install oathtool"

  MFA_SECRETS=$(lpass show --note "${LASTPASS_MFA_SECRETS_ID}")

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
