#!/usr/bin/perl

# sysinfo.pl - Just Another Perl Linux Sysinfo Script
# Copyright (C) 2006-2014 Dan Reidy (dubkat) <dubkat@gmail.com>
# $Id$
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# If you recieve a warning saying something similar
# to 'wrong parameter for Processes' you need to upgrade
# Sys::Statistics::Linux >= 0.10
#
# TODO suidperl(?) for detailed cryptsetup, luks, and raid info.

# YOU MAY EDIT THESE SETTINGS HERE.
my $showcrypt         = 1;  # off = 0, on = 1 (only displayed for the root user)
my $hide_nfs          = 0;  # off = 0, on = 1
my $show_swap_with_fs = 0;  # show swap as a filesystem.

# STOP EDITING.

# Perl has the uglist, and most cryptic FAILURE messages, lets try
# to avert the most common ones, and give readable resolutions.
BEGIN {
    my $err = 0;
    unless ( $^O eq 'linux' ) {
        warn ">>> Sorry, This script currently only works on GNU/Linux.\n";
        exit 1;
    }

    unless ( eval { require Sys::Statistics::Linux; } ) {
        warn ">>> The Sys::Statistics::Linux module is required.\n";
        $err++;
    }
    unless ( eval { require POSIX; } ) {
        warn ">>> The POSIX module is required.\n";
        $err++;
    }
    unless ( eval { require File::Basename; } ) {
        warn ">>> The File::Basename module is required.\n";
        $err++;
    }
    unless ( eval { require Getopt::Long; } ) {
        warn ">>> The Getopt::Long module is required.\n";
        $err++;
    }
	unless( eval { require File::Glob; } ) {
		warn ">>> The File::Glob module is required.\n";
		$err++;
	}
    unless ( eval { require Pod::Usage; } ) {
        warn ">>> The Pod::Usage module is required.\n";
        $err++;
    }

    if ($err) {
        warn
          ">>> Please install the modules required for this script via CPAN,\n";
        warn ">>> or ask your system administrator to install them for you.\n";
        exit $err;
    }

    $ENV{'PATH'} = join( ':', qw( /bin /usr/bin /usr/local/bin ) );
    $ENV{'IFS'} = '';
}

# life is good

# do we have any common sense?
use if eval { require common::sense } == 1, "common::sense";
use if eval { require common::sense } == 0, "strict";
use if eval { require common::sense } == 0, "warnings";

use File::Basename;
use Sys::Statistics::Linux;
use Getopt::Long;
use Pod::Usage;
use POSIX;

my $version = 0.9.2;
my $rev     = '$Revision: 46 $';
our $width;
my ( $watch, $help, $doc, $ver, 
     $host, $workload, $memory, 
     $net, $partitions, $compress) = undef;

GetOptions(
    'watch|w'   => \$watch,
    'version|v' => \$ver,
    'host|t'    => \$host,
    'cpu|c'     => \$workload,
    'memory|m'  => \$memory,
    'net|n'     => \$net,
    'part|p'    => \$partitions,
    'help|h'    => \$help,
    'doc|d'     => \$doc,
    'compress'  => \$compress,

);

if ( $compress ) {
	$width = 3;
} else {
	$width = 15;
}

&pod2usage(1) if ( not defined($doc) and $help );
&pod2usage(
    -exitstatus => 0,
    -verbose    => 2
) if $doc;



# re-exec ourself within watch
if ($watch) {
    my $t = shift || 1;
    exec( 'nice', 'watch', '-tn', $t, $^X, $0 );
}

my $lnx = Sys::Statistics::Linux->new();
#    Processes => {
#        init => 1,
#        pids => [ 1, 2, 3, 4 ]
#    }
#);

$lnx->set(
    SysInfo   => 1,
    CpuStats  => 1,
    ProcStats => 0,
    MemStats  => 1,
    NetStats  => 0,
    SockStats => 0,
    DiskStats => 0,
    DiskUsage => 1,
    LoadAVG   => 1,
    FileStats => 0,
    Processes => 0,
);

my $stats = $lnx->get;

# decide what we want to show...

if ( !( $ver || $host || $workload || $memory || $net || $partitions ) ) {

    &info_version;
    &info_host;
    &info_workload;
    &info_memory;
    &info_publicip;
    &info_net;
    &info_fs;
    exit 0;

}
else {

    &info_version  if $ver;
    &info_host     if $host;
    &info_workload if $workload;
    &info_memory   if $memory;
    &info_publicip if $net;
    &info_net      if $net;
    &info_fs       if $partitions;
    exit 0;

}

