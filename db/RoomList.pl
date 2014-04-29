#!/usr/bin/perl -w
use strict;
use warnings;
use ResourceList;
use RoomDB;

output_room_list();

sub output_room_list{
    my $room_keys = ["code","capacity"];
    ResourceList::output_resource_list($room_keys, \&RoomDB::select_all);
}
