#!/usr/bin/perl
use warnings;
use strict;

use Test::More qw(no_plan);
use lib "..";
use Schedule;

subtest "Create" => sub{
	my $schedule = new Schedule();
	isa_ok($schedule, "Schedule");
};

subtest "contains" => sub{
	my $schedule = new Schedule();
	my $timeslot = new SimpleTimeslot(14, 00, 2, 00);
	$schedule->add_slot("Mon", "Term 1", $timeslot);
	is($schedule->contains("Mon", "Term 1" , $timeslot),1);
};

subtest "does not contain" => sub{
	my $schedule = new Schedule();
	my $timeslot = new SimpleTimeslot(14, 00, 2, 00);
	is($schedule->contains("Mon", "Term 1" , $timeslot), 0);
};
