#!/bin/bash

SCRIPT_LOCATION=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export PERL5LIB="${SCRIPT_LOCATION}/src"

./client.pl