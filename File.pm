#!/usr/bin/perl
package File;
use strict;
use warnings;

sub read_from_file{
    my ($filename) = @_;
	my $filepath = get_full_path($filename);
	open(my $file, "<", $filepath) or die "Unable to open file $filepath for reading, $!";;
	my $text = join('', <$file>);
	close($file);
	return $text;
}
sub write_to_file{
	my ($filename, $content) = @_;
	my $filepath = get_full_path($filename);
	open(my $file, ">", $filepath) or die "Unable to open file $filepath for writing, $!";;
	print $file $content;
	close($file);
}

sub get_full_path{
	my ($filename) = shift;	
    my $working_directory  = `pwd`;
	my $full_filepath = $working_directory . "/" . $filename;
	$full_filepath =~ s/\n//g;
	return $full_filepath;
}
1;
