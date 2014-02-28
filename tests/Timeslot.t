#!/usr/bin/perl
use Test::More;
use lib "..";
use Timeslot;

sub get_timeslots(){
	my $start =  DateTime->new( year => 2013,month => 2, day=> 24,hour=> 10, minute => 0, second=> 0);
	my $duration = DateTime::Duration->new(hours=>2);

	my $start2 =  DateTime->new( year => 2013,month => 2, day=> 24,hour=> 11, minute => 0, second=> 0);

	my $early_timeslot = Timeslot->new(_start => $start, _duration=>$duration);
	my $late_timeslot = Timeslot->new(_start => $start2, _duration=>$duration);
	return ($early_timeslot, $late_timeslot);
};

subtest 'timeslot clash early overlap' => sub{
	my ($early_timeslot, $late_timeslot) = get_timeslots();
	ok($early_timeslot->check_clash($late_timeslot));
};

subtest 'timeslot clash late overlap'  => sub{
	my ($early_timeslot, $late_timeslot) = get_timeslots();
	ok($late_timeslot->check_clash($early_timeslot));
};

subtest 'do not cause timeslot clash'  => sub{
	my ($early_timeslot, $late_timeslot) = get_timeslots();
	my $duration = DateTime::Duration->new(hours=>2);

	$late_timeslot->_start($late_timeslot->_start+$duration);

	ok(!$late_timeslot->check_clash($early_timeslot));
};

subtest 'near miss is not a clash'  => sub{
	my ($early_timeslot, $late_timeslot) = get_timeslots();
	my $duration = DateTime::Duration->new(hours=>1);

	$late_timeslot->_start($late_timeslot->_start+$duration);

	ok(!$late_timeslot->check_clash($early_timeslot));
};

done_testing(4);
