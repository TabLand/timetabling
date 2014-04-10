#!/usr/bin/perl
package Timetable;
use strict;
use warnings;
use ModuleManager;
use PersonManager;
use ConstraintManager;
use RoomManager;

sub new{
	my ($class) = @_;
	my $self = {
		_modules => new ModuleManager(),
		_students => new PersonManager(),
		_staff => new PersonManager(),
		_rooms => new RoomManager(),
		_constraints => new ConstraintManager()
	};
	bless $self, $class;
	return $self;
}
sub get_staff_manager{
	my $self = shift;
	return $self->{_staff};
}
sub get_student_manager{
	my $self = shift;
	return $self->{_students};
}
sub get_module_manager{
	my $self = shift;
	return $self->{_modules};
}
sub get_constraint_manager{
	my $self = shift;
	return $self->{_constraints};
}
sub get_room_manager{
	my $self = shift;
	return $self->{_rooms};
}
sub generate_lunchtime_constraints{
	my ($self, $penalty) = shift;
	#make this editable? config files?
	my $lunchtime = new SimpleTimeslot("Noday", "Term 0", 12,00, 3,00);
	my $constraints = $self->get_constraint_manager();

	my @staff = $self->get_staff_manager()->get_all();
	for my $staff (@staff){
		$lunchbreak_checker = new ConstraintLunchBreak($staff, $penalty, $lunchtime);
		$constraints->add($lunchbreak_checker);
	}
}
sub generate_capacity_constraints{
	my ($self, $penalty) = shift;
	#make this editable? config files?

	my $constraints = $self->get_constraint_manager();
	my @rooms = $self->get_rooms_manager()->get_all();

	for my $room (@rooms){
		$capacity_checker = new ConstraintCapacity($staff, $penalty);
		$constraints->add($capacity_checker);
	}
}
sub generate_overbook_constraints{
	my ($self, $penalty) = shift;
	#make this editable? config files?

	my $constraints = $self->get_constraint_manager();
	my @rooms = $self->get_rooms_manager()->get_all();
	my @students = $self->get_students_manager()->get_all();
	my @staff = $self->get_staff_manager()->get_all();

	my @resources = (@rooms, @students, @staff);

	for my $resource (@resources){
		$overbooking_checker = new ConstraintOverbook($resource, $penalty);
		$constraints->add($overbooking_checking);
	}
}
1;
