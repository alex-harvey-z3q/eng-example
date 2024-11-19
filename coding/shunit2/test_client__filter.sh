#!/usr/bin/env bash

under_test='./client.sh'

oneTimeSetUp() {
  . "$under_test"
}

_has_private_true_example() {
  cat <<-EOF
		{
		  "marketing": {
		    "dnszone": "example1.com.",
		    "targets": ["10.0.0.1"],
		    "private": true
		  }
		}
	EOF
}

_has_private_false_example() {
  cat <<-EOF
		{
		  "marketing": {
		    "dnszone": "example2.com.",
		    "targets": ["10.0.0.2"],
		    "private": false
		  }
		}
	EOF
}

_has_private_missing_example() {
  cat <<-EOF
		{
		  "marketing": {
		    "dnszone": "example3.com.",
		    "targets": ["10.0.0.3"]
		  }
		}
	EOF
}

test_filter__private_true() {
  local file_data
  file_data="$(_has_private_true_example)"
  local result
  result="$(filter "$file_data")"
  assertNull "filter should exclude objects with private=true" "$result"
}

test_filter__private_false() {
  local file_data
  file_data="$(_has_private_false_example)"
  local result
  result="$(filter "$file_data")"
  assertNotNull "filter should include objects with private=false" "$result"
  assertContains "filter should include the DNS zone" "$result" "example2.com."
}

test_filter__private_missing() {
  local file_data
  file_data="$(_has_private_missing_example)"
  local result
  result="$(filter "$file_data")"
  assertNull "filter should exclude objects that have no private key (i.e. we assume private=true as the default)" "$result"
}

. shunit2
