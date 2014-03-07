#!/usr/bin/perl
package Module;
use strict;
use warnings;
use ActivityHolder;
use overload "\"\"" => \&to_string;

sub new{
	my ($class, $code, $name) = @_;
	my $self = {
		_code => $code,
		_name => $name,
		_schedule => new ActivityHolder()
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
sub get_schedule{
	my $self = shift;
	return $self->{_schedule};
}
sub to_string{
	my $self = shift;
	my $code = $self->get_code();
	my $name = $self->get_name();
	return "Module($code,$name)";
}
1;
