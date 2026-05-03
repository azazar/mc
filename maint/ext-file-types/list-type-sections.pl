#!/usr/bin/perl

use strict;
use File::Basename;

my $extensions_ini_file = $ARGV[0] // dirname($0) . '/../../misc/mc.ext.ini';

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
