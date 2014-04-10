#!/usr/bin/perl
package RoomManager;
use Room;
use strict;
use warnings;
use XML::LibXML qw( );

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
sub remove{
	my ($self, $room) = @_;
	delete $self->{_rooms}{$room->get_code()};
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
sub get{
	my ($self, $room_code) = @_;
	if($self->contains($room_code)){
		return $self->{_rooms}{$room_code};
	}
}
sub parseXML{
	my ($self, $filepath) = @_;
	my $parser = XML::LibXML->new();
	my $document = $parser->parse_file($filepath);
	my $root = $document->documentElement();
	my @rooms = $root->getChildrenByTagName("Room");
	for my $room (@rooms){
		my $code = $room->getChildrenByTagName("Code");
		my $capacity = $room->getChildrenByTagName("Capacity");
		$self->add(new Room($code, $capacity));
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
