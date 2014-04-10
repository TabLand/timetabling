#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "../src";
use lib "../src/Manager";
use Person;
use strict;
use warnings;

subtest "Create" => sub{
	my $person = new Person("abnd198", "Ijtaba Hussain");
	isa_ok($person, "Person");
	is($person->get_username(), "abnd198", "username getter works");
	is($person->get_name(), "Ijtaba Hussain", "name getter works");
};
subtest "Equals" => sub{
	my $person = new Person("abnd198", "Ijtaba Hussain");
	my $same_person = new Person("abnd198", "Ijtaba Hussain");
	ok($person->equals($same_person));
};
