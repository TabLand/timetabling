#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "../src";
use lib "../src/Manager";
use ConstraintOverbook;
use Person;
use Room;
use Module;
use strict;
use warnings;

subtest "Clash Person" => sub {
	my $student = new Person("abnd198", "Ijtaba Hussain");

	my $IN2029 = new Module("IN2029", "Programming in C++");
	my $IN3017 = new Module("IN3017", "Theory of Computation");

	my $IN2029_lecture = new Activity($IN2029, "Lecture", "ALL");
	my $IN3017_lecture = new Activity($IN3017, "Lecture", "ALL");

	my $three_till_five = new SimpleTimeslot("Thu", "Term 1", 15,00, 2,00);
	my $two_till_four = new SimpleTimeslot("Thu", "Term 1", 14,00, 2,00);

	$IN2029_lecture->set_timeslot($two_till_four);
	$IN3017_lecture->set_timeslot($three_till_five);

	$IN2029_lecture->add_student($student);
	$IN3017_lecture->add_student($student);

	my $constraint = new ConstraintOverbook($student, 10);
	ok(!$constraint->met(), "Student expected to be in two places at once");


	my $one = new SimpleTimeslot("Thu", "Term 1", 13,00,2,00);
	$IN2029_lecture->set_timeslot($one);

	ok($constraint->met(), "Student no longer expected to be in two places at once");
};

subtest "Clash Room" => sub {
	my $room = new Room("C301", 30);

	my $IN2029 = new Module("IN2029", "Programming in C++");
	my $IN3017 = new Module("IN3017", "Theory of Computation");

	my $IN2029_lecture = new Activity($IN2029, "Lecture", "ALL");
	my $IN3017_lecture = new Activity($IN3017, "Lecture", "ALL");

	my $three_till_five = new SimpleTimeslot("Thu", "Term 1", 15,00, 2,00);
	my $two_till_four = new SimpleTimeslot("Thu", "Term 1", 14,00, 2,00);

	$IN2029_lecture->set_timeslot($two_till_four);
	$IN3017_lecture->set_timeslot($three_till_five);

	$IN2029_lecture->set_room($room);
	$IN3017_lecture->set_room($room);

	my $constraint = new ConstraintOverbook($room, 10);
	ok(!$constraint->met(), "Room Double Booked");


	my $one = new SimpleTimeslot("Thu", "Term 1", 13,00,2,00);
	$IN2029_lecture->set_timeslot($one);

	ok($constraint->met(), "Room no longer double booked");
};
