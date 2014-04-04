#!/usr/bin/perl
use Test::More qw(no_plan); 
use lib "..";
use SimpleTimeslot;
use Day;
use Term;
use strict;
use warnings;

subtest "create" => sub {
	my $timeslot = new SimpleTimeslot("Mon", "Term 1", 14,00,2,00);
	isa_ok($timeslot, "SimpleTimeslot");
	is($timeslot->get_day(), "Monday", "day getter works");
	is($timeslot->get_term(), "Term 1", "term getter works");
};

subtest "equals" => sub{
	my $timeslot = new SimpleTimeslot("Mon", "Term 1", 14,00, 2,00);
	my $timeslot2 = new SimpleTimeslot("Mon", "Term 1", 14,00, 2,00);
	cmp_ok($timeslot, "==", $timeslot2);
};

subtest "not equals"=> sub{
	my $timeslot = new SimpleTimeslot("Mon", "Term 1", 14,00, 2,00);
	my $timeslot2 = new SimpleTimeslot("Mon", "Term 1", 14,30, 2,00);
	my $timeslot3 = new SimpleTimeslot("Tue", "Term 2", 14,00, 2,00);

	cmp_ok($timeslot, "!=", $timeslot2, "Not equal as different times on same day and term");
	cmp_ok($timeslot, "!=", $timeslot3, "Not equal as same times on different day and term");

}; 

subtest "end" => sub{
	my $timeslot = new SimpleTimeslot("Tue", "Term 2", 14,00, 2,00);
	my $end = new SimpleTime(16,00);
	cmp_ok($timeslot->get_end(), "==", $end);
};


subtest "clash early overlap" => sub {
	my $early = new SimpleTimeslot("Tue", "Term 2", 14,00, 2,00);
	my $late = new SimpleTimeslot("Tue", "Term 2", 15,00, 2,00);
	ok($early->check_clash($late));
};


subtest "clash late overlap" => sub {
	my $early = new SimpleTimeslot("Tue", "Term 2", 14,00, 2,00);
	my $late = new SimpleTimeslot("Tue", "Term 2", 15,00, 2,00);
	ok($late->check_clash($early));
};

subtest "clash inside" => sub {
	my $early = new SimpleTimeslot("Tue", "Term 2", 12,00, 6,00);
	my $late = new SimpleTimeslot("Tue", "Term 2", 14,00, 2,00);
	ok($late->check_clash($early));
};
subtest "do not clash" => sub {
	my $early = new SimpleTimeslot("Tue", "Term 2", 12,00, 6,00);
	my $late = new SimpleTimeslot("Tue", "Term 2", 19,00, 2,00);
	my $next_day = new SimpleTimeslot("Wed", "Term 1", 12,00, 6,00);

	is($late->check_clash($early),0,"Do not clash on non overlapping times on same day and term");
	is($early->check_clash($next_day),0,"Do not clash on non overlapping times on different day and term");
};
subtest "near miss is not a clash" => sub {
	my $early = new SimpleTimeslot("Tue", "Term 2", 12,00, 6,00);
	my $late = new SimpleTimeslot("Tue", "Term 2", 18,00, 2,00);
	is($late->check_clash($early),0);
};
subtest "same start time is a clash" => sub {
	my $early = new SimpleTimeslot("Tue", "Term 2", 12,00, 6,00);
	my $late = new SimpleTimeslot("Tue", "Term 2", 12,00, 2,00);
	is($late->check_clash($early),1);
};
subtest "sort" => sub{
	my $first = new SimpleTimeslot("Tue", "Term 2", 12,00, 1,00);
	my $second = new SimpleTimeslot("Tue", "Term 2", 14,00, 1,00);

	my ($early, $late) = sort ($second, $first);

	is($early, $first, "Smaller argument to timeslot sort is returned first");
	is($late, $second, "Larger argument to timeslot sort is returned later");
};

subtest "compare" => sub{
	my $first = new SimpleTimeslot("Mon", "Term 1", 12,00, 1,00);
	my $second = new SimpleTimeslot("Tue", "Term 1", 12,00, 1,00);

	ok($first < $second, "Monday behind tuesday");
	$first->set_term(2);
	ok($first > $second, "Term 1 behind Term 2");

	$second->set_term(2);
	$second->set_day("Monday");

	ok($first == $second, "Both now equal");
};
