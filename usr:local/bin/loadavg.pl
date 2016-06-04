#!/usr/bin/perl

use common::sense;
use File::Slurp;

my $data = read_file("/proc/loadavg");
my ($a, $b, $c) = $data =~ m/^(\S+) (\S+) (\S+)/;

printf "%s %6s %5s %6s\n%s %5.02f %5.02f %5.02f\n%s %5.02f %5.02f %5.02f\n", 
       "Type:", "1", "5", "15", 
       "Reported:", $a, $b, $c, 
       "Relative:", $a/2, $b/2, $c/2;
