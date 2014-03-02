#!/usr/bin/perl
package Booking;
use Moose;

has '_room' => (is => 'rw', isa => 'Room');
has '_timeslot' => (is => 'rw', isa => 'Timeslot');
has '_module' => (is => 'rw', isa => 'Module');
has '_activity' => (is => 'rw', isa => 'Activity');
#Better off creating student/staff factories/managers?
has '_students' => (is => 'rw', isa => 'HashRef[Student]');
has '_staff' => (is => 'rw', isa => 'HashRef[Staff]');

sub check_clash{
	$booking2 = shift;
	$is_same_room = $_room->equal($booking2->_room);
	$is_time_overlap = $_timeslot->check_clashes($booking2->_timeslot);

	if($is_same_room && $is_time_overlap) 1;
	else 0;
}
sub add_student{
	$new_student = shift;
	$_students->{$student->id} = $new_student;
}
sub add_staff{
	$new_staff = shift;
	$_staff->{$staff->id} = $new_staff;
}
sub remove_student{
	$new_student = shift;
	delete $_students->{$new_student->id};
}
sub remove_staff{
	$new_staff = shift;
	delete $staff->{$new_staff->id};
}