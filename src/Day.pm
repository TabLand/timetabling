#!/usr/bin/perl
package Day;
use strict;
use warnings;

sub number{
	my $day = substr shift, 0, 3;
	if($day eq "Sun") {0;}
	elsif($day eq "Mon") {1}
	elsif($day eq "Tue") {2}
	elsif($day eq "Wed") {3}
	elsif($day eq "Thu") {4}
	elsif($day eq "Fri") {5}
	elsif($day eq "Sat") {6}
	elsif($day eq "Nod") {-1}
}
sub pretty{
	my $day = shift;
	my @days = ("Noday","Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday");
	$days[$day+1];
}
1;
