#!/usr/bin/perl
package Constraint;
use strict;
use warnings;

sub new{
	die "Supposed to be called from child class";
}
sub met{
	die "Supposed to be called from child class";
}
sub get_penalty{
	die "Supposed to be called from child class";
}
sub get_clashes{
	die "Supposed to be called from child class";
}
sub get_clash_info{
	die "Supposed to be called from child class";
}
sub set_penalty{
	my ($self, $penalty) = @_;
	$self->{_penalty} = $penalty;
}
sub get_type{
	die "I'm a constraint, but you shouldn't be calling this method";
}
sub get_id{
	die "Mother of all constraints";
}
1;
