#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use Activity;
use strict;
use warnings;

subtest "Create" => sub{
	my $lecture = new Activity("Lecture", "ALL");
	isa_ok($lecture, "Activity");
	is($lecture->get_type(), "Lecture", "Activity type getter works");
	is($lecture->get_group(), "ALL", "Activity group getter works");
};
subtest "Module Association" => sub{
	my $lecture = new Activity("Lecture", "ALL");
	my $module = new Module("IN2029", "Programming in C++");

	$lecture->set_module($module);
	ok($lecture->get_module()->equals($module), "Module getter and setters work");
};
subtest "Student Association" => sub{
	my $lecture = new Activity("Lecture", "ALL");
	my $student = new Person("abnd198", "Ijtaba Hussain");
	my $module = new Module("IN2029", "Programming in C++");
	
	$lecture->add_student($student);
	$lecture->set_module($module);

	ok($lecture->exists_student($student), "Activity contains reference to student");
	ok($student->exists_activity($lecture), "Student Person contains a reference to activity");
};
subtest "Staff Association" => sub{
	my $lecture = new Activity("Lecture", "ALL");
	my $lecturer = new Person("kloukin", "Dr Christos Kloukinas");
	my $module = new Module("IN2029", "Programming in C++");

	$lecture->add_staff($lecturer);
	$lecture->set_module($module);

	ok($lecture->exists_staff($lecturer), "Activity contains reference to staff");
	ok($lecturer->exists_activity($lecture), "Staff Person contains a reference to activity");
};
subtest "Room Association" => sub{
	my $lecture = new Activity("Lecture", "ALL");
	my $room = new Room("C304", 30);

	$lecture->set_room($room);
	ok($lecture->get_room()->equals($room));
};
subtest "Timeslot Association" => sub{
	my $lecture = new Activity("Lecture", "ALL");
	my $slot = new SimpleTimeslot(12,00,2,00);
	
	$lecture->set_timeslot($slot);
	ok($slot->equals($lecture->get_timeslot()));
}
