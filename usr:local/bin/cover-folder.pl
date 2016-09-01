#!/usr/bin/env perl
#
# Locate cover files (cover.jpg) under your Music directory, and convert them
# into folder icons.
#
# Copyright (C) 2016 Dan Reidy <dubkat@gmail.com>
#  https://github.com/dubkat/misc-linux-tools
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



BEGIN {
    unless ( $^O eq 'linux' ) {
        die "* Sorry, This script currently only works on GNU/Linux.\n";
    }
    unless ( eval { require Image::Magick; } ) {
        warn "* The Image::Magick module is required.\n";
        $err++;
    }
    unless ( eval { require common::sense; } ) {
        warn "* The common::sense module is required (no, really... it is!).\n";
        $err++;
    }
    unless ( eval { require File::HomeDir; } ) {
        warn "* The File::HomeDir module is required.\n";
        $err++;
    }
    if ($err) {
        die "\n* Please install the modules required for this script via CPAN,\n"
        . "  or ask your system administrator to install them for you.\n";
    }

}

use common::sense;
use File::HomeDir;
use Image::Magick;

sub convert_cover {
    my $source = shift;
    my $dest;
    my $path;
    if ( $source =~ m#^(.+)/#ix ) {
        $path = $1;
    }
    if ( ! -d $path ) {
        die "$path is not a directory.";
    }
    $dest = "$path/.cover.png";
    if ( ! -e $dest ) {
        my $magick = new Image::Magick;
        $magick->Read($source); #|| die "Failed to read in $dest from I::M";
        $magick->Write($dest);  #|| die "Failed to write out $dest from I::M.";
    }
    if ( ! -f "$path/.directory" ) {
        open(my $fh, ">", "$path/.directory" );
        print $fh "[Desktop Entry]\nIcon=./.cover.png\n\n";
        close $fh;
        say "Wrote: $path/.directory";
    }
    say "Wrote: $dest";
}

sub directory_processor {
  my $path = shift;
  $path =~ s/\/$//;

  opendir (DIR, $path) or die "Unable to open $path: $!\n";
  my @files = grep { !/^\./ } readdir (DIR);
  closedir(DIR);
  # prepend the pathname to files.
  @files = map { $path . '/' . $_ } @files;

  for (@files) {
    if ( -d $_ ) {
      directory_processor($_);
      next;
    }
    if ( -f $_ && $_ =~ m/cover\.(jpe?g|gif|png)$/ix ) {
        say "Found cover: $_";
        convert_cover($_);
    }
  }
}

my $music = File::HomeDir->my_music // die "Cannot find your music directory.";
directory_processor($music);


__END__

=encoding utf8

=head1 NAME

B<cover-folder.pl> - Convert cover.jpg album cover art into folder icons.

=head1 DESCRIPTION

/home/user/Music/VNV Nation/cover.jpg is converted to a hidden PNG Image, and
a directory .desktop file is written to make the image the album's cover art for
that folder.

=head1 SYNOPSIS

There are no options, and no internal settings. just make sure
you're music directory is set correctly with XDG tools. If this shell command
returns correct results, you're in business.

C<xdg-user-dir MUSIC>

Simply run the script from whatever directory is convienent.

C<./cover-folder.pl>

=head1 REQUIRED MODULES

=over 4

=item * L<File::HomeDir>

    To automagically find your music directory.

=item * L<Image::Magick>

    To convert the cover art to a compatable image format. May be called PerlMagick.

=item * L<common::sense>

    Because everyone needs a little more of it in their lives.

=back

=head1 BUGS

Maybe... none ive seen. If so, open a ticket on https://github.com/dubkat/misc-linux-tools

=head1 AUTHORS

   Dan Reidy

   dubkat@gmail.com

   https://github.com/dubkat/misc-linux-tools

=head1 LICENSE

Copyright (C) 2016 Dan Reidy <dubkat@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.


This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
