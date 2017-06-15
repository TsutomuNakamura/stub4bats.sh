#! /usr/bin/env bash
source "test-helper.sh"

#
# __stub_clean() tests.
#

# Removes unsets stub call list, removes stub from index
STUB_INDEX=("uname=0" "top=1")
STUB_0_CALLS=("<none>" "-r" "-r -a")
STUB_1_CALLS=("-h")
__stub_clean "uname"

assert ''


# End of tests.
assert_end "__stub_clean()"
