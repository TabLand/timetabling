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
subtest "sort" => sub{
	my $first = new SimpleTimeslot("Tue", "Term 2", 12,00, 1,00);
	my $second = new SimpleTimeslot("Tue", "Term 2", 14,00, 1,00);

	my ($early, $late) = sort ($second, $first);

	is($early, $first, "Smaller argument to timeslot sort is returned first");
	is($late, $second, "Larger argument to timeslot sort is returned later");
};

subtest "intersect clash inside" => sub{
	my $early = new SimpleTimeslot(12,00, 6,00);
	my $late = new SimpleTimeslot(14,00, 2,00);

	my @cut = $late->intersect($early);

	cmp_ok($cut[0],"==", new SimpleTimeslot(12,00, 2,00), "first intersect as expected");
	cmp_ok($cut[1],"==", new SimpleTimeslot(14,00, 2,00), "second intersect as expected");
	cmp_ok($cut[2],"==", new SimpleTimeslot(16,00, 2,00), "first intersect as expected");
};
subtest "no intersect" => sub{
	my $early = new SimpleTimeslot(12,00, 1,00);
	my $late = new SimpleTimeslot(14,00, 1,00);

	my @cut = $late->intersect($early);

	cmp_ok($cut[0],"==", $early, "first intersect as expected");
	cmp_ok($cut[1],"==", $late, "second intersect as expected");
	is(@cut, 2, "return array size as expected");
};
subtest "intersect returns single" => sub {
	my $one = new SimpleTimeslot(1,00, 1,00);
	my $second_one = new SimpleTimeslot(1,00, 1,00);

	my @cut = $one->intersect($second_one);

	my $first = $cut[0] == $one;
	my $size_is_one = @cut == 1;

	cmp_ok($cut[0],"==", $one, "intersect as expected");
	is(@cut, 1, "return array size as expected");
};
