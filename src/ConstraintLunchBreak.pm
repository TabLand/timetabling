#!/usr/bin/perl
package ConstraintLunchBreak;
use strict;
use warnings;
use parent "Constraint";

sub new{
	my ($class, $person, $penalty, $time_period) = @_;
	my $self = {
		_person=>$person,
		_penalty=>$penalty,
		_time_period=>$time_period
	};
	bless $self, $class;
	return $self;
}
sub get_person{
	my $self = shift;
	return $self->{_person};
}
sub get_penalty{
	my $self = shift;
	return $self->{_penalty} * $self->met();
}
sub get_time_period{
	my ($self) = @_;
	return $self->{_time_period};
}
sub met{
	my $self = shift;
	my $commitments = $self->get_activities_during_lunchtime();
	my @break_durations =  $self->get_minutes_between_activities($commitments);

	my $met = 0;
	for my $duration (@break_durations){
		if($duration>= $self->get_min_lunch_break_length()){
			$met = 1;
			last;
		}
	}
	return $met;
}
sub get_min_lunch_break_length(){
	#TODO Make this customizable
	return 60;
}
sub get_activities_during_lunchtime{
	my $self = shift;
	my $person = $self->get_person();
	my $schedule = $person->get_schedule();
	my $lunch_activities = $schedule->get_between($self->get_time_period());
	return $lunch_activities;
}
sub get_minutes_between_activities{
	my ($self, $schedule) = @_;
	my @sorted = $schedule->get_sorted_activities();
	
	my $first = $self->get_time_period()->get_start();
	my $last = $self->get_time_period()->get_end();

	my @minute_diff = ();

	if(@sorted>0){
		my $first_activity_start = $sorted[0]->get_timeslot()->get_start();
		my $last_activity_end = $sorted[-1]->get_timeslot()->get_end();
		push(@minute_diff,$first->minutes_to($first_activity_start));
		for(my $i = 0; $i < @sorted-1; $i++){
			my $start_break = $sorted[$i]->get_timeslot()->get_end();
			my $finish_break = $sorted[$i+1]->get_timeslot()->get_start();
			push(@minute_diff,$start_break->minutes_to($finish_break));
		}
		push(@minute_diff,$last_activity_end->minutes_to($last));
	} else{
		push(@minute_diff,$first->minutes_to($last));		
	}
	return @minute_diff;
}
sub get_clash_info{
	my $self = shift;
	#TODO get the days that person cannot have lunch
	my $days = "";
	my $person = $self->get_person();
	
	my $role = "";
	if($self->met()){
		my $return = "Person $person has no problems having lunch";
	}
	else {
		my $return = "Person $person cannot have lunch due to commitments";
	}
}
sub get_type{
	return "ConstraintLunchBreak";
}
1;
