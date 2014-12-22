#!/usr/bin/env perl

#===============================================================================
#
#         FILE: crypt-df.pl
#
#        USAGE: ./crypt-df.pl  [options]
#
#  DESCRIPTION: A wrapper around the df command that also shows cryptsetup info.
#
#      OPTIONS: any option's that your system df accepts
#
# REQUIREMENTS: cryptsetup
#
#         BUGS: hopefully not.
#
#        NOTES: If this script is somewhere in your path, read the output from
#               perldoc crypt-df.pl
#
#       AUTHOR: Dan Reidy (dubkat), dubkat@gmail.com
#
#     HOMEPAGE: http://google.com/+DanReidy
#
#    MORE INFO: http://misc-linux-tools.googlecode.com/
#
#      VERSION: 1.0
#
#      CREATED: 12/14/2014 03:14:25 PM
#
#     REVISION: $Id$
#
#      LICENSE: Artistic 2.0 / GPL-2
#===============================================================================


# Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS' 
# AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED 
# BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE 
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE 
# USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# enable this option if you're on a single-user machine and you are in the sudoers.
my $use_sudo = 0;




# Stop Editing
# Stop Editing
# Stop Editing
#########################################################################################################

BEGIN {
	my $e=0;

	# prefer common sense over strict and warnings
	eval "common::sense;";
	$e=1 if ($@);

	use if $e, strict;
	use if $e, warnings;
	require utf8;
}



my $df="/bin/df";

my %data;
my @data;

my $count;
my @header;
my $ldev = 0;
my $lmnt = 0;


sub cryptinfo {
	my $id = shift;
	my $dev = $data{$id}->{'dev'};
	my $sudo;
	
	$sudo = '/usr/bin/sudo' if $use_sudo;

	my @data = qx($sudo /sbin/cryptsetup status $dev 2>/dev/null);
	chomp @data;
	if ( @data ) {
		foreach my $line (@data) {
			if ( $line =~ /type:\s+(\S+)/ ) {
				$data{$id}->{'cr_type'} = $1;
			}
			if ( $line =~ /cipher:\s+(\S+)/ ) {
				$data{$id}->{'cr_cipher'} = $1;
			}
			if ( $line =~ /device:\s+(\S+)/ ) {
				$data{$id}->{'cr_realdev'} = $1;
			}
			if ( $line =~ /keysize:\s+(.+)/ ) {
				$data{$id}->{'cr_keysize'} = $1;
			}
		}

		return;
	}
	#$data{$id}->{'cr_type'} = 'null';
	#$data{$id}->{'cr_cipher'} = 'null';
	
	
	
}


@data = qx($df @ARGV);
chomp @data;
$count = @data;

for (my $i=0; $i < $count; $i++) {
	my $line = shift @data;
	if ( $i == 0 ) {
		foreach (split # +#,$line) {
			next if $_ =~ /^on$/;
			push @header, $_;
		}
		next;
	}
	
	my @new = split # +#, $line;
	$data{$i} = {
		'dev' => $new[0],
		'typ' => $new[1],
		'sz'  => $new[2],
		'uz'  => $new[3],
		'av'  => $new[4],
		'ct'  => $new[5],
		'mnt' => $new[6],
		'cr_type' => undef,
		'cr_cipher' => undef,
		'cr_realdev' => undef,
		'cr_keysize' => undef
	};
	cryptinfo($i);
}

foreach my $key (keys %data) {
	if ( length $data{$key}->{'dev'} >= $ldev ) {
		$ldev = length $data{$key}->{'dev'};
	}
	if ( length $data{$key}->{'mnt'} >= $lmnt ) {
		$lmnt = length $data{$key}->{'mnt'};
	}
}

# print header
printf(
	"%-*s %6s %6s %5s %5s %4s %s %*s:%s\n",
	$ldev, $header[0],$header[1], $header[2], $header[3],
	$header[4],$header[5], $header[6], $lmnt, "Type", "Cipher"
);


