#!/usr/bin/perl
package ActivityRequirement;
use strict;
use warnings;
use overload
    "\"\"" => \&to_string,
    "<=>"  => \&compare,
    "cmp"  => \&compare;

sub new{
	my ($class, $id, $module, $type, $group) = @_;

	my $self = {
        _id     => $id,
		_type   => $type,
		_group  => $group,
		_module => $module,
	};
	bless $self, $class;
	return $self;
}

sub get_id{
	my $self = shift;
    return $self->{_id};
}

sub get_type{
	my $self = shift;
	return $self->{_type};
}

sub get_group{
	my $self = shift;
	return $self->{_group};
}

sub get_module{
	my $self = shift;
	return $self->{_module};
}

sub get_student_numbers{
  	#TODO IMPLEMENT IT!
}

sub get_staff_numbers{
  	#TODO IMPLEMENT IT!
}

sub get_person_numbers{
  	#TODO IMPLEMENT IT!
}

sub exists_student{
	my ($self, $student) = @_;
  	#TODO IMPLEMENT IT!
}
sub exists_staff{
	my ($self, $staff) = @_;
  	#TODO IMPLEMENT IT!
}
sub equals{
	my ($first, $second) = @_;
    my $same_id          = $first->{_id} == $second->{_id};
	return $same_id;
}
sub to_string{
	my $self   = shift;

	my $module = $self->get_module();
	my $group  = $self->get_group();
	my $type   = $self->get_type();
	my $id     = $self->get_id();

	return "Activity($id:$module:$group:$type)";
}
sub compare{
	my ($first, $second) = @_;
	my $first_ts = $first->get_timeslot();
	my $second_ts = $second->get_timeslot();
	return $first_ts->compare($second_ts);
}
sub check_clash{
	my ($first, $second) = @_;
	my $first_timeslot = $first->get_timeslot();
	my $second_timeslot = $second->get_timeslot();
	#We don't check clashes amongst rooms, or referenced staff / students/ other module activities as that job has been delegated to the Schedules referenced by staff/students/rooms/modules and Constraint's children. We're only concerned about clashing timeslots
	return $first_timeslot->check_clash($second_timeslot);
}
#mostly for lunchtime constraints
sub check_clash_time_only{
	my ($activity, $timeslot) = @_;
	my $first_timeslot = $activity->get_timeslot();
	return $first_timeslot->check_clash_time_only($timeslot);
}
1;
