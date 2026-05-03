#!/usr/bin/perl

use strict;
use File::Basename;

my $script_dir = dirname($0);
my $project_root = "$script_dir/../..";

my $extensions_ini_file = $ARGV[0] // "$project_root/misc/mc.ext.ini";

open my $fh, '<', $extensions_ini_file or die "Could not open file '$extensions_ini_file' $!";
my $current_section;

while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /^\s*\[([^\]]+)\]\s*$/) {
        $current_section = "$1";
    } elsif (defined($current_section) && $line =~ /^\s*type\s*=\s*\S+/i) {
        print "$current_section\n";
    }
}

close $fh;
