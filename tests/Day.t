#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use Day;
use strict;
use warnings;

subtest "number" => sub{
	is(Day::number("Nod"),-1);
	is(Day::number("Sun"),0);
	is(Day::number("Mon"),1);
	is(Day::number("Tue"),2);
	is(Day::number("Wed"),3);
	is(Day::number("Thu"),4);
	is(Day::number("Fri"),5);
	is(Day::number("Sat"),6);

	is(Day::number("Noday"),-1);
	is(Day::number("Sunday"),0);
	is(Day::number("Monday"),1);
	is(Day::number("Tuesday"),2);
	is(Day::number("Wednesday"),3);
	is(Day::number("Thursday"),4);
	is(Day::number("Friday"),5);
	is(Day::number("Saturday"),6);
};
subtest "pretty" => sub{
	is(Day::pretty(-1),"Noday"); 
	is(Day::pretty(0),"Sunday"); 
	is(Day::pretty(1),"Monday");
	is(Day::pretty(2),"Tuesday");
	is(Day::pretty(3),"Wednesday");
	is(Day::pretty(4),"Thursday");
	is(Day::pretty(5),"Friday");
	is(Day::pretty(6),"Saturday");
};
