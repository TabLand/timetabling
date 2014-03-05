#!/usr/bin/perl
package Activity;
use strict;
use warnings;
use Module;
use Person;
use Room;
use SimpleTimeslot;

sub new{
	my ($class, $type, $group) = @_;

	my $room = new Room("No where", 0);
	my $module = new Module("No Module","No Description");
	my $timeslot = new SimpleTimeslot(00,00,00,00);

	my $self = {
		_type => $type,
		_group => $group,
		_students => [],
		_staff => [],
		_room => $room,
		_module => $module,
		_timeslot => $timeslot
	};

	bless $self, $class;
	return $self;
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
	$self->{_room} = $room;
}
sub get_module{
	my $self = shift;
	return $self->{_module};
}
sub set_module{
	my ($self, $module) = @_;
	$self->{_module} = $module;
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
	$staff->add_activity($self);
	push @{$self->{_staff}}, $staff;
}
sub add_student{
	my ($self, $student) = @_;
	$student->add_activity($self);
	push @{$self->{_students}}, $student;
}
sub exists_student{
	my ($self, $needle) = @_;
	foreach my $student (@{$self->{_students}}){
		if($student->equals($needle)) {
			return 1;
		}
	}
	return 0;
}
sub exists_staff{
	my ($self, $needle) = @_;
	foreach my $staff (@{$self->{_staff}}){
		if($staff->equals($needle)){
			return 1;
		}
	}
	return 0;
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
