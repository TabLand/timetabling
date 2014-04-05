#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use SimpleTime;
use strict;
use warnings;

subtest "Create SimpleTime" => sub{
	my $time = new SimpleTime(10,00);
	isa_ok($time, "SimpleTime");
};

subtest "Equals" => sub {
	my $half_past_ten = new SimpleTime(10,30);
	my $half_past_ten2 = new SimpleTime(10,30);
	cmp_ok($half_past_ten, "==", $half_past_ten2);
};

subtest "String Equals" => sub {
	my $half_past_ten = new SimpleTime(10,30);
	is($half_past_ten, "10:30");
};

subtest "Add" => sub {
	my $first = new SimpleTime(10,00);
	my $second = new SimpleTime(2,40);
	my $sum = $first + $second;
	cmp_ok($sum,"==", new SimpleTime(12,40));
};

subtest "Subtract" => sub {
	my $two_thirty = new SimpleTime(2,30);
	my $one_ten = new SimpleTime(1,10);
	my $diff = $two_thirty - $one_ten;
	cmp_ok($diff,"==", new SimpleTime(1, 20));
};

subtest "Less than" => sub{
	my $ten = new SimpleTime(10,00);
	my $eleven = new SimpleTime(11,00);
	cmp_ok($ten, "<", $eleven);
};

subtest "More than" => sub{
	my $ten = new SimpleTime(10,00);
	my $eleven = new SimpleTime(11,00);
	cmp_ok($eleven , ">" , $ten);
};

subtest "More than equals" => sub{
	my $eleven = new SimpleTime(11,00);
	my $eleven2 = new SimpleTime(11,00);
	cmp_ok($eleven, ">=", $eleven2);
};

subtest "Less than equals" => sub{
	my $eleven = new SimpleTime(11,00);
	my $eleven2 = new SimpleTime(11,00);
	is($eleven<=$eleven2,1);
};

subtest "Large subtraction loops to previous day" => sub {
	my $one = new SimpleTime(1,00);
	my $two = new SimpleTime(2, 00);
	my $diff = $one - $two;
	cmp_ok($diff,"==", new SimpleTime(23, 00));
};
subtest "Minutes to" => sub{
	my $one = new SimpleTime(1,00);
	my $two = new SimpleTime(2, 00);
	my $minutes_to = $one->minutes_to($two);
	is($minutes_to, 60, "Single hour minutes to calculation works");
	my $half_twelve = new SimpleTime(12,30);
	my $quarter_to_five = new SimpleTime(16,45);
	$minutes_to = $half_twelve->minutes_to($quarter_to_five);
	is($minutes_to, 4*60+15, "Multiple hour minutes to calculation works");
	$minutes_to = $quarter_to_five->minutes_to($half_twelve);
	is($minutes_to, -4*60-15, "Negative minutes to calculation also works");
}
