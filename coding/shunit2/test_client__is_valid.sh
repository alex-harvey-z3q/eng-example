#!/usr/bin/env bash

under_test='./client.sh'

oneTimeSetUp() {
  . "$under_test"
}

_valid_json_example() {
  echo '{"key": "value"}'
}

_invalid_json_example() {
  echo '{"key": "value"'
}

test_valid__true() {
  local file_data
  file_data="$(_valid_json_example)"
  is_valid "$file_data"
  assertTrue "If JSON is valid, is_valid should return true" "$?"
}

test_valid__false() {
  local file_data
  file_data="$(_invalid_json_example)"
  is_valid "$file_data"
  assertFalse "If JSON is invalid, is_valid should return false" "$?"
}

. shunit2

