#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use ConstraintLunchBreak;
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

	my $lunchtime = new SimpleTimeslot("Noday", "Term 0", 12,00, 3,00);

	my $constraint = new ConstraintLunchBreak($student, 10, $lunchtime);

	my $commitments = $constraint->get_activities_during_lunchtime();
	my @break_durations =  $constraint->get_minutes_between_activities($commitments);

	is($commitments->get_activity_numbers(),2, "Correct number of activities returned from schedule get_between");
	is(@break_durations,3,"Correct number of break durations returned");
	is(join(",",@break_durations),"0,0,-60");
	is($break_durations[0],0,"First break duration as expected");
	is($break_durations[1],0,"Second break duration as expected");
	is($break_durations[2],-60,"Third break duration as expected");
	ok(!$constraint->met(), "Student missing out on lunch");
	
	#Move the timeslot over to after 3pm
	$two_till_four->set_start(15,00);

	ok($constraint->met(), "Student no longer missing out on lunch");
};
