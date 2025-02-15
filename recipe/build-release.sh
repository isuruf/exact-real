#!/bin/bash
set -ex

# Run ./configure
source ./recipe/cflags.sh
./recipe/configure.sh

# Build libexactreal
make

# Run all our test suites
make check
make check-valgrind
make distcheck

# /tmp/secrets contains some CI-injected credentials to services such as
# coveralls or ASV.
source /tmp/secrets || true

# Run benchmarks on the release variant
./recipe/run-asv.sh

# Enforce proper formatting of C++ code
clang-format -i -style=file `git ls-files '*.cc' '*.hpp' '*.ipp' '*.h' '*.h.in' '*.hpp.in'`
git diff --exit-code
   
# Make sure there's no pending todos
! grep "TO""DO" `git ls-files | grep -v external | grep -v azure-pipelines`
