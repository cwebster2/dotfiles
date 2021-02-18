AUTO_LOCK=900

function _bw_get_session() {
  if ! key_id=$(keyctl request user bw_session 2>/dev/null); then
    2>&1 bw login --check > /dev/null || bw login --apikey
    2>&1 bw unlock --check > /dev/null || BW_SESSION=$(bw unlock --raw)
    key_id=$(echo "$BW_SESSION" | keyctl padd user bw_session @u)
  fi
  keyctl timeout "$key_id" $AUTO_LOCK
  BW_SESSION=$(keyctl pipe "$key_id")
}

alias bw_login="_bw_get_session; export BW_SESSION"
