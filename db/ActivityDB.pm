#!/usr/bin/perl -w
package ActivityDB;
use DB_lib;
use ModuleDB;
use strict;
use warnings;

sub get_function_ref_hash_ref{
    my $function_ref = {"add" => \&add,
                        "edit" => \&edit,
                        "delete" => \&del};
    return $function_ref;
}

sub get_id{
    my ($unsafe_activity, $dbh) = @_;
    my $safe_activity = validate_activity($unsafe_activity);
    my $sql           = 'SELECT ActivityID FROM Activity WHERE ModuleCode=? AND Type=? AND ActivityGroup=?';
    my $sth           = $dbh->prepare($sql);

    $sth->execute($safe_activity->{"code"}, $safe_activity->{"type"}, $safe_activity->{"group"})
                    or DB_lib::fail($dbh, "Activity Get ID");
    my $row_count = 0;
    my $activity_id;

    while (my @row = $sth->fetchrow_array) {
        $row_count += 1;
        $activity_id = $row[0];
    }

    my $too_many_or_too_little_rows_returned = ($row_count != 1);

    if($too_many_or_too_little_rows_returned){
        die "Activity not found, or duplicates snuck in?? Row count $row_count";
    }
    else{
        return $activity_id;
    }    
}

sub add{
    my ($unsafe_activity, $dbh) = @_;

    my $safe_activity = validate_activity($unsafe_activity);

    my $sql           = 'INSERT INTO Activity (ModuleCode, Type, ActivityGroup, Duration) '
                          . 'VALUES (?,?,?,?)';
    my $sth           = $dbh->prepare($sql);

    $sth->execute($safe_activity->{"code"}, $safe_activity->{"type"}
                  , $safe_activity->{"group"}, $safe_activity->{"duration"})
                    or DB_lib::fail($dbh, "Activity Add");
    return $sth;
}

sub edit{
    my ($unsafe_old_activity, $unsafe_new_activity, $dbh) = @_;
    my $safe_new_activity = validate_activity($unsafe_new_activity);
    my $safe_old_activity = validate_activity($unsafe_old_activity);

    my $sql = 'UPDATE Activity SET ModuleCode=?, Type=?, ActivityGroup=?, Duration=? ' 
              . 'WHERE ModuleCode=? AND Type=? AND ActivityGroup=? AND Duration=?';
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_new_activity->{"code"}, $safe_new_activity->{"type"}
                 , $safe_new_activity->{"group"}, $safe_new_activity->{"duration"}
                 , $safe_old_activity->{"code"}, $safe_old_activity->{"type"}
                 , $safe_old_activity->{"group"}, $safe_old_activity->{"duration"})
                    or DB_lib::fail($dbh, "Activity Edit");
    return $sth;
}

sub del{
    my ($unsafe_activity, $dbh)  = @_;

    my $safe_activity = validate_activity($unsafe_activity);
    my $sql         = 'DELETE FROM Activity WHERE ModuleCode=? AND Type=?'
                      . ' AND ActivityGroup=? AND Duration=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($safe_activity->{"code"}, $safe_activity->{"type"}
                 , $safe_activity->{"group"}, $safe_activity->{"duration"})
                    or DB_lib::fail($dbh, "Activity Delete");
    return $sth;
}

sub select_all{
    my ($dbh) = shift;

    my $sql = 'SELECT Module.Code, Module.Name' 
            . ', Activity.Type, Activity.ActivityGroup, Activity.Duration'
            . ' FROM Activity, Module WHERE Activity.ModuleCode = Module.Code';
    my $sth = $dbh->prepare($sql);
    $sth->execute()
                    or DB_lib::fail($dbh, "Activity Select All");
    return $sth;
}

sub validate_activity{
    my $unsafe_activity    = shift;
    my $safe_activity      = {};

    my $unsafe_code        = $unsafe_activity->{"code"};
    my $unsafe_group       = $unsafe_activity->{"group"};
    my $unsafe_type        = $unsafe_activity->{"type"};
    my $unsafe_duration    = $unsafe_activity->{"duration"};

    $safe_activity->{"code"}     = validate_code($unsafe_code);
    $safe_activity->{"group"}    = validate_text($unsafe_group);
    $safe_activity->{"type"}     = validate_text($unsafe_type);
    $safe_activity->{"duration"} = validate_duration($unsafe_duration);

    return $safe_activity;
}

sub validate_code{
    my $unsafe_code = shift;
    my @code        = split('-', $unsafe_code);
    if(@code != 2){
        die "Malformed Module code string $unsafe_code sent";
    }
    return ModuleDB::validate_code($code[0]);
}

sub validate_text{
    my $unsafe_text = shift;
    $unsafe_text =~ s/[^A-Za-z\ ]//g;
    my $safe_text = $unsafe_text;
    return $safe_text;
}

sub validate_duration{
    my $unsafe_duration = shift;
    $unsafe_duration =~ s/[^0-9\.]//g;

    if($unsafe_duration <0 || $unsafe_duration >=24){
        die "Received unsafe duration: $unsafe_duration";
    }
    my $safe_duration = $unsafe_duration;
    return  $safe_duration;
}

1;
