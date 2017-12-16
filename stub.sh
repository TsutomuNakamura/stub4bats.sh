# !/usr/bin/env bash
#
# stub.sh 1.0.2 - stubbing helpers for simplifying bash script tests.
# https://github.com/jimeh/stub.sh
#
# (The MIT License)
#
# Copyright (c) 2014 Jim Myhrberg.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#

# TODO:
##/tmp/__stub_sh_${EUID}_${PPID}__/*
command rm -rf /tmp/__stub_sh_${EUID}__/*

# Public: Stub given command.
#
# Arguments:
#   - $1: Name of command to stub.
#   - $2: (optional) When set to "STDOUT", echo a default message to STDOUT.
#         When set to "STDERR", echo default message to STDERR.
#
# Echoes nothing.
# Returns nothing.
stub() {
  local redirect="null"

  if [[ "${2^^}" = "STDOUT" ]]; then
    redirect=""
  elif [[ "${2^^}" = "STDERR" ]]; then
    redirect="stderr"
  fi

  stub_and_echo "$1" "$1 stub: \$@" "$redirect"
}


# Public: Stub given command, and echo given string.
#
# Arguments:
#   - $1: Name of command to stub.
#   - $2: String to echo when stub is called.
#   - $3: (optional) When set to "STDERR", echo to STDERR instead of STDOUT.
#         When set to "null", all output is redirected to /dev/null.
#
# Echoes nothing.
# Returns nothing.
stub_and_echo() {
  local redirect=""

  if [[ "${3^^}" = "STDERR" ]]; then
    redirect=" 1>&2"
  elif [[ "$3" = "null" ]]; then
    redirect=" &>/dev/null";
  fi

  # stub_and_eval "$1" "echo \"$2\"$redirect"
  stub_and_eval "$1" "command echo \"$2\"$redirect"
}


# Public: Stub given command, and execute given string with eval.
#
# Arguments:
#   - $1: Name of command to stub.
#   - $2: String to eval when stub is called.
#
# Echoes nothing.
# Returns nothing.
stub_and_eval() {
  local cmd="$1"

  if ! declare -p STUB_DICTIONARY &> /dev/null; then
    declare -g -A STUB_DICTIONARY
  fi

#  if [ "${#STUB_INDEX[@]}" -eq 0 ]; then
  if [ "${#STUB_DICTIONARY[@]}" -eq 0 ]; then
      command mkdir -p /tmp/__stub_sh_${EUID}__
      command rm -f /tmp/__stub_sh_${EUID}__/*
  fi

  # Prepare stub index and call list for this stub.
  __stub_register "$cmd"

  # Create the stub.
  eval "$( command printf "%s" "${cmd}() {  __stub_call \"${cmd}\" \"\$@\";  $2;}")"
}


# Public: Find out if stub has been called. Returns 0 if yes, 1 if no.
#
# Arguments:
#   - $1: Name of stubbed command.
#
# Echoes nothing.
# Returns 0 (success) is stub has been called, 1 (error) otherwise.
stub_called() {
  if [ "$(stub_called_times "$1")" -lt 1 ]; then
    return 1
  fi
}


# Public: Find out if stub has been called with specific arguments.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $@: Any/all additional arguments are used to specify what stub was
#         called with.
#
# Examples:
#   stub uname
#   uname
#   uname -r -a
#   stub_called_with uname       # Returns 0 (success).
#   stub_called_with uname -r    # Returns 1 (error).
#   stub_called_with uname -r -a # Returns 0 (success).
#
# Echoes nothing.
# Returns 0 (success) if specified stub has been called with given arguments,
# otherwise returns 1 (error).
stub_called_with() {
  local cmd="$1"
  shift 1

  if [ "$(stub_called_with_times "$cmd" "$@")" -lt 1 ]; then
    return 1
  fi
}


# Public: Find out how many times a stub has been called.
#
# Arguments:
#   - $1: Name of stubbed command.
#
# Echoes number of times stub has been called if $2 is not given, otherwise
# echoes nothing.
# Returns 0 (success) if $2 is not given, or if it is given and it matches the
# number of times the stub has been called. Otherwise 1 (error) is returned if
# it doesn't match..
stub_called_times() {
  local cmd="$1"
  local count=0

  if [ -f /tmp/__stub_sh_${EUID}__/${cmd} ]; then
    count=$(command wc -l < /tmp/__stub_sh_${EUID}__/${cmd})
  fi

  command echo $count
}


# Public: Find out if stub has been called exactly the given number of times
# with specified arguments.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $2: Exact number of times stub has been called.
#
# Echoes nothing.
# Returns 0 (success) if stub has been called at least the given number of
# times with specified arguments, otherwise 1 (error) is returned.
stub_called_exactly_times() {
  if [ "$(stub_called_times "$1")" != "$2" ]; then
    return 1
  fi
}


# Public: Find out if stub has been called at least the given number of times.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $2: Minimum required number of times stub has been called.
#
# Echoes nothing.
# Returns 0 (success) if stub has been called at least the given number of
# times, otherwise 1 (error) is returned.
stub_called_at_least_times() {
  if [ "$(stub_called_times "$1")" -lt "$2" ]; then
    return 1
  fi
}


# Public: Find out if stub has been called no more than the given number of
# times.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $2: Maximum allowed number of times stub has been called.
#
# Echoes nothing.
# Returns 0 (success) if stub has been called no more than the given number of
# times, otherwise 1 (error) is returned.
stub_called_at_most_times() {
  if [ "$(stub_called_times "$1")" -gt "$2" ]; then
    return 1
  fi
}


# Public: Find out how many times a stub has been called with specific
# arguments.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $@: Any/all additional arguments are used to specify what stub was
#         called with.
#
# Echoes number of times stub has been called with given arguments.
# Return 0 (success).
stub_called_with_times() {
  local cmd="$1"
  local i=
  shift 1

  declare -a args=("$@")
  if [ "${#args[@]}" -eq 0 ]; then args+=("<none>"); fi

  local count=0
  #local index="$(__stub_index "$cmd")"
  if [ -f /tmp/__stub_sh_${EUID}__/${cmd} ]; then
    # Create base64 argments
    local args64
    for (( i = 0; i < ${#args[@]}; ++i )) {
      [[ "$i" -ne 0 ]] && args64+=","
      args64+="$(command base64 -w 0 <<< "${args[i]}")"
    }
    count="$(command grep -xc "${args64}" /tmp/__stub_sh_${EUID}__/${cmd})"
  fi

  command echo $count
}

# Public: Find out if stub has been called exactly the given number of times
# with specified arguments.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $2: Exact number of times stub has been called.
#   - $@: Any/all additional arguments are used to specify what stub was
#         called with.
#
# Echoes nothing.
# Returns 0 (success) if stub has been called at least the given number of
# times with specified arguments, otherwise 1 (error) is returned.
stub_called_with_exactly_times() {
  local cmd="$1"
  local count="$2"
  shift 2

  if [ "$(stub_called_with_times "$cmd" "$@")" != "$count" ]; then
    return 1
  fi
}


# Public: Find out if stub has been called at least the given number of times
# with specified arguments.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $2: Minimum required number of times stub has been called.
#   - $@: Any/all additional arguments are used to specify what stub was
#         called with.
#
# Echoes nothing.
# Returns 0 (success) if stub has been called at least the given number of
# times with specified arguments, otherwise 1 (error) is returned.
stub_called_with_at_least_times() {
  local cmd="$1"
  local count="$2"
  shift 2

  if [ "$(stub_called_with_times "$cmd" "$@")" -lt "$count" ]; then
    return 1
  fi
}


# Public: Find out if stub has been called no more than the given number of
# times.
#
# Arguments:
#   - $1: Name of stubbed command.
#   - $2: Maximum allowed number of times stub has been called.
#   - $@: Any/all additional arguments are used to specify what stub was
#         called with.
#
# Echoes nothing.
# Returns 0 (success) if stub has been called no more than the given number of
# times with specified arguments, otherwise 1 (error) is returned.
stub_called_with_at_most_times() {
  local cmd="$1"
  local count="$2"
  shift 2

  if [ "$(stub_called_with_times "$cmd" "$@")" -gt "$count" ]; then
    return 1
  fi
}


# Public: Restore the original command/function that was stubbed.
#
# Arguments:
#   - $1: Name of command to restore.
#
# Echoes nothing.
# Returns nothing.
restore() {
  local cmd="$1"

  if [ -z "${STUB_DICTIONARY[${cmd}]}" ]; then
    return 0
  fi

  # Remove stub functions.
  unset -f "$cmd"

  # If stub was for a function, restore the original function.
  if [ -n "${#STUB_DICTIONARY[${cmd}]}" ]; then
    if [ "${STUB_DICTIONARY[${cmd}]}" != "<command>" ]; then
      # If it is a function...
      eval "${STUB_DICTIONARY[${cmd}]}"
      unset STUB_DICTIONARY[${cmd}]
    fi
  fi
}


#
# Internal functions
#

# Private: Used to keep track of which stubs have been called and how many
# times.
__stub_call() {
  local cmd="$1"
  shift 1
  declare -a args=("$@")
  local i=
  if [ "${#args[@]}" -eq 0 ]; then args+=("<none>"); fi

  if [ -n "${STUB_DICTIONARY[${cmd}]}" ]; then
    local args64
    for ((i = 0; i < ${#args[@]}; ++i)) {
      [ "$i" -ne 0 ] && args64+=","
      args64+="$(command base64 -w 0 <<< "${args[i]}")"
    }

    command echo "$args64" >> /tmp/__stub_sh_${EUID}__/${cmd}
  fi
}

# Private: Prepare for the creation of a new stub. Adds stub to index and
# sets up an empty call list.
__stub_register() {
  local cmd="$1"

  # Clean up after any previous stub for the same command.
  #__stub_clean "$cmd"

  if [[ -z "${STUB_DICTIONARY[${cmd}]}" ]]; then
    local type_of_object="$(type "$cmd" 2> /dev/null | command head -1)"
    if [[ "$type_of_object" == *"is a function" ]]; then
      STUB_DICTIONARY[${cmd}]="$(type "$cmd" | command tail -n +2)"
    else
      STUB_DICTIONARY[${cmd}]="<command>"
    fi
  fi
  command rm -f /tmp/__stub_sh_${EUID}__/${cmd}
}

# Private: Cleans out and removes a stub's call list, and removes stub from
# index.
__stub_clean() {
  local cmd="$1"

  # Remove all relevant details from any previously existing stub for the same
  # command.
  if [[ -n "${STUB_DICTIONARY[${cmd}]}" ]]; then
    if [[ "${STUB_DICTIONARY[${cmd}]}" = "<command>" ]]; then

      unset STUB_DICTIONARY[${cmd}]
    else
      # Restore original function
      unset -f ${cmd}
      eval "${STUB_DICTIONARY[${cmd}]}"
    fi
  fi
  command rm -f /tmp/__stub_sh_${EUID}__/${cmd}
}