sub info_version {
    if ($ver) {
    print 'sysinfo.pl v.', $version,
      ' Copyright (C) 2006-2014 Dan Reidy <dubkat@gmail.com>', "\n";
    print '$Id$', "\n\n";
    print <<LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

LICENSE
    }

}

sub curl_publicip {
    my $publicIp = qx[ curl --connect-timeout 1 -fs ip.appspot.com ];
    $publicIp ||= "<unknown>";
    chomp $publicIp;
    return $publicIp;
}

sub info_publicip {
     printf "%-*s %s\n", $width, 'Public IP:', &curl_publicip;
     return;
}

sub info_host {
    printf "%-*s %s.%s (%s %s)\n", $width, 'Hostname:',
      $stats->{SysInfo}->{hostname}, $stats->{SysInfo}->{domain},
      $stats->{SysInfo}->{kernel},   $stats->{SysInfo}->{release};
    printf "%-*s %s\n", $width, 'Distro:', mydistro() if mydistro();
    printf "%-*s %s", $width, 'Date:', join " ",
      $lnx->gettime('%A %b %d %Y %T %Z'), "\n";
    printf "%-*s %s\n", $width, 'Uptime:', $stats->{SysInfo}->{uptime};
    return;
}

sub info_workload {
    my ( $mhz, $vendor, $model, $entropy, $pool ) = undef;
    open( PROC, '</proc/cpuinfo' ) || die("Cannot read from /proc/cpuinfo");
    while (<PROC>) {
        $vendor = $1 if $_ =~ m/vendor_id\s*:\s*(.+)/;
        $model  = $1 if $_ =~ m/model\sname\s*:\s*(.+)/;
        $mhz    = $1 if $_ =~ m/cpu MHz\s*:\s*(.+)/i;
    }
    close(PROC);

    open( PROC, '</proc/sys/kernel/random/entropy_avail');
    $entropy = <PROC>;
    close PROC;
    open( PROC, '</proc/sys/kernel/random/poolsize');
    $pool = <PROC>;
    close PROC;
        if ( $vendor && $model && $mhz ) {
        $vendor =~ s/\s+/ /g;
        $model  =~ s/\s+/ /g;
        printf "%-*s %s %s %dMHz\n", 
        $width, 'Processor:', $vendor, $model, $mhz;
    }
    printf "%-*s %-5s %d %-5s %d\n", $width, 'Encryption:', 'Entropy:', $entropy,
    'Poolsize:', $pool;
    printf "%-*s %-5s %-5s %-5s \n", $width, 'Load Average:',
      $stats->{LoadAVG}->{avg_1}, $stats->{LoadAVG}->{avg_5},
      $stats->{LoadAVG}->{avg_15};

    printf "%-*s user: %-6s  nice: %-6s  system: %-6s idle: %-6s\n", $width,
      'CPU Use:', $stats->{CpuStats}->{cpu}->{user},
      $stats->{CpuStats}->{cpu}->{nice}, $stats->{CpuStats}->{cpu}->{system},
      $stats->{CpuStats}->{cpu}->{idle};
}

sub info_memory {
    printf "%-*s total: %-7s used: %-7s free: %-7s in_use: %-3s%%\n", $width,
      'Memory:', makehuman( $stats->{MemStats}->{memtotal} ),
      makehuman( $stats->{MemStats}->{memused} -
          $stats->{MemStats}->{buffers} -
          $stats->{MemStats}->{cached} ),
      makehuman( $stats->{MemStats}->{realfree} ),
      int(
        (
            (
                $stats->{MemStats}->{memused} -
                  $stats->{MemStats}->{buffers} -
                  $stats->{MemStats}->{cached}
            ) * 100
        ) / $stats->{MemStats}->{memtotal}
      );

    # print the swap info as if it is memory
    unless ($show_swap_with_fs) {
        printf "%-*s total: %-7s used: %-7s free: %-7s in_use: %-3s%%\n",
          $width, 'Swap:', makehuman( $stats->{MemStats}->{swaptotal} ),
          makehuman( $stats->{MemStats}->{swapused} ),
          makehuman( $stats->{MemStats}->{swapfree} ),
          floor $stats->{MemStats}->{swapusedper};
    }
}

