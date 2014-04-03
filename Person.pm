#!/usr/bin/perl
package Person;
use strict;
use warnings;
use Schedule;
use overload "\"\"" => \&to_string;
sub new{
	my ($class, $username, $name) = @_;
	my $self = {
		_username => $username,
		_name => $name,
		_schedule => new Schedule()
	};
	bless $self, $class;
	return $self;
}
sub get_name{
	my $self = shift;
	return $self->{_name};
}
sub get_username{
	my $self = shift;
	return $self->{_username};
}
sub equals{
	my ($first, $second) = @_;
	my $same_name = $first->get_name() eq $second->get_name();
	my $same_username = $first->get_username() eq $second->get_username();
	return $same_name && $same_username;
}
sub get_schedule{
	my $self = shift;
	return $self->{_schedule};
}
sub to_string{
	my $self = shift;
	my $name = $self->get_name();
	my $username = $self->get_username();
	return "Person($username:$name)";
}
1;