# print data
foreach my $key (sort keys %data) {
	if ( $data{$key}->{'cr_type'} ) {
		printf(
			"%-*s %6s %6s %5s %5s %4s %s %*s:%s\n",
			$ldev	, $data{$key}->{'dev'}, $data{$key}->{'typ'},
			$data{$key}->{'sz'}, $data{$key}->{'uz'}, 
			$data{$key}->{'av'}, $data{$key}->{'ct'},
			$data{$key}->{'mnt'}, 
			$lmnt - length($data{$key}->{'cr_type'}),
			$data{$key}->{'cr_type'}, $data{$key}->{'cr_cipher'}
		);
		next;
	}
	printf(
		"%-*s %6s %6s %5s %5s %4s %s\n",
		$ldev	, $data{$key}->{'dev'}, $data{$key}->{'typ'},
		$data{$key}->{'sz'}, $data{$key}->{'uz'}, 
		$data{$key}->{'av'}, $data{$key}->{'ct'},
		$data{$key}->{'mnt'}	
	);
}

__END__

=pod
 
=head1 NAME 

=over

crypt-df.pl

$Id$

=back

=head1 SYNOPSIS

=over

A wrapper script around the system df command to include cryptsetup information.

=back

=head1 OPTIONS

=over

This script passes any options it receives directly to the L<df(1)> command, with one exception.

Within the script, near the top, there is an option named $use_sudo. By default, it is set
to 0.  As a result, non-root users will not see extended information.  However, on a machine
such as your personal desktop/laptop/server/whatever where you are the primary user, you could
enable this options by setting it to $use_sudo=1;  The result is, the script will use the 
SUDO command to view cryptsetup information.

=back

=head1 USAGE

=over

Create an alias in either /etc/profile.d/ or your .bashrc to look something like this:
B<alias df="/usr/local/bin/crypt-df.pl -hTP">

=back


=head1 AUTHOR

=over

Dan Reidy <dubkat@gmail.com>

https://plus.google.com/+DanReidy

https://misc-linux-scripts.googlecode.com/

=back

=head1 LICENSE



=head2	Artistic License 2.0

=head3 Copyright (c) 2014, Dan Reidy

=over

Everyone is permitted to copy and distribute verbatim copies of this license document, 
but changing it is not allowed.

=back


=head2 Preamble

=over

This license establishes the terms under which a given free software Package may be copied, modified, distributed, and/or redistributed. The intent is that the Copyright Holder maintains some artistic control over the development of that Package while still keeping the Package available as open source and free software.

You are always permitted to make arrangements wholly outside of this license directly with the Copyright Holder of a given Package. If the terms of this license do not permit the full use that you propose to make of the Package, you should contact the Copyright Holder and seek a different licensing arrangement.

=back

=head2 Definitions

=over

=item

"Copyright Holder" means the individual(s) or organization(s) named in the copyright notice for the entire Package.

=item

"Contributor" means any party that has contributed code or other material to the Package, in accordance with the Copyright Holder's procedures.

=item

"You" and "your" means any person who would like to copy, distribute, or modify the Package.

=item

"Package" means the collection of files distributed by the Copyright Holder, and derivatives of that collection and/or of those files. A given Package may consist of either the Standard Version, or a Modified Version.

=item

"Distribute" means providing a copy of the Package or making it accessible to anyone else, or in the case of a company or organization, to others outside of your company or organization.

=item

"Distributor Fee" means any fee that you charge for Distributing this Package or providing support for this Package to another party. It does not mean licensing fees.

=item

"Standard Version" refers to the Package if it has not been modified, or has been modified only in ways explicitly requested by the Copyright Holder.

=item

"Modified Version" means the Package, if it has been changed, and such changes were not explicitly requested by the Copyright Holder.

=item

"Original License" means this Artistic License as Distributed with the Standard Version of the Package, in its current version or as it may be modified by The Perl Foundation in the future.

=item

"Source" form means the source code, documentation source, and configuration files for the Package.

=item

"Compiled" form means the compiled bytecode, object code, binary, or any other form resulting from mechanical transformation or translation of the Source form.

=back

=head2 Permission for Use and Modification Without Distribution

=over

