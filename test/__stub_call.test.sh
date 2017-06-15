#! /usr/bin/env bash
source "test-helper.sh"

#
# __stub_call() tests.
#

# Adds call to stub call list.
stub uname

__stub_call "uname"
__stub_call "uname" -r
__stub_call "uname" -r -a

assert "wc -l < /tmp/__stub_sh_${EUID}__/uname" 3
assert "grep -xc '$(base64 <<< "<none>")' /tmp/__stub_sh_${EUID}__/uname" 1
assert "grep -xc '$(base64 <<< "-r")' /tmp/__stub_sh_${EUID}__/uname" 1
assert "grep -xc '$(base64 <<< "-r"),$(base64 <<< "-a")' /tmp/__stub_sh_${EUID}__/uname" 1
assert "grep -xc '$(base64 <<< "-r"),$(base64 <<< "-c")' /tmp/__stub_sh_${EUID}__/uname" 0

# End of tests.
assert_end "__stub_call()"
