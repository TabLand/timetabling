#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "../src";
use lib "../src/Manager";
use Schedule;
use strict;
use warnings;

subtest "Create" => sub{
	my $schedule = new Schedule();
	isa_ok($schedule, "Schedule");
};
subtest "Add / Remove / Exists" =>sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $lecture = new Activity($module, "Lecture","ALL");
	my $schedule = new Schedule();

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

	my $schedule = new Schedule();

	$schedule->add_activity($clash);
	$schedule->add_activity($another_clash);
	$schedule->add_activity($not_clash);

	my $clashes = $schedule->get_clashes();
	is($clashes->get_activity_numbers(), 2, "Correct number of clashing activities returned");
	ok($clashes->exists_activity($clash), "First clash as expected");
	ok($clashes->exists_activity($another_clash), "Second clash as expected");
};
subtest "Get Between" => sub{

	my $test_module = new Module("Test", "Testing");

	my $lecture1 = new Activity($test_module, "First", "First");
	my $lecture2 = new Activity($test_module, "Second", "Second");
	my $lecture3 = new Activity($test_module, "Third", "Third");

	my $twelve_till_one = new SimpleTimeslot("Thu", "Term 1", 12,00, 1,00);
	my $one_till_two = new SimpleTimeslot("Thu", "Term 1", 13,00, 1,00);
	my $two_till_three = new SimpleTimeslot("Thu", "Term 1", 14,00, 1,00);
	my $lunchtime = new SimpleTimeslot("Noday", "Term 0", 12,00, 3,00);

	$lecture1->set_timeslot($twelve_till_one);
	$lecture2->set_timeslot($one_till_two);
	$lecture3->set_timeslot($two_till_three);

	my $schedule = new Schedule();

	$schedule->add_activity($lecture1);
	$schedule->add_activity($lecture2);
	$schedule->add_activity($lecture3);

	my $activities_during_lunch = $schedule->get_between($lunchtime);
	is($activities_during_lunch->get_activity_numbers(), 3, "Correct number of activities during lunch");
	ok($activities_during_lunch->exists_activity($lecture1), "First activity as expected");
	ok($activities_during_lunch->exists_activity($lecture2), "Second activity as expected");
	ok($activities_during_lunch->exists_activity($lecture3), "Third activity as expected");
};
