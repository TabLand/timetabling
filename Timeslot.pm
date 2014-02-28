#!/usr/bin/perl
package Timeslot;
use Moose;
use DateTime;

has '_start' => (is => 'rw', isa => 'DateTime');
has '_duration'=> (is => 'rw', isa => 'DateTime::Duration');

sub check_clash{
	my $self = shift;
	my $timeslot2 = shift;
	
	my $first_starts_later = $self->_start > $timeslot2->_start;
	my $second_ends_earlier = $self->_start < $timeslot2->_start + $timeslot2->_duration;

	my $second_starts_later = $timeslot2->_start > $self->_start;
	my $first_ends_earlier = $timeslot2->_start < $self->_start + $self->_duration;

	if($first_starts_later && $second_ends_earlier) {1;}
	elsif($second_starts_later && $first_ends_earlier) {1;}
	else {0;}
};

1;
