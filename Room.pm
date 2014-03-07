#!/usr/bin/perl
package Room;
use strict;
use warnings;
use ActivityHolder;
use overload "\"\"" => \&to_string;

sub new{
	my ($class, $code, $capacity) = @_;
	my $self = {
		_code => $code,
		_capacity => $capacity,
		_schedule => new ActivityHolder()
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
sub get_schedule{
	my $self = shift;
	return $self->{_schedule};
}
sub to_string{
	my $self = shift;
	my $code = $self->get_code();
	my $capacity = $self->get_capacity();
	return "Room($code,Capacity:$capacity)";
}
1;