sub info_net {
    my @net = qx(cat /proc/net/dev);
    printf "%-*s ", $width, 'Network:';
    foreach (@net) {
        next if $_ =~ m/^Inter|^\s*face|^\s*lo:/;
        if (
            m/
			\s*(\S+):\s*
			(\d+)\s*
			\d+\s*
			\d+\s*
			\d+\s*
			\d+\s*
			\d+\s*
			\d+\s*
			\d+\s*
			(\d+)
			/x
          )
        {
            next if ( $2 == 0 && $3 == 0 ); #hide devices that show no traffic
            printf "%s > %s > %s   ", makehuman( $2 / 1024 ), $1,
              makehuman( $3 / 1024 );
        }
    }
    print "\n";
}

sub info_fs {

    # which partition has the longest name and adjust table accordingly.
    my $l = 0;
    my $i = 0;
    if ( $compress ) {
    	$l = $width;
    } else {
    	foreach ( keys %{ $stats->{DiskUsage} } ) {
    		next if ( $_ =~ m/:/ );
        	$l = length $_ if length $_ > $l;
    	}
    }
    my ( $totalavail, $totalused, $totalfree, $totalusedper ) = 0;
    
    unless ( $compress ) {
    	printf "%-*s %-*s %-*s %8s %8s %8s %3%\n", $width, 'Filesystems:', $l,
      	'Partition', 8, 'Mount', 'Total', 'Used', 'Free';
    } else {
    	printf "%-*s\n", $width, 'Filesystems:';
    }
    
    foreach my $fs ( sort keys %{ $stats->{DiskUsage} } ) {

        $totalavail += $stats->{DiskUsage}->{$fs}->{total}
          unless ( $hide_nfs and $fs =~ m/:/ );
        $totalused += $stats->{DiskUsage}->{$fs}->{usage}
          unless ( $hide_nfs and $fs =~ m/:/ );
        $totalfree += $stats->{DiskUsage}->{$fs}->{free}
          unless ( $hide_nfs and $fs =~ m/:/ );
        $totalusedper += $stats->{DiskUsage}->{$fs}->{usageper}
          unless ( $hide_nfs and $fs =~ m/:/ );

        printf(
            "%-*s %-*s %-*s %8s %8s %8s %3d%% ",
            $width,
            '',
            $l,
            $fs,
            8,
            $stats->{DiskUsage}->{$fs}->{mountpoint},
            makehuman( $stats->{DiskUsage}->{$fs}->{total} ),
            makehuman( $stats->{DiskUsage}->{$fs}->{usage} ),
            makehuman( $stats->{DiskUsage}->{$fs}->{free} ),
            $stats->{DiskUsage}->{$fs}->{usageper}
        ) unless ( $fs =~ m/:/ );
        
        # show nfs can be outragously long depending on settings
        # so lets make it more reasonable
        # TODO '--->'
        if ( !$hide_nfs && $fs =~ m/:/ ) {
        	# NFS mount points
        	printf "%-*s %-*s %8s\n", $width, '', $l, $fs, 
        	$stats->{DiskUsage}->{$fs}->{mountpoint};
        	# NFS Space
        	printf "%-*s `->%*s %*s %8s %8s %8s %3d%%", $width, '', $l-3, '', 8, '',
        	makehuman( $stats->{DiskUsage}->{$fs}->{total} ),
        	makehuman( $stats->{DiskUsage}->{$fs}->{usage} ),
        	makehuman( $stats->{DiskUsage}->{$fs}->{free} ),
        	$stats->{DiskUsage}->{$fs}->{usageper};
        }

        #only root may see the next section. (CRYPTFS)
        if ( ( dirname($fs) eq '/dev/mapper' ) && $showcrypt && $< == 0 ) {
            my ( $d, $c, $k ) = cryptinfo($fs);
            printf "[%s on %s]", $c, $d;
        }
        print "\n" unless ( $hide_nfs and $fs =~ m/:/ );
    }

    # print the swap info so it appears nicely with the rest of our filesystems.
    if ($show_swap_with_fs) {
        printf "%-*s %-*s %-*s %8s %8s %8s %3s%%\n", $width, '', $l, 'none', 5,
          'swap', makehuman( $stats->{MemStats}->{swaptotal} ),
          makehuman( $stats->{MemStats}->{swapused} ),
          makehuman( $stats->{MemStats}->{swapfree} ),
          floor $stats->{MemStats}->{swapusedper};
    }

    # print the total available for *
    my $avg = int( ( $totalused * 100 ) / $totalavail );
    printf "%-*s %-*s %-*s %8s %8s %8s %3d%%\n", $width, '', $l, 'TOTALS', 8,
      '-----', makehuman($totalavail), makehuman($totalused),
      makehuman($totalfree), $avg;
}

