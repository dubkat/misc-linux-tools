#!/usr/bin/env perl

=license License
  pdsnd-generator.pl - Generate a list of hostnames for your network.
  Copyright (C) 2016 Daniel J. Reidy <dubkat@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
=cut

use common::sense;

my $netname = "local.network";
my $netnum = "192.168.2";

# azimuth.lan.static.home.box
my %static = (
	1 => 'azimuth.eth',
	2 => 'renegade.eth',
	3 => 'zenith.wifi',
	4 => 'zenith.eth',
	5 => 'meridian.wifi',
	6 => 'meridian.eth',
	8 => 'zircon.wifi',
	9 => 'bear-hunter.wifi',
	10 => 'otter-snatch.wifi',
	50 => 'chromecast.wifi',
	200 => 'acid.eth',
	205 => 'hopscotch.eth',
	206 => 'leapfrog.eth',
	254 => 'access-point01.wifi');


my ($a,$b,$c) = split /\./, $netnum;

my $reverse = sprintf( "%d-%d-%d", $c, $b, $a );
my $network = sprintf("%d.%d.%d", $a, $b, $c );
my %alias;

sub sethost {
	my $num = shift;
	my $hostname;


	my $dec = ($num * 256^0) + ($c * 256^1) + ($b * 256^2) + ($a * 256^ 3);
	my $hex = sprintf("%#x", $dec);
	my $bin = sprintf("%#b", $dec);
	#say "ip: $netnum.$d \t bin: $bin \t dec: $dec \t hex: $hex";

	given ($num) {
		when (0)   {
			$hostname = sprintf( "NETWORK-%s.%s", $reverse, $netname );
			$alias{$hostname} = sprintf( "NETWORK.%s", $netname );
		}
		when (255) {
			$hostname = sprintf( "BROADCAST.%s", $netname);
			$alias{$hostname} = "BROADCAST";
		}
		when (defined $static{$_}) {
			my ($host,$profile) = split /\./, $static{$_}, 2;
			$hostname = sprintf( "%s.static.%s.%s", $host, $profile, $netname );
			$alias{$hostname} = $host;
		}
		default {
			$hostname = sprintf( "%s.dhcp.wifi.%s", $hex, $netname );
			$alias{$hostname} = $hex;
		}
	}

	return ($hostname);
}

for (0..255) {
	my $hostname = sethost $_;
	printf "rr { \tname=%s; \ta=%s.%d;  \treverse=on;\t}\n", $hostname, $network, $_;
	if ( defined $alias{$hostname} ) {
		printf "rr { \tname=%s; \tcname=%s; \t}\n\n", $alias{$hostname}, $hostname;
	}
}
