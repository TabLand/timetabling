#!/usr/bin/perl
use Test::More qw(no_plan);
use lib "../src";
use lib "../src/Manager";
use RoomManager;
use strict;
use warnings;

subtest "Create" => sub{
	my $room_manager = new RoomManager();
	isa_ok($room_manager, "RoomManager");
};
subtest "Contains" => sub{
	my $room_manager = new RoomManager();
	my $room = new Room("CG01", 10);

	$room_manager->add($room);
	ok($room_manager->contains("CG01"));
};
subtest "Find by Minimum capacity" => sub{
	my $room_manager = new RoomManager();
	my $room = new Room("CG01", 10);

	$room_manager->add($room);

	my $rooms_ref = $room_manager->find_by_min_capacity(10);
	my @rooms = @$rooms_ref;
	
	is(@rooms,1, "correct number of rooms returned");

	ok($rooms[0]->equals($room), "expected room returned");

	my $not_found_ref = $room_manager->find_by_min_capacity(11);
	my @not_found = @$not_found_ref;
	is(@not_found,0,"no room with unachievable capacity found");
};
