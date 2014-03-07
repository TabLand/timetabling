#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use Term;
use strict;
use warnings;

subtest "number" => sub{
	is(Term::number("Term 0"),0);
	is(Term::number("Term 1"),1);
	is(Term::number("Term 2"),2);
	is(Term::number("Term 3"),3);
};

subtest "pretty" => sub{
	is(Term::pretty(0),"Term 0");
	is(Term::pretty(1),"Term 1");
	is(Term::pretty(2),"Term 2");
	is(Term::pretty(3),"Term 3");
};
