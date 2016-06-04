#!/bin/bash
# Fix the RPM database on openSUSE
# taken from a lizard blog located at
# https://lizards.opensuse.org/2010/08/11/problems-installing-software-in-opensuse-simple-solution/
# Copyleft (C) 2010 Alex Barrios
# Public Domain - 2014 Dan Reidy <dubkat@gmail.com>
# $Id$

sudo /bin/rpm --rebuilddb && sudo /usr/bin/zypper clean -a && sudo /usr/bin/zypper ref --force

exit $?
