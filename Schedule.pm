#!/usr/bin/perl
package Schedule;
use Activity;
use strict;
use warnings;
use overload    "\"\"" => \&to_string;
sub new{
	my $class = shift;
	my $self = {_activities=>{}};
	bless $self, $class;
	return $self;
}
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
sub get_clashes{
	my $self = shift;
	my @activities = sort (values $self->{_activities});
 	my $clash_holder = new Schedule();
	if(@activities >=2){
		for(my $i=0; $i<@activities-1; $i++){
			my $before = $activities[$i];
			my $after = $activities[$i+1];
			my $clashes = $before->check_clash($after);
			my $doesnt_exist_prior = !$clash_holder->exists_activity($before);
			if($clashes && $doesnt_exist_prior){
				$clash_holder->add_activity($before);
				$clash_holder->add_activity($after);
			}
			elsif($clashes){
				$clash_holder->add_activity($after);
			}
		}
	}
	return $clash_holder;
}
sub clash_info{
	die "Should've been called from child";
}
sub to_string{
	my $self = shift;
	my @activities = sort (values $self->{_activities});
	my $return = "ActivityHolder(";
	foreach my $activity (@activities){
		$return .= "\t" . $activity->to_string() . "\n";
	}
	$return .= ")";
	$return;
}
1;
