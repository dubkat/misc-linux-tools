#!/usr/bin/perl

#^^^ This should point to your system's perl, or which ever
#    custom perl you may have installed. Usually /usr/bin/perl
#
#       AUTHOR: Dan Reidy (dubkat), dubkat@gmail.com
#     HOMEPAGE: http://google.com/+DanReidy
#    MORE INFO: https://github.com/dubkat/misc-linux-tools
#      CREATED: 2015-07-24
#      LICENSE: GPL-2
#
# Perl Critic Level: 3
#
# Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS'
# AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED
# BY YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE
# USE OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# do we have any common sense?
use if eval { require common::sense } == 1, "common::sense";
use if eval { require common::sense } == 0, "strict";
use if eval { require common::sense } == 0, "warnings";
use Carp;
use feature qw(say);
use version; our $VERSION = 'v16.07.06';
use Image::ExifTool qw(:Public);
use HTTP::Date;
use Env qw(HOME);
use constant { TRUE => 1, FALSE => 0 };
my $root_path = shift @ARGV;
my $seq = sprintf("%000d",0);
my $custom_dir = FALSE;
my $output_dir;

$output_dir = shift @ARGV;
if ( defined($output_dir) ) {
    $custom_dir = TRUE;
} else {
    $output_dir = $ENV{'HOME'} ."/Pictures/sorted";
}

# if we want to make directories for year
my $group_by_year = TRUE;
# auto delete camera generated thumnails.
my $delete_thumbs = TRUE;

sub file_processor {
  my $in_file = shift;

  # if it's a camera thumbnail, handle it as requested.
  if ($in_file =~ m/\.THM$/x) {
    if ($delete_thumbs) {
      unlink $in_file;
    }
    return;
  }

  # skip over any file in the camera that we ourselves dont specifically handle.
  if ( $in_file !~ m/\.(jpe?g|png|tiff?|webm|webp|mkv|mp4|mov|3gp)$/ix ) {
    return;
  }

  # whatever's left should be for us.

  say "Processing file: $_";
  # lets look up it's exif data.
  my $year;
  my $output = $output_dir;
  my $info = ImageInfo($_);
  my $create = $info->{'CreateDate'};
  my $type = lc $info->{'FileType'};
  if ( $type eq "jpeg" ) {
    $type = "jpg";
  }

  if ( $type =~ m/mov|3gp|m4v|m4a/x ) {
      $type = 'mp4';
  }
  my ($date,$time) = split / +/, $create;
  # lets stop modifying timestamps. most OS's should be able to handle it.
  #$time =~ s/:/-/gx;
  $date =~ s/:/-/gx;
  my $stamp = str2time("$date $time");


  my ($sec,$min,$hour,$mday,$mon,$gyear,$wday,$yday,$isdst) = localtime($stamp);
  my $media_touch = sprintf "%04d-%02d-%02d %02d:%02d:%02d", $gyear+1900, $mon+1, $mday, $hour, $min, $sec;
  #print "DEBUG: stamp($stamp), media_touch($media_touch) \n";

  if ( $custom_dir == FALSE && $group_by_year == TRUE ) {
    ($year) = $date =~ (m/(^\d{4})/x);
    if ( ! -d "$output_dir/$year" ) {
      qx{ mkdir -p "$output_dir/$year" } && croak "Failed to create directory $output_dir/$year\n";
    }
    $output = "$output_dir/$year";
  }

  $create = sprintf("%s_%s", $date, $time);
  next if $create eq "_";
  my $edited = "";
  my $basename = sprintf("%s/%s", $output, $create);

  if ( $_ =~ m/\-edited|_lzn\./x ) {
    $edited = "-edited";
  }

  my $newfile = sprintf("%s%s.%s", $basename, $edited, $type);
  while ( -e $newfile ) {
    my $sequence = sprintf("%04d", $seq);
    my $new_basename = $basename ."-". $sequence;
    $newfile = sprintf("%s%s.%s", $new_basename, $edited, $type);
    $seq++;
  }
  $seq = 1;

  my $ret;
  if ( $_ =~ m/\.(jpe?g|png|tiff?|webp)$/ix ) {
      #printf("source: %s\ndest: %s\n\n", $_, $newfile);
      if ( lc($_) ne lc($newfile) ) {
          system("mv", "-v", $_, $newfile);
          $ret = $? >> 8;
          if ($ret != 0 ) {
              die("Return: $ret. Failed to move $_ to $newfile");
          }
      }
      system("touch", "-d", $media_touch, $newfile);
      $ret = $? >> 8;
      if ($ret != 0 ) {
          die("Return: $ret. Failed to touch $newfile with date '$media_touch'");
      }
      next;
  }

  #rename($_, $newfile);
  if ($_ !~ /\.mp4$/ix ) {
    my $vinfo = ImageInfo($_);
    my $vcodec = undef;
    my $acodec = undef;
    #require Data::Dumper;
    #print Dumper $info;

    if( $vinfo->{'CompressorID'} eq 'avc1' ) {
      #video is already mp4 compatable.
      $vcodec = "copy";
    } else {
      $vcodec = "libx264";
    }

    if ($vinfo->{'AudioFormat'} =~ /^aac|mp4a$/ix ) {
      $acodec = "copy";
    } else {
      $acodec = "aac";
    }
    system("ffmpeg", "-i", $_, "-metadata", "creation_time='$media_touch'", "-c:v", $vcodec, "-c:a", $acodec, $newfile);
    $ret = $? >> 8;
    if ($ret != 0 ) {
        die("Return: $ret. Failed to convert $_ to $newfile");
    }
    unlink $_;
    system("touch", "-d", $media_touch, $newfile);
    $ret = $? >> 8;
    if ($ret != 0 ) {
        die("Return: $ret. Failed to touch $newfile with date '$media_touch'");
    }

    next;
  }

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
    file_processor($_);
  }
}


if ( ! -d $root_path ) { croak "First arguement must be a directory."; }
if ( ! -d $output_dir ) {
  qx{mkdir -p $output_dir} || croak "Failed to create output directory.";
}

print "Attempting to open $root_path\n";
directory_processor($root_path);
