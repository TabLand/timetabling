#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use ConstraintCapacity;
use Person;
use Room;
use Module;
use strict;
use warnings;

subtest "Room Overcapacity" => sub {
	my $room = new Room("C301", 1);

	my $student = new Person("abnd198", "Ijtaba Hussain");
	my $student2 = new Person("abnd199", "Ijtaba Hussain 2");
	my $student3 = new Person("abnd200", "Ijtaba Hussain 3");

	my $IN2029 = new Module("IN2029", "Programming in C++");

	my $IN2029_lecture = new Activity($IN2029, "Lecture", "ALL");
	my $IN2029_tutorial = new Activity($IN2029, "Tutorial", "ALL");

	my $three_till_five = new SimpleTimeslot("Thu", "Term 1", 15,00, 2,00);
	my $five_till_six = new SimpleTimeslot("Thu", "Term 1", 17,00, 1,00);

	$IN2029_lecture->set_timeslot($three_till_five);
	$IN2029_tutorial->set_timeslot($five_till_six);

	$IN2029_lecture->add_student($student);
	$IN2029_lecture->add_student($student2);
	$IN2029_lecture->add_student($student3);
	$IN2029_lecture->set_room($room);

	$IN2029_tutorial->add_student($student);
	$IN2029_tutorial->add_student($student2);
	$IN2029_tutorial->set_room($room);

	my $constraint = new ConstraintCapacity($room, 10);
	my @activity_capacities = $constraint->get_activity_capacities();
	is(join(",",@activity_capacities),"2,3","Activity capacities array forming as expected");
	
	my @capacity_diffs = $constraint->get_capacity_diffs();
	is(join(",",@capacity_diffs),"1,2","Activity capacities diffs array forming as expected");

	ok(!$constraint->met(), "Room over capacity");

	is($constraint->get_penalty(),30, "Constraint penalty proportional to over stuffing");
	$room->set_capacity(5);

	is($constraint->get_penalty(),25, "Constraint penalty applies to under capacity rooms too");

	ok($constraint->met(), "Room is no longer overbooked");
};
