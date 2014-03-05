#!/usr/bin/perl
package RoomManager;
use Room;
use strict;
use warnings;

sub new{
	my ($class) = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}
sub add{
	my ($self, $room) = @_;
	$self->{_rooms}{$room->get_code()} = $room;
}
sub contains{
	my ($self, $room_code) = @_;
	if(defined $self->{_rooms}{$room_code}){
		return 1;
	}
	else {
		return 0;
	}
}
sub find_by_min_capacity{
	#TODO change code to find closest match, not anything above min
	my ($self, $min_capacity) = @_;
	my @rooms = values $self->{_rooms};
	my @return = ();
	foreach my $room (@rooms){
		if($room->get_capacity() >= $min_capacity){
			push @return, $room;
		}
	}
	\@return;
}
1;
