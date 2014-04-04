#!/usr/bin/perl
package SimpleTimeslot;
use SimpleTime;
use Term;
use Day;
use strict;
use warnings;
use overload
    "\"\"" => \&to_string,
    "<=>"  => \&compare,
    "cmp"  => \&compare;

sub new{
	my ($class, $day, $term, $start_hour, $start_minute, $duration_hour, $duration_minute) = @_;
	my $self = {_start => new SimpleTime($start_hour, $start_minute),
		    _duration => new SimpleTime($duration_hour, $duration_minute),
		    _term => Term::number($term),
		    _day => Day::number($day)};
	bless $self, $class;
	return $self;
};

sub get_start{
	my $self = shift;
	return $self->{_start};
};
sub get_duration{
	my $self = shift;
	return $self->{_duration};
};
sub get_end{
	my $self = shift;
	return $self->{_start} + $self->{_duration};
};
sub get_day{
	my $self = shift;
	return Day::pretty($self->{_day});
}
sub get_term{
	my $self = shift;
	return Term::pretty($self->{_term});
}
sub get_day_number{
	my $self = shift;
	return $self->{_day};
}
sub get_term_number{
	my $self = shift;
	return $self->{_term};
}
sub set_start{
	my ($self, $hour, $minute) = @_;
	$self->{_start} = new SimpleTime($hour, $minute);
}
sub set_duration{
	my ($self, $hour, $minute) = @_;
	$self->{_duration} = new SimpleTime($hour, $minute);
}
sub set_day{
	my ($self, $day) = @_;
	$self->{_day} = Day::number($day);
}
sub set_term{
	my ($self, $term) = @_;
	$self->{_term} = $term;
}
sub check_clash{
	my ($first, $second) = @_;

	my $same_day = $first->get_day() eq $second->get_day();
	my $same_term = $first->get_term_number() eq $second->get_term_number();

	my $time_clash = $first->check_clash_time_only($second);

	if($time_clash && $same_day && $same_term) {1;}
	else {0;}
}
sub check_clash_time_only{
	my ($first, $second) = @_;

	my $first_starts_later = $first->get_start() >= $second->get_start();
	my $second_ends_earlier = $first->get_start() < $second->get_end();

	my $second_starts_later = $second->get_start() >= $first->get_start();
	my $first_ends_earlier = $second->get_start() < $first->get_end();

	if($first_starts_later && $second_ends_earlier) {1;}
	elsif($second_starts_later && $first_ends_earlier) {1;}
	else {0;}
}
sub compare{
	my ($first, $second) = @_;

	my $same_day = $first->get_day_number() == $second->get_day_number();
	my $same_term = $first->get_term_number() == $second->get_term_number();

	if($first->get_term_number() < $second->get_term_number()){ -1;}
	elsif($first->get_term_number() > $second->get_term_number()){1;}
	elsif($first->get_day_number() < $second->get_day_number()){-1;}
	elsif($first->get_day_number() > $second->get_day_number()){1;}
	else {
		if($first->get_start() < $second->get_start()){
			return -1;
		}
		else{
			my $same_start = $first->get_start() == $second->get_start();
			my $same_duration = $first->get_duration() == $second->get_duration();
	
			if($same_start && $same_duration && $same_term && $same_day){
				return 0;
			}
			return 1;
		}
	}
}
sub equals{
	my ($first, $second) = @_;
	return $first == $second;
}
sub TO_JSON { 
	return { %{ shift() } }; 
}
sub to_string{
	my $self = shift;
	my $term = $self->get_term();
	my $day = $self->get_day();
	my $start = $self->get_start();
	my $end = $self->get_end();
	return "$day - $term / $start to $end";
}
1;
