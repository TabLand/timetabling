#!/usr/bin/perl
package SimpleTimeslot;
use SimpleTime;
use overload
    "\"\"" => \&_to_string,
    "<=>"  => \&compare,
    "cmp"  => \&compare;

sub new{
	$class = shift;
	$self = {_start => new SimpleTime(shift, shift),
		 _duration => new SimpleTime(shift, shift)};
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
		my ($early, $late) = sort($first, $second);
	}
	else {
		my ($early, $late) = sort($first, $second);
	}
	
}

	my ($first, $second) = @_;



	
}

1;
