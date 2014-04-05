#!/usr/bin/perl
package ConstraintPersonClash;
use strict;
use warnings;
use parent "Constraint";

sub new{
	my ($class, $person, $penalty) = @_;
	my $self = {
		_person=>$person,
		_penalty=>$penalty};

	bless $self, $class;
	return $self;
}
sub get_person{
	my $self = shift;
	return $self->{_person};
}
sub get_penalty{
	#return only if met?
	my $self = shift;
	return $self->{_penalty};
}
sub set_penalty{
	my ($self, $penalty) = @_;
	$self->{_penalty} = $penalty;
}
sub met{
	my $self = shift;
	my $clashes = $self->get_clashes();
	if($clashes->get_activity_numbers()==0) {1}
	else {0}
}
sub get_clashes{
	my $self = shift;
	my $schedule = $self->get_person()->get_schedule();
	return $schedule->get_clashes();
}
sub get_clash_info{
	my $self = shift;
	my $clashes = $self->get_clashes();
	my $person = $self->get_person();
	#TODO figure out a way to grab person role from Activity, when potentially, a person could be a student in some activities and a staff in others
	my $role = "";
	if($self->met()){
		my $return = "No clashes to report for person $person";
	}
	else {
		my $return = "Person $person expected to be in two places at once, with role $role, activity dump $clashes";
	}
}
1;
