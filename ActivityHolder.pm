#!/usr/bin/perl
package ActivityHolder;
use strict;
use warnings;

sub add_activity{
	my ($self, $activity) = @_;
	$self->{_activities}{$activity->identifier()} = $activity;
}
sub get_activity_ids{
	my $self = shift;
	my @ids = keys $self->{_activities};
	return join "," , @ids;
}
sub get_activity_numbers{
	my $self = shift;
	my @numbers = keys $self->{_activities};
	return @numbers;
}
sub remove_activity{
	my ($self, $activity) = @_;
	delete $self->{_activities}{$activity->identifier()};
}
sub exists_activity{
	my ($self, $activity) = @_;
	return exists $self->{_activities}{$activity->identifier()};
}
1;
