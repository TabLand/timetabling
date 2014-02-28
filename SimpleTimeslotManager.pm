#!/usr/bin/perl
package SimpleTimeslotManager;
use SimpleTimeslot;

sub new{
	$class = shift;
	$self = {};
	bless $self, $class;
	return $self;
}

sub add{
	my ($self, $day, $term, $slot) = @_;
	#hash will overwrite for slots with same start time..
	$overwritten = $self->existing_ref($self, $day, $term, $slot);

	$self->{$day}{$term}{$slot->get_start()} = $slot;

	return $overwritten;
}

sub existing_ref{
	my ($self, $day, $term, $slot) = @_;
	return (exists $self->{$day});
}

sub get{
	my ($self,$day,$term) = @_;
	return $self->{$day}{$term};
}

sub check_clashes{

}

sub contains{
	my ($self, $day, $term, $slot) = @_;
	return ($self->{$day}{$term}{$slot->get_start()} == $slot);
}

1;
