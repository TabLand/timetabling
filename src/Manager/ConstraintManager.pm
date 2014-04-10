#!/usr/bin/perl
package ConstraintManager;
use strict;
use warnings;
use Module;
use XML::LibXML qw( );

sub new{
	my ($class) = @_;
	my $self = {
		_constraints => {}
	};
	bless $self, $class;
	return $self;
}
sub parseXML{
	die "implement this for each type of constraint";
}
sub add{
	my ($self, $constraint) = @_;
	$self->{_constraints}{$constraint->get_id()} = $constraint;
}
sub remove{
	my ($self, $constraint) = @_;
	delete $self->{_constraints}{$constraint->get_id()};
}
sub get_all_constraints{
	my $self;
	return values $self->{_constraints};
}
sub get_sum_penalty{
	my $self = shift;
	my $sum = 0;
	my @constraints = $self->get_all_constraints();
	for my $constraint (@constraint){
		$sum += $constraint->get_penalty();
	}
}
