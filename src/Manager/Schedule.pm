#!/usr/bin/perl
package Schedule;
use Activity;
use strict;
use warnings;
use overload    "\"\"" => \&to_string;
sub new{
	my ($class, $resource_type, $resource_id, $revision_id) = @_;
	my $self = {_activities    => (),
                _resource_type => $resource_type,
                _resource_id   => $resource_id,
                _revision_id   => $revision_id, };
	bless $self, $class;
	return $self;
}
sub add_activity{
	my ($self, $activity) = @_;
	push $self->{_activities}, $activity;
}

sub get_resource_type{
    my $self = shift;
    return $self->{_resource_type};
}

sub get_resource_id{
    my $self = shift;
    return $self->{_resource_id};
}

sub get_revision_id{
    my $self = shift;
    return $self->{_revision_id};
}

sub get_activity_ids{
	my $self = shift;
	my @activities = $self->get_activities();
    my @ids;
    
    for my $activity (@activities){
        push @ids, $activity->get_id();
    }
    
    return @ids;
}

sub get_activities{
	my $self = shift;
	my @activities = $self->{_activities};
	return @activities;
}

sub get_activity_numbers{
	my $self = shift;
	return $self->{_activities};
}

sub get_clashes{
	my $self = shift;
	my @activity_ids = $self->get_activity_ids();

    my $clash_holder = new Schedule($self->get_resource_type() ." Clash", $self->get_resource_id());

	return $clash_holder;
}
sub get_between{
	my ($self, $time_period) = @_;
	my @activities = $self->get_sorted_activities();
 	my $between_list = new Schedule();
	if(@activities >=2){
		for(my $i=0; $i<@activities; $i++){
			my $activity = $activities[$i];
			my $in_between = $activity->check_clash_time_only($time_period);
			if($in_between){
				$between_list->add_activity($activity);
			}
		}
	}
	return $between_list;
}
sub get_sorted_activities{
	my $self = shift;
	my @sorted = sort $self->get_activities();
	return @sorted;
}

sub to_string{
	my $self = shift;
	my @activities = $self->get_sorted_activities();
	my $return = "Schedule(";
	foreach my $activity (@activities){
		$return .= "\t" . $activity->to_string() . "\n";
	}
	$return .= ")";
	$return;
}
1;
