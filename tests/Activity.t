#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use Activity;
use strict;
use warnings;

subtest "Create" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module,"Lecture", "ALL");
	isa_ok($lecture, "Activity");
	is($lecture->get_type(), "Lecture", "Activity type getter works");
	is($lecture->get_group(), "ALL", "Activity group getter works");
};
subtest "Module Association" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module,"Lecture", "ALL");

	ok($lecture->get_module()->equals($module), "Module getter and setters work");
	is($lecture->identifier(),"IN2029/Lecture/ALL", "Correct Activity Identifier");
	is($module->get_activity_numbers(),1,"Module contains correct number of activities");
	ok($module->exists_activity($lecture),"Module contains reference to activity");
};
subtest "Student Association" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module,"Lecture", "ALL");
	my $student = new Person("abnd198", "Ijtaba Hussain");

	$lecture->add_student($student);

	ok($lecture->exists_student($student), "Activity contains reference to student");
	ok($student->exists_activity($lecture), "Student Person contains a reference to activity");

	is($lecture->get_student_numbers(),1,"Received correct number of students after student add");
	is($student->get_activity_numbers(),1,"Received correct number of activities in student after add activity to student");

	$lecture->remove_student($student);
	is($lecture->get_student_numbers(),0,"Received correct number of students in activity after student remove");
	is($student->get_activity_numbers(),0,"Received correct number of activities in student after remove activity from student");

	ok(!$lecture->exists_staff($student), "Student remove works");
	ok(!$student->exists_activity($lecture), "Student no longer contains a reference to activity");
};
subtest "Staff Association" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module,"Lecture", "ALL");
	my $lecturer = new Person("kloukin", "Dr Christos Kloukinas");

	$lecture->add_staff($lecturer);

	ok($lecture->exists_staff($lecturer), "Activity contains reference to staff");
	ok($lecturer->exists_activity($lecture), "Staff Person contains a reference to activity");
	is($lecture->get_staff_numbers(),1,"Received correct number of staff after staff add");
	is($lecturer->get_activity_numbers(),1,"Received correct number of activities in staff after add activity to staff");

	$lecture->remove_staff($lecturer);
	is($lecturer->get_activity_numbers(),0,"Received correct number of activities in staff after remove activity from staff");
	is($lecture->get_staff_numbers(),0,"Received correct number of staff after staff remove");
	ok(!$lecture->exists_staff($lecturer), "Staff remove works");
	ok(!$lecturer->exists_activity($lecture), "Staff no longer contains a reference to activity");
};
subtest "Room Association" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module,"Lecture", "ALL");
	my $room = new Room("C304", 30);
	my $second_room = new Room("C305", 35);

	$lecture->set_room($room);
	ok($lecture->get_room()->equals($room), "Activity contains reference to first Room");
	ok($room->exists_activity($lecture),"First room contains reference to activity");
	
	$lecture->set_room($second_room);
	ok($lecture->get_room()->equals($second_room), "Activity now contains reference to second room");
	ok(!$room->exists_activity($lecture),"First room no longer contains reference to activity");
};
subtest "Timeslot Association" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module,"Lecture", "ALL");
	my $slot = new SimpleTimeslot(12,00,2,00);
	
	$lecture->set_timeslot($slot);
	ok($slot->equals($lecture->get_timeslot()), "Expected timeslot returned");
}