sub cryptinfo {
	use File::Glob ':glob';
    my $map = shift;
    my ( $cipher, $keysize, $device );
    return "" unless ( dirname($map) eq '/dev/mapper' );
	my $cryptsetup = (</*/cryptsetup>)[0];
	return "unknown" unless $cryptsetup && -x $cryptsetup;
	$map = basename($map);
    my @cdata = qx[$cryptsetup status $map ] || die($!);
    foreach (@cdata) {
        $cipher  = $1 if ( $_ =~ m/cipher:\s*(\S+)/ );
        $keysize = $1 if ( $_ =~ m/keysize:\s*(\d+)/ );
        $device  = $1 if ( $_ =~ m/device:\s*(\S+)/ );
    }
    $cipher =~ s/:.+//;
    return ( $device, $cipher, $keysize );
}

sub mydistro {
    my $distro  = undef;
    my @release;
    if ( -x "/usr/bin/lsb_release" ) {
	my $i = qx[/usr/bin/lsb_release -si];
	my $r = qx[/usr/bin/lsb_release -sr];
	chomp $i;
	chomp $r;
	$distro = sprintf("%s %s", $i, $r);
    }
    else {
    	@release = glob('/etc/*-release');
        foreach my $r (@release) {
        	next if -l $r;
        	next unless -f $r;
        	$distro = qx[/usr/bin/head -n 1 $r];
        	chomp $distro;
	}
    }
    return $distro;
}

sub makehuman {
    my $in = shift;
    my $return;
    my ( $t, $g, $m, $k ) = ( 1024 * 1024 * 1024, 1024 * 1024, 1024, 1 );
    if ( $in >= $t ) {
        $in = sprintf( "%.2fT", $in / $t );
    }
    elsif ( $in >= $g ) {
        $in = sprintf( "%.2fG", $in / $g );
    }
    elsif ( $in >= $m ) {
        $in = sprintf( "%.2fM", $in / $m );
    }
    elsif ( $in >= $k ) {
        $in = sprintf( "%.2fK", $in / $k );
    }
    else {
        $in = sprintf( "%.2fB", $in );
    }
    return $in;
}

__END__

=head1 NAME

sysinfo - Just Another Perl System Information Script!

=head1 DESCRIPTION

Prints out nifty and important system information.

=head1 SYNOPSIS

sysinfo [options]

=head1 REQUIRED MODULES

=over 4

=item o B<Sys::Statistics::Linux>

Install from CPAN (available in portage for you Gentoo users!).

=item o B<Getopt::Long>

Likely included with your distribution's perl.

=item o B<Pod::Usage>

Likely included with your distribution's perl.

=item o B<File::Basename>

Likely included with your distribution's perl.

=item o B<POSIX>

Likely included with your distribution's perl.

=head1 TIPS

o Running B<sysinfo> with no flags will output all possible information (except help).

o Running B<sysinfo> with the -w or --watch flags will allow you to keep a constant eye on things!

=head1 OPTIONS

=item B<-h|--help>

Brief usage help.

=item B<-d|--doc>

View full, formatted documentation. similar to issuing `perldoc /path/to/sysinfo`

=item B<-v|--version>

Print the standard version information you would expect to see.

=item B<-w|--watch>

Runs sysinfo within the `watch` program, allowing you to continually monitor your system.
You can optionally follow the --watch flag with an update value. This value defaults to '1'
if it is not specified. Use CONTROL+C to exit out of this mode.

EXAMPLE: `sysinfo -w 0.1` (Give's you pretty close to 'real time' statistics).

NOTE: Watch will be executed 'nice'ly.

=item B<-t|--host>

Show only basic information about this machine, such as hostname, distro, and uptime.

=item B<-c|--cpu>

Show only information relitive to the processor. Make/Model, Load Averages, and User/System/Nice/Idle breakdown.

=item B<-m|--memory>

Show only how much memory is in use, and free. (does not include swap info unless that option is activated at the begining of this script).

=item B<-n|--net>

Show only the network statistics.

=item B<-p|--part>

Show detailed partition information, similar to viewing `df` output.

=head1 BUGS

If you find any bugs or have any feature requests, email the author with 'SYSINFO' in the subject,
or contact dubkat on the B<EFnet> or B<IRCsource> IRC Networks.

=head1 AUTHORS

Dan Reidy <dubkat@gmail.com>

=head1 LICENSE

$Id$

Copyright (C) 2007 Dan Reidy <dubkat@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.


This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut

