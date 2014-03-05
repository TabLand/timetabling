#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "..";
use Module;
use strict;
use warnings;

subtest "Create" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	isa_ok($module, "Module");
	is($module->get_code(), "IN2029", "Module code getter works");
	is($module->get_name(), "Programming in C++", "Module name getter works");
};
subtest "Equals" => sub{
	my $module = new Module("IN2029", "Programming in C++");
	my $same_module = new Module("IN2029", "Programming in C++");
	ok($module->equals($same_module));
};
