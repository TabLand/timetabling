#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "../src";
use lib "../src/Manager";
use Room;
use strict;
use warnings;

subtest "Create" => sub{
	my $room = new Room("C104", 30);
	isa_ok($room, "Room");
	is($room->get_code(), "C104", "Room code getter works");
	is($room->get_capacity(), 30, "Room capacity getter works");
};
subtest "Equals" => sub{
	my $room = new Room("C104", 30);
	my $same_room = new Room("C104", 30);
	ok($room->equals($same_room));
};
