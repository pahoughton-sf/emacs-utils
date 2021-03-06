#!/bin/bash
# File:	    test-system.bash
# Project:  emacs-utils
# Desc:
#
#   Perform system tests for emacs-utils product
#
# Author(s):   Paul Houghton <paul4hough@gmail.com>
# Created:     2013-10-08 11:12
#

test -n "$DEBUG" && set -x

topdir=$1
if [ -z "$topdir" ] ; then
    echo "Need topdir"
    exit 2
fi

results=0

# Setup and install into testing dir
cd "${topdir}"
[ -d tests_tmp/emacs-utils* ] && rm -rf tests_tmp
mkdir tests_tmp
make dist
cd tests_tmp
[ -d tests_home ] && rm -rf tests_home
mkdir tests_home
TEST_HOME=`pwd`/tests_home

tar xf ../emacs-utils*tar.gz
cd emacs-utils*
HOME="${TEST_HOME}"
autoreconf &&
./configure --with-lispdir="${TEST_HOME}/.emacs.d/lisp" &&
make install || exit 1
# double install works? (had a bug w/ this b4)
make install || exit 1
echo "Feature: emacs-utils"

expfiles='
.emacs.d/customize-23.el
.emacs.d/customize-24.el
.emacs.d/init-cygwin32.el
.emacs.d/init-darwin.el
.emacs.d/init-linux.el
.emacs.d/init-usg-unix-v.el
.emacs.d/init.el
'
for fn in ${expfiles} ; do
  if [ -f "${HOME}/${fn}"  ] ; then
    echo '  provides ${HOME}/'${fn}
  else
    echo '  FAILED to provide ${HOME}/'${fn}
    results=1
  fi
done

# good for debuging
# emacs -batch -l "${HOME}/.emacs.d/init.el" -eval '(princ load-path)'

func=timestamp
val=`emacs -batch -l "${HOME}/.emacs.d/init.el" -eval "(princ (${func}))" 2>test.${func}.out`
if [ -n "$val" ] ; then
  echo "  provides ${func}"
  echo "  provides init customization"
    [ -f test.${func}.out ] && rm test.${func}.out
else
  echo "  FAILED to provide ${func}"
  echo "  FAILED to provide init customization"
  results=1
fi
# todo markdown-mode
basic_functions='
cobol-mode
insert-classname
insert-timestamp
php-mode
puppet-mode
todo-mode
'
resutls=0;
for func in $basic_functions ; do
  if emacs -batch -l "${HOME}/.emacs.d/init.el" -eval "(${func})" > test.${func}.out 2>&1 ; then
    echo "  provides ${func}"
    [ -f test.${func}.out ] && rm test.${func}.out
  else
    echo "  FAILED to provide ${func}"
    cat test.${func}.out
    results=1
  fi
done

func="find-header"
echo stdlib.h | emacs -batch -l "${HOME}/.emacs.d/init.el" -eval "(${func})" > test.${func}.out 2>&1
if [ $? -eq 0 ] ; then
  echo "  provides ${func}"
    [ -f test.${func}.out ] && rm test.${func}.out
else
  echo "  FAILED ${func}"
  results=1
fi

#emacs -batch -l "${HOME}/.emacs.d/init.el" -eval '(princ load-path)'
exit $results
