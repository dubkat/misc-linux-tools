#!/usr/bin/env perl
# blocker.pl - Input a list of hostnames, output pdnsd negate blocks.
# Copyright (C) 2015 Dan Reidy <dubkat@gmail.com>
# Perl::Critic Compliant: Level 1


use strict;
use warnings;
use Carp qw(croak);
use version; our $VERSION = 'v15.9.22';

#my $cnt = scalar @ARGV;
if ( scalar @ARGV == 0 ) {
	croak (q{I was expecting a list of hostnames. Idiot.});
}
for (0..@ARGV-1) {
	printf qq{neg {\n\tname=%s;\n\ttypes=A,AAAA,CNAME,NS;\n}\n}, shift;
}


