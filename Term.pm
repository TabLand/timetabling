#!/usr/bin/perl
package Term;
use strict;
use warnings;

sub number{
	my $term = substr (shift, 5, 1);
	return ($term + 0);
}
sub pretty{
	my $term = shift;
	return "Term $term";
}
1;
