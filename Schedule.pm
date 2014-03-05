#!/usr/bin/perl
package Schedule;
use SimpleTimeslot;
use List::BinarySearch qw( :all );

sub new{
	$class = shift;
	$self = {};
	bless $self, $class;
	return $self;
}

sub add_slot{
	my ($self, $day, $term, $slot) = @_;
	push (@{$self->{$day}{$term}}, $slot);
	sort @{$self->{$day}{$term}};
}

sub _existing_ref{
	my ($self, $day, $term) = @_;
	if(defined $self->{$day}{$term}) {return 1;}
	else {return 0;}
}

sub get{
	my ($self,$day,$term) = @_;
	if($self->_existing_ref($day,$term)){
		return $self->{$day}{$term};
	}
	else {
		return [];
	}
}

sub get_clashes{
	my ($self, $term, $day, $needle) = @_;
	my @slots = $self->{$day}{$term};
	@return = [];
	foreach my $slot (@slots){
		if($slot->check_clash($needle)){
			push @return, $slot;
		}
	}
	return @return;
}

sub contains{
	my ($self, $day, $term, $needle) = @_;

	if($self->_existing_ref($day, $term)){
		my $hay_stack = $self->{$day}{$term}; 
		foreach $slot (@$hay_stack){
			if($needle == $slot) {
				return 1;
			}
		}	
		return 0;
	}
	else{
		return 0;
	}
}
1;
