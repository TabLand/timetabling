#!/usr/bin/perl
use warnings;
use strict;

use Test::More qw(no_plan);
use lib "..";
use Schedule;
use JSON;

subtest "Create" => sub{
	my $schedule = new Schedule();
	isa_ok($schedule, "Schedule");
};

subtest "get" => sub{
	my $schedule = new Schedule();
	my $two = new SimpleTimeslot(14, 00, 2, 00);


	$schedule->add_slot("Mon", "Term 1", $two);

	my $slots = $schedule->get("Mon", "Term 1");
	is(@$slots, 1, "returns expected number of slots in array");
	isa_ok($$slots[0], "SimpleTimeslot");
};
subtest "contains" => sub{
	my $schedule = new Schedule();
	my $two = new SimpleTimeslot(14, 00, 2, 00);
	my $second_two = new SimpleTimeslot(14, 00, 2, 00);

	$schedule->add_slot("Mon", "Term 1", $two);

	my $slots = $schedule->get("Mon", "Term 1");
	is(@$slots, 1, "returns expected number of slots in array");
	is($schedule->contains("Mon", "Term 1" , $second_two),1);
};
subtest "does not contain" => sub{
	my $schedule = new Schedule();
	my $two = new SimpleTimeslot(14, 00, 2, 00);

	my $slots = $schedule->get("Mon", "Term 1");
	is(@$slots, 0, "returns expected number of slots in array");
	is($schedule->contains("Mon", "Term 1" , $two), 0);
};
subtest "unique array refs" => sub{
	my $one = \[];
	my $two = \[];
	my $three = \[];
	ok($one != $two);
	ok($two != $three);
	ok($three != $one);
};
