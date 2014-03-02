#!/usr/bin/perl
package SimpleTime;
use strict;
use warnings;
use overload
    "\"\"" => \&_to_string,
    "+"    => \&_add,
    "-"    => \&_subtract,
    "eq"   => \&_string_equals,
    "cmp"  => \&_compare,
    "<=>"  => \&_compare;

sub new{
	my $class = shift;
	my $self = {
		_hour => validate_hour(shift),
		_minute => validate_minute(shift)
	};
	bless $self, $class;
	return $self;
};

sub get_hour{
	my $self = shift;
	return $self->{_hour};
};

sub get_minute{
	my $self = shift;
	return $self->{_minute};
};

sub validate_hour{
	my $hour = shift;
	return ($hour % 24);
};

sub validate_minute{
	my $minute = shift;
	return ($minute % 60);
};

sub _to_string{
	my $self = shift;
	return $self->{_hour} . ":" . $self->{_minute};
};

sub _add{
	my ($first, $second) = @_;
	my $total_hours = $first->get_hour()+$second->get_hour();
	my $total_minutes = $first->get_minute()+$second->get_minute();
	return new SimpleTime($total_hours, $total_minutes);
};

sub _string_equals{
	my ($self, $string) = @_;
	return $self->_to_string() eq $string;
}

sub _subtract{
	my ($first, $second) = @_;
	my $subtract_hours = $first->get_hour() - $second->get_hour();
	my $subtract_minutes = $first->get_minute() - $second->get_minute();
	return new SimpleTime($subtract_hours,$subtract_minutes);
}

sub _compare{
	my ($first, $second) = @_;
	if($first->_less_than($second)){
		return -1;
	}
	elsif($first->_equals($second)){
		return 0;
	}
	else {
		return 1;
	}
}

sub _less_than{
	my ($first, $second) = @_;
	my $less_hours = $first->get_hour() < $second->get_hour();
	my $less_minutes = $first->get_minute() < $second->get_minute();
	
	if($less_hours){
	 return 1;
	}
	else{
		my $equal_hours = $first->get_hour() == $second->get_hour();
		if($equal_hours && $less_minutes){
			return 1;		
		}
		else{
			return 0;
		}
	}
};

sub _equals{
	my ($first, $second) = @_;
	my $equal_hours = $first->get_hour() == $second->get_hour();
	my $equal_minutes = $first->get_minute() == $second->get_minute();
	return $equal_hours && $equal_minutes;
};

1;
