#!/usr/bin/perl

use strict;

my $extensions_ini_file = $ARGV[0] || die "Usage: $0 <path_to_extensions_ini_file>\n";

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
