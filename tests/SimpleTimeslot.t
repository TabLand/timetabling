#!/usr/bin/perl
use Test::More qw(no_plan); 
use lib "..";
use SimpleTimeslot;

use strict;
use warnings;

subtest "create" => sub {
	my $my_timeslot = new SimpleTimeslot(14,00,2,00);
	isa_ok($my_timeslot, "SimpleTimeslot");
};

subtest "equals" => sub{
	my $timeslot = new SimpleTimeslot(14,00, 2,00);
	my $timeslot2 = new SimpleTimeslot(14,00, 2,00);
	cmp_ok($timeslot, "==", $timeslot2);
};

subtest "end" => sub{
	my $timeslot = new SimpleTimeslot(14,00, 2,00);
	my $end = new SimpleTime(16,00);
	cmp_ok($timeslot->get_end(), "==", $end);
};


subtest "clash early overlap" => sub {
	my $early = new SimpleTimeslot(14,00, 2,00);
	my $late = new SimpleTimeslot(15,00, 2,00);
	ok($early->check_clash($late));
};


subtest "clash late overlap" => sub {
	my $early = new SimpleTimeslot(14,00, 2,00);
	my $late = new SimpleTimeslot(15,00, 2,00);
	ok($late->check_clash($early));
};

subtest "clash inside" => sub {
	my $early = new SimpleTimeslot(12,00, 6,00);
	my $late = new SimpleTimeslot(14,00, 2,00);
	ok($late->check_clash($early));
};
subtest "do not clash" => sub {
	my $early = new SimpleTimeslot(12,00, 6,00);
	my $late = new SimpleTimeslot(19,00, 2,00);
	is($late->check_clash($early),0);
};
subtest "near miss is not a clash" => sub {
	my $early = new SimpleTimeslot(12,00, 6,00);
	my $late = new SimpleTimeslot(18,00, 2,00);
	is($late->check_clash($early),0);
};
