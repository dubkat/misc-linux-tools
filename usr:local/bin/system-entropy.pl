#!/usr/bin/perl
# Copyright 2015 Dan Reidy <dubkat@gmail.com>

use common::sense;

my $entropy = qx{/sbin/sysctl -n kernel.random.entropy_avail};
my $pool = qx{/sbin/sysctl -n kernel.random.poolsize};
$entropy =~ s/\n//;
$pool =~ s/\n//;

printf "Poolsize:   %d\nWaterlevel: %d\nFill Level: %d%%\n", 
$pool, $entropy, ($entropy / $pool) * 100;




