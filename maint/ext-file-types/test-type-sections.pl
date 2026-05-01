#!/usr/bin/perl

use strict;

my $usage = "Usage: $0 <path_to_extensions_ini_file> <path_to_sample_files_dir>\n";
my $extensions_ini_file = $ARGV[0] || die $usage;
my $sample_files_dir = $ARGV[1] || die $usage;

open my $fh, '<', $extensions_ini_file or die "Could not open file '$extensions_ini_file' $!";
my $current_section;
my %section_type;
my %section_ignore_case;

while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /^\s*\[([^\]]+)\]\s*$/) {
        $current_section = "$1";
    } elsif (defined($current_section) && $line =~ /^\s*TypeIgnoreCase\s*=\s*(.+)\s*$/i) {
        $section_ignore_case{$current_section} = ($1 =~ /^\s*true\s*$/i) ? 1 : 0;
    } elsif (defined($current_section) && $line =~ /^\s*type\s*=\s*(.+)\s*$/i) {
        $section_type{$current_section} = $1;
    }
}

close $fh;

my $no_matches = 0;
my $no_failures = 0;

for my $section (keys %section_type) {
    my $type_regexp = $section_type{$section};
    my $type_ignore_case = $section_ignore_case{$section} // 0;
    my $sample_file_path = "$sample_files_dir/$section";

    if (! -e $sample_file_path) {
        print "$section: sample is missing!\n";
        $no_failures++;
        next;
    }

    my $file_output = `file -z -b -L -S "$sample_file_path" 2>/dev/null`;

    chomp $file_output;

    if ($file_output =~ /^ERROR:/) {
        $file_output = `file -b -L -S "$sample_file_path" 2>/dev/null`;
        chomp $file_output;
    }

    $type_regexp =~ s/\\\\/\\/g;

    # Check if the sample file matches the type regexp
    if ($type_ignore_case ? $file_output =~ /$type_regexp/i : $file_output =~ /$type_regexp/) {
        $no_matches++;
    } else {
        print "$section: regexp /$type_regexp/" . ($type_ignore_case ? "i" : "") . " does not match \"$file_output\"\n";
        $no_failures++;
    }
}

if ($no_failures > 0) {
    print "\nTotal failures: $no_failures, Total matches: $no_matches\n";
    exit 1;
} else {
    print "\nAll tests passed successfully.\n";
    exit 0;
}
