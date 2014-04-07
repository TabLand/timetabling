#!/usr/bin/perl
package ConstraintOverbook;
use strict;
use warnings;
use parent "Constraint";

sub new{
	my ($class, $resource, $penalty) = @_;
	my $self = {
		_resource=>$resource,
		_penalty=>$penalty};

	bless $self, $class;
	return $self;
}
sub get_resource{
	my $self = shift;
	return $self->{_resource};
}
sub get_penalty{
	my $self = shift;
	return ($self->{_penalty} * $self->get_clash_numbers());
}
sub met{
	my $self = shift;
	if($self->get_clash_numbers()==0) {1}
	else {0}
}
sub get_clash_numbers{
	my $self = shift;
	my $clashes = $self->get_clashes();
	return $clashes->get_activity_numbers();
}
sub get_clashes{
	my $self = shift;
	my $schedule = $self->get_resource()->get_schedule();
	return $schedule->get_clashes();
}
sub get_clash_info{
	my $self = shift;
	my $clashes = $self->get_clashes();
	my $resource = $self->get_resource();
	#TODO move following todo to ConstraintPersonOverbook - inheritance..
	#TODO figure out a way to grab person role from Activity, when potentially, a person could be a student in some activities and a staff in others
	my $role = "";
	if($self->met()){
		my $return = "No clashes to report for resource $resource";
	}
	else {
		my $return = "resource $resource overbooked, activity dump $clashes";
	}
}
1;
