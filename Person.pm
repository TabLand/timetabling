#!/usr/bin/perl
package Person;
use strict;
use warnings;
use parent "ActivityHolder";
sub new{
	my ($class, $username, $name) = @_;
	my $self = {
		_username => $username,
		_name => $name,
		_activities => {}
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
1;
