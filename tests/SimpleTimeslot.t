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

subtest "not equals"=> sub{
	my $timeslot = new SimpleTimeslot(14,00, 2,00);
	my $timeslot2 = new SimpleTimeslot(14,30, 2,00);
	cmp_ok($timeslot, "!=", $timeslot2);
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
subtest "sort" => sub{
	my $first = new SimpleTimeslot(12,00, 1,00);
	my $second = new SimpleTimeslot(14,00, 1,00);

	my ($early, $late) = sort ($second, $first);

	is($early, $first, "Smaller argument to timeslot sort is returned first");
	is($late, $second, "Larger argument to timeslot sort is returned later");
};

subtest "intersect clash early" => sub{
	my $early = new SimpleTimeslot(12,00, 3,00);
	my $late = new SimpleTimeslot(14,00, 2,00);

	my @cut = $early->intersect($late);

	my $first = $cut[0] == new SimpleTimeslot(12,00, 2,00);
	my $second = $cut[1] == new SimpleTimeslot(14,00, 1,00);
	my $third = $cut[2] == new SimpleTimeslot(15,00, 1,00);
	
	cmp_ok($cut[0],"==", new SimpleTimeslot(12,00, 2,00), "first intersect as expected");
	cmp_ok($cut[1],"==", new SimpleTimeslot(14,00, 1,00), "second intersect as expected");
	cmp_ok($cut[2],"==", new SimpleTimeslot(15,00, 1,00), "first intersect as expected");
};
subtest "intersect clash late" => sub{
	my $early = new SimpleTimeslot(12,00, 3,00);
	my $late = new SimpleTimeslot(14,00, 2,00);

	my @cut = $late->intersect($early);

	cmp_ok($cut[0],"==", new SimpleTimeslot(12,00, 2,00), "first intersect as expected");
	cmp_ok($cut[1],"==", new SimpleTimeslot(14,00, 1,00), "second intersect as expected");
	cmp_ok($cut[2],"==", new SimpleTimeslot(15,00, 1,00), "first intersect as expected");
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
