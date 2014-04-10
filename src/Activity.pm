#!/usr/bin/perl
package Activity;
use strict;
use warnings;
use Module;
use Person;
use Room;
use SimpleTimeslot;
use overload
    "\"\"" => \&to_string,
    "<=>"  => \&compare,
    "cmp"  => \&compare;

sub new{
	my ($class, $module, $type, $group) = @_;

	my $room = new Room("Nowhere", 0);
	my $timeslot = new SimpleTimeslot("Noday", "Term 0", 00,00,00,00);

	my $self = {
		_type => $type,
		_group => $group,
		_students => {},
		_staff => {},
		_room => $room,
		_module => $module,
		_timeslot => $timeslot
	};
	bless $self, $class;
	$module->get_schedule()->add_activity($self);
	return $self;
}
sub identifier{
	my $self = shift;
	my $module_code = $self->get_module()->get_code();
	my $type = $self->get_type();
	my $group = $self->get_group();
	my $identifier = "$module_code/$type/$group";
	return $identifier;
}
sub get_type{
	my $self = shift;
	return $self->{_type};
}
sub get_group{
	my $self = shift;
	return $self->{_group};
}
sub get_room{
	my $self = shift;
	return $self->{_room};
}
sub set_room{
	my ($self, $room) = @_;
	if (exists $self->{_room}) {
		$self->{_room}->get_schedule()->remove_activity($self);
	}
	$self->{_room} = $room;
	$room->get_schedule()->add_activity($self);
}
sub get_module{
	my $self = shift;
	return $self->{_module};
}
sub get_timeslot{
	my $self = shift;
	return $self->{_timeslot};
}
sub set_timeslot{
	my ($self, $timeslot) = @_;
	$self->{_timeslot} = $timeslot;
}
sub add_staff{
	my ($self, $staff) = @_;
	$self->add_person("_staff", $staff);
}
sub add_student{
	my ($self, $student) = @_;
	$self->add_person("_students", $student);
}
sub add_person{
	my ($self, $type, $person) = @_;
	$person->get_schedule()->add_activity($self);
	$self->{$type}{$person->get_username()} = $person;
}
sub remove_staff{
	my ($self,$staff) = @_;
	$self->remove_person("_staff",$staff);
}
sub remove_student{
	my ($self,$student) = @_;
	$self->remove_person("_students",$student);
}
sub remove_person{
	my ($self,$type, $person) = @_;
	$self->{$type}{$person->get_username()}->get_schedule()->remove_activity($self);
	delete $self->{$type}{$person->get_username()};
}
sub get_student_numbers{
	my $self = shift;
	return $self->get_person_numbers("_students");
}
sub get_staff_numbers{
	my $self = shift;
	return $self->get_person_numbers("_staff");
}
sub get_person_numbers{
	my ($self, $type) = @_;
	my @numbers = keys $self->{$type};
	return @numbers;
}
sub exists_student{
	my ($self, $student) = @_;
	return exists $self->{_students}{$student->get_username()};
}
sub exists_staff{
	my ($self, $staff) = @_;
	return exists $self->{_staff}{$staff->get_username()};
}
sub equals{
	my ($first, $second) = @_;

	my $same_group = $first->get_group() eq $second->get_group();
	my $same_type = $first->get_type() eq $second->get_type();
	my $same_module = $first->get_module()->equals($second->get_module());
	my $same_room = $first->get_room()->equals($second->get_room());
	my $same_timeslot = $first->get_timeslot()->equals($second->get_timeslot());

	return $same_group && $same_type && $same_module && $same_room && $same_timeslot;
}
sub to_string{
	my $self = shift;
	my $room = $self->get_room();
	my $time = $self->get_timeslot();
	my $identifier = $self->identifier();
	return "$identifier, $room, $time, ";
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