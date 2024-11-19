#!/usr/bin/env bash

under_test='./client.sh'

oneTimeSetUp() {
  . "$under_test"
}

_example_response() {
  cat <<-EOF
		{
		  "object1": {
		    "name": "example1",
		    "valid": true,
		    "details": {
		      "description": "First example object"
		    }
		  },
		  "object2": {
		    "name": "example2",
		    "valid": false,
		    "details": {
		      "description": "Second example object"
		    }
		  },
		  "object3": {
		    "name": "example3",
		    "details": {
		      "description": "Third example object"
		    }
		  },
		  "object4": {
		    "name": "example4",
		    "valid": true
		  }
		}
	EOF
}

_processed_data() {
  # the key of every object that has a child attribute "valid" set to true
  cat <<-EOF
		object1
		object4
	EOF
}

test_process() {
  local response_data
  response_data="$(_example_response)"
  local expected_processed actual_processed
  expected_processed="$(_processed_data)"
  actual_processed="$(process "$response_data")"
  assertEquals "Process function did not make the expected transformation" "$expected_processed" "$actual_processed"
}

. shunit2
