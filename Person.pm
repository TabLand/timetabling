#!/usr/bin/perl
package Person;
use strict;
use warnings;

sub new{
	my ($class, $username, $name) = @_;
	my $self = {
		_username => $username,
		_name => $name
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
sub add_activity{
	my ($self, $activity) = @_;
	push @{$self->{_activities}}, $activity;
}
sub exists_activity{
	my ($self, $needle) = @_;
	foreach my $activity (@{$self->{_activities}}){
		if($activity->equals($needle)){
			return 1;
		}
	}
	return 0;
}
1;
