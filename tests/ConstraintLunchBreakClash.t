#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use ConstraintLunchBreakClash;
use Person;
use Module;
use strict;
use warnings;

subtest "Clash" => sub {
	my $student = new Person("abnd198", "Ijtaba Hussain");

	my $IN2029 = new Module("IN2029", "Programming in C++");

	my $IN2029_lecture = new Activity($IN2029, "Lecture", "ALL");
	my $IN2029_tutorial = new Activity($IN2029, "Tutorial", "ALL");

	my $twelve_till_two = new SimpleTimeslot("Thu", "Term 1", 12,00, 2,00);
	my $two_till_four = new SimpleTimeslot("Thu", "Term 1", 14,00, 2,00);

	$IN2029_lecture->set_timeslot($twelve_till_two);
	$IN2029_tutorial->set_timeslot($two_till_four);

	$IN2029_lecture->add_student($student);
	$IN2029_tutorial->add_student($student);

	my $constraint = new ConstraintLunchBreakClash($student, 10);
	ok(!$constraint->met(), "Student missing out on lunch");
	
	/*Move the timeslot over to after 3pm*/
	$two_till_four->set_start(15,00);

	ok($constraint->met(), "Student no longer missing out on lunch");
};
