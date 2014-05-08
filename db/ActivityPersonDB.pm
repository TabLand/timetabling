#!/usr/bin/perl -w
package ActivityPersonDB;
use ActivityDB;
use PersonDB;
use strict;
use warnings;

sub get_function_ref_hash_ref{
    my $function_ref = {'add' => \&add,
                        'edit' => \&edit,
                        'delete' => \&del};
    return $function_ref;
}

sub add{
    my ($unsafe_a_p, $dbh) = @_;
    my $better_unsafe_a_p  = split_a_p($unsafe_a_p);

    my $safe_username    = PersonDB::validate_username($better_unsafe_a_p->{'username'});
    my $safe_activity_id = ActivityDB::get_id($better_unsafe_a_p->{'activity'},$dbh);
    
    my $sql = 'INSERT INTO ActivityPerson (ActivityID,Username) VALUES (?,?)';
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_activity_id, $safe_username)
                    or DB_lib::fail($dbh, 'Activity Person Add');
    return $sth;
}

sub edit{
    my ($unsafe_old_a_p, $unsafe_new_a_p, $dbh) = @_;

    my $better_unsafe_new_a_p = split_a_p($unsafe_new_a_p);
    my $better_unsafe_old_a_p = split_a_p($unsafe_old_a_p);

    my $safe_new_username    = PersonDB::validate_username($better_unsafe_new_a_p->{'username'});
    my $safe_old_username    = PersonDB::validate_username($better_unsafe_old_a_p->{'username'});

    my $safe_new_activity_id = ActivityDB::get_id($better_unsafe_new_a_p->{'activity'},$dbh);
    my $safe_old_activity_id = ActivityDB::get_id($better_unsafe_old_a_p->{'activity'},$dbh);

    my $sql             = 'UPDATE ActivityPerson SET ActivityID=?, Username=? WHERE ActivityID=? AND Username=?';
    my $sth             = $dbh->prepare($sql);
    $sth->execute($safe_new_activity_id, $safe_new_username,
                 ,$safe_old_activity_id, $safe_old_username)
                    or DB_lib::fail($dbh, 'Activity Person Edit');
    return $sth;
}

sub del{
    my ($unsafe_a_p, $dbh) = @_;
    my $better_unsafe_a_p  = split_a_p($unsafe_a_p);

    my $safe_username    = PersonDB::validate_username($better_unsafe_a_p->{'username'});
    my $safe_activity_id = ActivityDB::get_id($better_unsafe_a_p->{'activity'},$dbh);

    my $sql         = 'DELETE FROM ActivityPerson WHERE ActivityID=? AND Username=?';

    my $sth         = $dbh->prepare($sql);
    $sth->execute($safe_activity_id, $safe_username)
                    or DB_lib::fail($dbh, 'Activity Person Delete');
    return $sth;
}

sub select_all{
    my ($dbh)   = shift;
    my $sql     = 'SELECT Module.Code, Module.Name' 
                . ', Activity.Type, Activity.ActivityGroup'
                . ', Person.Username, Person.Name'
                . ' FROM Module, Activity, Person, ActivityPerson'
                . ' WHERE Person.Username     = ActivityPerson.Username'
                . ' AND   Activity.ActivityID = ActivityPerson.ActivityID'
                . ' AND   Module.Code         = Activity.ModuleCode';
    my $sth     = $dbh->prepare($sql);
    $sth->execute
            or DB_lib::fail($dbh, 'Activity Person Select All');
    return $sth;
}

sub get_all_activities_for_person{
    my ($dbh, $unsafe_username) = @_;
    my $safe_username           = PersonDB::validate_username($unsafe_username); 

    my $sql = "SELECT ActivityID FROM ActivityPerson WHERE Username=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($safe_username)
            or DB_lib::fail($dbh, 'Get all activities for person');

    my @activity_ids;

    while(my @row = $sth->fetchrow_array){
        my $activity_id = $row[0];
        push @activity_ids, $activity_id;
    }

    return @activity_ids;
}

sub split_a_p{
    my $a_p          = shift;
    my $new_a_p      = {};
    my $activity_ref = {};

    my $person_string = $a_p->{'person'};
    my @person        = split('-', $person_string);
    if(@person != 2){
        die "Malformed person string \"$person_string\" sent";
    }

    $new_a_p->{'username'} = $person[0];
    $new_a_p->{'name'}     = $person[1];

    my $activity_string = $a_p->{'activity'};
    my @activity = split('-', $activity_string);
    if(@activity != 4){
        die "Malformed activity string \"$activity_string\" sent";
    }

    my $stub_duration = "00:00";
    #ActivityDB.pm can only validate codes in the format ModuleCode-ModuleName
    $activity_ref->{'code'}     = $activity[0] . '-' . $activity[1];
    $activity_ref->{'type'}     = $activity[2];
    $activity_ref->{'group'}    = $activity[3];
    $activity_ref->{'duration'} = $stub_duration;

    $new_a_p->{'activity'} = $activity_ref;
    return $new_a_p;
}

1;
