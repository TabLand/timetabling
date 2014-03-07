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
	$module->add_activity($self);
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
		$self->{_room}->remove_activity($self);
	}
	$self->{_room} = $room;
	$room->add_activity($self);
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
	$self->{$type}{$person->get_username()}->remove_activity($self);
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
1;
