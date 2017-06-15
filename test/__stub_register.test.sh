#! /usr/bin/env bash
source "test-helper.sh"

#
# __stub_register() tests.
#

# Sets up stub index, stub call list, and adds stub to index.
hoge () { echo test; }

__stub_register "uname"
__stub_register "top"
__stub_register "hoge"

assert 'echo ${#STUB_DICTIONARY[@]}' 3
assert 'echo ${STUB_DICTIONARY[uname]}' '<command>'
assert 'echo ${STUB_DICTIONARY[top]}' '<command>'
assert 'echo ${STUB_DICTIONARY[hoge]}' 'hoge () { echo test }'

# Note: There seems to be no possible way to validate if a empty array
# variable has been set, as it appears to be empty/null/undefined whatever I
# try.


# End of tests.
assert_end "__stub_register()"
