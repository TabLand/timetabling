#!/usr/bin/perl
package Schedule;
use SimpleTimeslot;

sub new{
	$class = shift;
	$self = {};
	bless $self, $class;
	return $self;
}

sub add_slot{
	my ($self, $day, $term, $slot) = @_;
	#hash will overwrite for slots with same start time..
	$overwritten = _existing_ref($self, $day, $term, $slot);

	$self->{$day}{$term}{$slot->get_start()} = $slot;

	return $overwritten;
}

sub _existing_ref{
	my ($self, $day, $term, $slot) = @_;
	if(exists $self->{$day}{$term}{$slot->get_start()}) {return 1;}
	else {return 0;}
}

sub get{
	my ($self,$day,$term) = @_;
	return $self->{$day}{$term};
}

sub check_clashes{

}

sub contains{
	my ($self, $day, $term, $slot) = @_;

	if($self->_existing_ref($day, $term, $slot)){
		return ($self->{$day}{$term}{$slot->get_start()} == $slot);
	}
	else{
		return 0;
	}
}
1;