(1) You are permitted to use the Standard Version and create and use Modified Versions for any purpose without restriction, provided that you do not Distribute the Modified Version.

Permissions for Redistribution of the Standard Version
(2) You may Distribute verbatim copies of the Source form of the Standard Version of this Package in any medium without restriction, either gratis or for a Distributor Fee, provided that you duplicate all of the original copyright notices and associated disclaimers. At your discretion, such verbatim copies may or may not include a Compiled form of the Package.

(3) You may apply any bug fixes, portability changes, and other modifications made available from the Copyright Holder. The resulting Package will still be considered the Standard Version, and as such will be subject to the Original License.

Distribution of Modified Versions of the Package as Source
(4) You may Distribute your Modified Version as Source (either gratis or for a Distributor Fee, and with or without a Compiled form of the Modified Version) provided that you clearly document how it differs from the Standard Version, including, but not limited to, documenting any non-standard features, executables, or modules, and provided that you do at least ONE of the following:

(a) make the Modified Version available to the Copyright Holder of the Standard Version, under the Original License, so that the Copyright Holder may include your modifications in the Standard Version.
(b) ensure that installation of your Modified Version does not prevent the user installing or running the Standard Version. In addition, the Modified Version must bear a name that is different from the name of the Standard Version.
(c) allow anyone who receives a copy of the Modified Version to make the Source form of the Modified Version available to others under
(i) the Original License or
(ii) a license that permits the licensee to freely copy, modify and redistribute the Modified Version using the same licensing terms that apply to the copy that the licensee received, and requires that the Source form of the Modified Version, and of any works derived from it, be made freely available in that license fees are prohibited but Distributor Fees are allowed.

Distribution of Compiled Forms of the Standard Version or Modified Versions without the Source
(5) You may Distribute Compiled forms of the Standard Version without the Source, provided that you include complete instructions on how to get the Source of the Standard Version. Such instructions must be valid at the time of your distribution. If these instructions, at any time while you are carrying out such distribution, become invalid, you must provide new instructions on demand or cease further distribution. If you provide valid instructions or cease distribution within thirty days after you become aware that the instructions are invalid, then you do not forfeit any of your rights under this license.

(6) You may Distribute a Modified Version in Compiled form without the Source, provided that you comply with Section 4 with respect to the Source of the Modified Version.

Aggregating or Linking the Package
(7) You may aggregate the Package (either the Standard Version or Modified Version) with other packages and Distribute the resulting aggregation provided that you do not charge a licensing fee for the Package. Distributor Fees are permitted, and licensing fees for other components in the aggregation are permitted. The terms of this license apply to the use and Distribution of the Standard or Modified Versions as included in the aggregation.

(8) You are permitted to link Modified and Standard Versions with other works, to embed the Package in a larger work of your own, or to build stand-alone binary or bytecode versions of applications that include the Package, and Distribute the result without restriction, provided the result does not expose a direct interface to the Package.

Items That are Not Considered Part of a Modified Version
(9) Works (including, but not limited to, modules and scripts) that merely extend or make use of the Package, do not, by themselves, cause the Package to be a Modified Version. In addition, such works are not considered parts of the Package itself, and are not subject to the terms of this license.

General Provisions
(10) Any use, modification, and distribution of the Standard or Modified Versions is governed by this Artistic License. By using, modifying or distributing the Package, you accept this license. Do not use, modify, or distribute the Package, if you do not accept this license.

(11) If your Modified Version has been derived from a Modified Version made by someone other than you, you are nevertheless required to ensure that your Modified Version complies with the requirements of this license.

(12) This license does not grant you the right to use any trademark, service mark, tradename, or logo of the Copyright Holder.

(13) This license includes the non-exclusive, worldwide, free-of-charge patent license to make, have made, use, offer to sell, sell, import and otherwise transfer the Package with respect to any patent claims licensable by the Copyright Holder that are necessarily infringed by the Package. If you institute patent litigation (including a cross-claim or counterclaim) against any party alleging that the Package constitutes direct or contributory patent infringement, then this Artistic License to you shall terminate on the date that such litigation is filed.

(14) B<Disclaimer of Warranty>: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=back

=cut
