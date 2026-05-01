#!/usr/bin/perl

use strict;

sub tsv_escape {
    my ($text) = @_;

    $text =~ s/\\/\\\\/g;
    $text =~ s/\t/\\t/g;
    $text =~ s/\n/\\n/g;
    $text =~ s/\r/\\r/g;
    $text =~ s/([\x00-\x08\x0b\x0c\x0e-\x1f])/sprintf('\\x%02x', ord($1))/ge;

    return $text;
}

die "Usage: $0 <output_file_name_without_extension>\n" unless @ARGV == 1;

my $script_dir = $0;
$script_dir =~ s{[^/]+$}{};
$script_dir =~ s{/$}{};
$script_dir = '.' if $script_dir eq '';

my $samples_path = "$script_dir/../tests/src/fixtures/filemanager/file-types/sample_files";
my $output_dir = "$script_dir/../tests/src/fixtures/filemanager/file-types/file_output";
my $output_name = $ARGV[0];
$output_name =~ s/[\/\:]/-/g;
my $output_path = "$output_dir/" . $output_name . '.tsv';

my %output_rows = ();

opendir(my $dh, $samples_path) || die "Can't open $samples_path: $!";
while (my $file = readdir $dh) {
    next if $file eq '.' || $file eq '..';
    
    my $input_file = "$samples_path/$file";
    my $command = "file -z -b -L -S \"$input_file\" 2>&1";
    my $output = `$command`;
    my $exit_code = $? >> 8;

    $output =~ s/\n.*//s;

    $output_rows{$file} = $output;
}
closedir $dh;

mkdir $output_dir unless -d $output_dir;

open(my $fh, '>', $output_path) or die "Could not open file '$output_path' $!";
foreach my $file (sort keys %output_rows)
{
    print $fh tsv_escape($file) . "\t" . tsv_escape($output_rows{$file}) . "\n";
}
close $fh;
