#!/usr/bin/perl
package ConstraintCapacity;
use strict;
use warnings;
use parent "Constraint";

sub new{
	my ($class, $room, $penalty) = @_;
	my $self = {
		_room=>$room,
		_penalty=>$penalty};

	bless $self, $class;
	return $self;
}
sub get_room{
	my $self = shift;
	return $self->{_room};
}
sub get_penalty{
	my $self = shift;
	my $penalty = $self->{_penalty};
	my @capacity_diffs = $self->get_capacity_diffs();
	#under capacity activities are penalised at a rate of 0.5
	my $penalty_rate = 0.5;
	my $sum = 0;
	for(my $i = 0; $i<@capacity_diffs; $i++){
		if($capacity_diffs[$i] <0){
			$sum += -$penalty_rate * $capacity_diffs[$i];
		}
		else {
			$sum += $capacity_diffs[$i];
		}
	}
	return $sum * $penalty;
}
sub met{
	my $self = shift;
	my @capacity_diffs = $self->get_capacity_diffs();
	my $in_capacity = 1;
	for my $capacity_diff (@capacity_diffs){
		if($capacity_diff>0){
			$in_capacity = 0;
			last;
		}
	}
	return $in_capacity;
}
#under_capacity activities become negative, over_capacity become positive
sub get_capacity_diffs{
	my $self = shift;
	my @activity_capacities = $self->get_activity_capacities();
	my $room_capacity = $self->get_room()->get_capacity();
	for(my $i = 0; $i<@activity_capacities; $i++){
		$activity_capacities[$i] -= $room_capacity;
	}
	return @activity_capacities;
}
sub get_activity_capacities{
	my $self = shift;
	my @activities = $self->get_room()->get_schedule()->get_activities();
	my @actual_capacities = ();
	for my $activity (@activities){
		my $num_students = $activity->get_student_numbers();
		my $num_staff = $activity->get_staff_numbers();
		my $total_num = $num_staff + $num_students;
		push(@actual_capacities, $total_num);
	}
	return @actual_capacities;
}
sub get_clash_info{
	my $self = shift;
	#TODO move following todo to ConstraintPersonOverbook - inheritance..
	#TODO figure out a way to grab person role from Activity, when potentially, a person could be a student in some activities and a staff in others
	if($self->met()){
		my $return = "Room is within capacity";
	}
	else {
		my $return = "Room is over capacity";
	}
}
sub get_type{
	return "ConstraintLunchBreak";
}
1;
