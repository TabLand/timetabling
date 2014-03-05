#!/usr/bin/perl
package SimpleTimeslot;
use SimpleTime;
use strict;
use warnings;
use overload
    "\"\"" => \&_to_string,
    "<=>"  => \&compare,
    "cmp"  => \&compare;

sub new{
	my ($class,$start_hour, $start_minute, $duration_hour, $duration_minute) = @_;
	my $self = {_start => new SimpleTime($start_hour, $start_minute),
		    _duration => new SimpleTime($duration_hour, $duration_minute)};
	bless $self, $class;
	return $self;
};

sub create{
	my ($class, $start, $end) = @_;
	my $self = {_start => $start,
		 _duration => $end-$start};
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

sub check_clash{
	my ($first, $second) = @_;

	my $first_starts_later = $first->get_start() > $second->get_start();
	my $second_ends_earlier = $first->get_start() < $second->get_end();

	my $second_starts_later = $second->get_start() > $first->get_start();
	my $first_ends_earlier = $second->get_start() < $first->get_end();

	if($first_starts_later && $second_ends_earlier) {1;}
	elsif($second_starts_later && $first_ends_earlier) {1;}
	else {0;}
}

sub intersect{
	my ($first, $second) = @_;
	my @return = ();

	if($first==$second) {
		push @return, $first;
	}
	elsif($first->check_clash($second)){
		push @return, _slice($first, $second);
	}
	else {
		my ($early, $late) = sort($first, $second);
		push @return, ($early, $late);
	}
	@return;
}

sub _slice{
	my ($first, $second) = @_;
	my @temp_times =();

	push (@temp_times,$first->get_start());
	push (@temp_times,$first->get_end());
	push (@temp_times,$second->get_start());
	push (@temp_times,$second->get_end());
	
	my @sorted_slots = sort ($first, $second);
	my @sorted_times = sort @temp_times;

	my $early = create SimpleTimeslot($sorted_times[0], $sorted_times[1]);
	my $middle = create SimpleTimeslot($sorted_times[1], $sorted_times[2]);
	my $late = create SimpleTimeslot($sorted_times[2], $sorted_times[3]);
	
	return ($early, $middle, $late);
}

sub compare{
	my ($first, $second) = @_;
	
	if($first->get_start() < $second->get_start()){
		return -1;
	}
	else{
		my $same_start = $first->get_start() == $second->get_start();
		my $same_duration = $first->get_duration() == $second->get_duration();
		if($same_start && $same_duration){
			return 0;
		}
		return 1;
	}
}
sub TO_JSON { 
	return { %{ shift() } }; 
}
1;
