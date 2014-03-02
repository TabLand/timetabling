#!/usr/bin/perl
package SimpleTime;
use strict;
use warnings;
use overload
    "\"\"" => \&_to_string,
    "+"    => \&_add,
    "-"    => \&_subtract,
    "=="   => \&_equals,
    "eq"   => \&_string_equals,
    "<"	   => \&_less_than,
    ">"    => \&_more_than,
    ">="   => \&_more_than_eq,
    "<="   => \&_less_than_eq;


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

sub _equals{
	my ($first, $second) = @_;
	my $equal_hours = $first->get_hour() == $second->get_hour();
	my $equal_minutes = $first->get_minute() == $second->get_minute();
	return $equal_hours && $equal_minutes;
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

sub _more_than{
	my ($first, $second) = @_;
	my $less_than = _less_than($first, $second);
	my $equal = _equals($first,$second);
	return not($less_than || $equal);
}

sub _more_than_eq{
	my ($first, $second) = @_;
	my $less_than = _less_than($first, $second);
	return not($less_than);
}

sub _less_than_eq{
	my ($first, $second) = @_;
	my $less_than = _less_than($first, $second);
	my $equals = _equals($first,$second);
	return $less_than || $equals;
}

1;
