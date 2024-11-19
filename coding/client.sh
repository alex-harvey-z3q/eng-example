#!/usr/bin/env bash

default_service="https://example.com"
default_endpoint="/service/generate"

log_info()  { echo "[INFO] $*"  >&2 ; }
log_error() { echo "[ERROR] $*" >&2 ; }
log_debug() { [[ -n "$DEBUG" ]] && \
              echo "[DEBUG] $*" >&2 ; }

usage() {
  echo "Usage: [DEBUG=1] $0 [-h] -s SERVICE_URL -e ENDPOINT -i INPUT_FILE"
  exit 1
}

get_opts() {
  local opt OPTARG OPTIND

  service="$default_service"
  endpoint="$default_endpoint"

  while getopts "s:e:i:h" opt; do
    case "$opt" in
      s) service="$OPTARG" ;;
      e) endpoint="$OPTARG" ;;
      i) file_name="$OPTARG" ;;
      h) usage ;;
     \?) echo "ERROR: Invalid option -$OPTARG"
         usage ;;
    esac
  done

  shift $((OPTIND-1))

  if [[ -z "$file_name" ]] ; then
    usage
  fi
}

is_valid() {
  local file_data="$1"
  if ! jq empty <<< "$file_data" > /dev/null 2>&1 ; then
    log_error "Invalid JSON data"
    return 1
  fi
  return 0
}

filter() {
  local file_data="$1"
  log_debug "Filtering for private=false objects"
  jq '.[] | select(.private == false)' <<< "$file_data"
}

post() {
  local payload="$1"
  local endpoint="$2"

  log_info "Posting data to $endpoint"
  log_debug "Payload: $payload"

  local response
  response="$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$endpoint")"

  local curl_status="$?"

  if [[ "$curl_status" -ne 0 ]] ; then
    log_error "Failed to post data (curl exit status $curl_status)"
    return 1
  fi

  if [[ -z "$response" ]] ; then
    log_error "Got empty response"
    return 1
  fi

  echo "$response"
}

process() {
  local response_data="$1"
  log_debug "Processing server response"
  jq -r 'to_entries[] | select(.value.valid == true) | .key' <<< "$response_data"
}

main() {
  local file_data public_data response_data

  get_opts "$@"

  if [[ ! -f "$file_name" ]]; then
    log_error "File $file_name not found"
    exit 1
  fi

  file_data="$(< "$file_name")"

  if ! is_valid "$file_data" ; then
    log_error "$file_name does not contain valid JSON"
    log_debug "$file_data"
    exit 1
  fi

  public_data="$(filter "$file_data")"

  if [[ -z "$public_data" ]] ; then
    log_info "No public data to send (all objects are private)"
    exit 0
  fi

  if response_data="$(post "$public_data" "$service/$endpoint")" ; then
    log_error "Failed to send POST request"
    exit 1
  fi

  if ! is_valid "$response_data" ; then
    log_error "Response data does not contain valid JSON"
    log_debug "$response_data"
    exit 1
  fi

  process "$response_data"
}

if [[ "$0" = "${BASH_SOURCE[0]}" ]]; then
  main "$@"
fi
