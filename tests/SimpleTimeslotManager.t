#!/usr/bin/perl
use warnings;
use strict;

use Test::More qw(no_plan);
use lib "..";
use SimpleTimeslotManager;

subtest "Create" => sub{
	my $timeslot_manager = new SimpleTimeslotManager();
	isa_ok($timeslot_manager, "SimpleTimeslotManager");
};

subtest "existing_ref" => sub{
	my $timeslot_manager = new SimpleTimeslotManager();
	my $timeslot = new SimpleTimeslot(14, 00, 2, 00);
	$timeslot_manager->add("Mon", "Term 1", $timeslot);
	is($timeslot_manager->existing_ref("Mon", "Term 1" , $timeslot),1);
};

subtest "non existing_ref" => sub{
	my $timeslot_manager = new SimpleTimeslotManager();
	my $timeslot = new SimpleTimeslot(14, 00, 2, 00);
	ok(!$timeslot_manager->existing_ref("Mon", "Term 1" , $timeslot));
};

subtest "add and contains" => sub{
	my $timeslot_manager = new SimpleTimeslotManager();
	my $timeslot = new SimpleTimeslot(14, 00, 2, 00);
	$timeslot_manager->add("Mon", "Term 1", $timeslot);
	is($timeslot_manager->contains("Mon", "Term 1", $timeslot),1);
};
