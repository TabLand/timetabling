#!/usr/bin/perl
package Module;
use strict;
use warnings;
use parent "ActivityHolder";

sub new{
	my ($class, $code, $name) = @_;
	my $self = {
		_code => $code,
		_name => $name,
		_activities => {}
	};
	bless $self, $class;
	return $self;
}
sub get_code{
	my $self = shift;
	return $self->{_code};
}
sub get_name{
	my $self = shift;
	return $self->{_name};
}
sub equals{
	my ($first, $second) = @_;
	my $same_code = $first->get_code() eq $second->get_code();
	my $same_name = $first->get_name() eq $second->get_name();
	return $same_code && $same_name;
}
1;
