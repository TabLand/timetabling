#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use ActivityHolder;
use strict;
use warnings;

subtest "Create" => sub{
	my $module = new ActivityHolder();
	isa_ok($module, "ActivityHolder");
};
subtest "Add / Remove / Exists" =>sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module, "Lecture","ALL");
	my $schedule = new ActivityHolder();

	$schedule->add_activity($lecture);
	ok($schedule->exists_activity($lecture),"Add and exists_activity working");
	is($schedule->get_activity_numbers(), 1, "Correct number of activities returned");

	$schedule->remove_activity($lecture);
	ok(!$schedule->exists_activity($lecture),"Remove and exists_activity working");
	is($schedule->get_activity_numbers(), 0, "Correct number of activities returned");
};
subtest "Get Clashes" => sub{

	my $test_module = new Module("Test", "Testing");

	my $clash = new Activity($test_module, "Clashing", "Once");
	my $another_clash = new Activity($test_module, "Clashing", "Again");
	my $not_clash = new Activity($test_module, "Not clashing", "definitely");

	my $three_till_five = new SimpleTimeslot("Thu", "Term 1", 15,00, 2,00);
	my $two_till_four = new SimpleTimeslot("Thu", "Term 1", 14,00, 2,00);
	my $two_till_four_morrow = new SimpleTimeslot("Fri", "Term 1", 14,00, 2,00);

	$clash->set_timeslot($two_till_four);
	$another_clash->set_timeslot($three_till_five);
	$not_clash->set_timeslot($two_till_four_morrow);

	my $schedule = new ActivityHolder();

	$schedule->add_activity($clash);
	$schedule->add_activity($another_clash);
	$schedule->add_activity($not_clash);

	my $clashes = $schedule->get_clashes();
	print "Schedule" . $schedule;
	print "Clashes" . $clashes;
	is($clashes->get_activity_numbers(), 2, "Correct number of clashing activities returned");
	ok($clashes->exists_activity($clash), "First clash as expected");
	ok($clashes->exists_activity($another_clash), "Second clash as expected");
};
