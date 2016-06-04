#!/usr/bin/env perl

use common::sense;

my $ip = shift;

my ($a,$b,$c,$d) = split /\./,$ip,4;


my $dec = ($d * 256^0) + ($c * 256^1) + ($b * 256^2) + ($a * 256^ 3);
my $hex = sprintf("%#x", $dec);
my $bin = sprintf("%#b", $dec);
say "ip: $ip \t bin: $bin \t dec: $dec \t hex: $hex";


