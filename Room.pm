#!/usr/bin/perl
package Room;
use strict;
use warnings;
use parent "ActivityHolder";

sub new{
	my ($class, $code, $capacity) = @_;
	my $self = {
		_code => $code,
		_capacity => $capacity,
		_activities => {}
	};
	bless $self, $class;
	return $self;
}
sub get_code{
	my $self = shift;
	return $self->{_code};
}
sub get_capacity{
	my $self = shift;
	return $self->{_capacity};
}
sub equals{
	my ($first, $second) = @_;
	my $same_code = $first->get_code() eq $second->get_code();
	my $same_capacity = $first->get_capacity() == $second->get_capacity();
	return $same_code && $same_capacity;
}
sub to_string{
	my $self = shift;
	my $code = $self->get_code();
	my $capacity = $self->get_capacity();
	return "Room($code,Capacity:$capacity)";
}
1;
