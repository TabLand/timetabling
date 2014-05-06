#!/usr/bin/perl -w
package TimetableDB;
use DB_lib;
use RoomDB;
use strict;
use warnings;

sub initialise{
    my $dbh           = shift;
    my $timetable_sql = 'CALL InitialiseTimetableHistory()';
    my $lunch_sql     = 'CALL InitialiseLunchBreaks()';

    my $sth           = $dbh->prepare($timetable_sql);
    $sth->execute 
        or DB_lib::fail($dbh, "Initialise Timetable");

    $sth              = $dbh->prepare($lunch_sql);
    $sth->execute 
        or DB_lib::fail($dbh, "Initialise Lunch");
}

sub change_activity_booking{
    my ($dbh, $unsafe_activity);
    my $safe_activity = validate_activity_booking($unsafe_activity);

    my $sql = "UPDATE TimetableHistory SET Day=?, Start=?, RoomCode=? WHERE ActivityID=? AND RevisionID=?";
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_activity->{"day"}
                 ,$safe_activity->{"start"}
                 ,$safe_activity->{"room"}
                 ,$safe_activity->{"activity_id"}
                 ,$safe_activity->{"revision_id"});
                        or DB_lib::fail($dbh, "Failed to update activity booking");
}

sub change_lunchtime{
    my ($dbh, $unsafe_lunchtime);
    my $safe_lunchtime = validate_lunchtime_booking($unsafe_lunchtime);

    my $sql = "UPDATE 
                    LunchBreak 
              SET 
                    Start=?
              WHERE 
                    Username   = ? 
                AND RevisionID = ?
                AND DayID      = ?";
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_lunchtime->{"start"}
                 ,$safe_lunchtime->{"username"}
                 ,$safe_lunchtime->{"revision_id"}
                 ,$safe_lunchtime->{"day_id"});
                        or DB_lib::fail($dbh, "Failed to update activity booking");
}

sub get_activity_booking_latest{
    my ($dbh, $unsafe_activity_id);
    my $safe_activity_id = validate_id($unsafe_activity_id);

    my $sql = "SELECT
                    RevisionID, ActivityID, Start, Day, RoomCode
               FROM 
                    TimetableHistory 
               WHERE 
                    ActivityID=? AND RevisionID=LatestRevision()";

    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_activity_id)
                        or DB_lib::fail($dbh, "Failed to get latest activity booking");

    if(my @row = $sth->fetchrow_array){
        my $activity_booking = {};
        $activity_booking->{"revision_id"} = $row[0];
        $activity_booking->{"activity_id"} = $row[1];
        $activity_booking->{"start"}       = $row[2];
        $activity_booking->{"day"}         = $row[3];
        $activity_booking->{"room_code"}   = $row[4];
    }
    else{
        DB_lib::fail($dbh, "Failed to fetch rows for latest activity booking");
    }
    return $activity_booking;
}

sub get_lunchtime_booking_latest{
    my ($dbh, $unsafe_username, $unsafe_day_id);
    my $safe_activity_id = validate_id($unsafe_activity_id);
    my $safe_username    = PersonDB::validate_username($unsafe_username);

    my $sql = "SELECT
                    Username, RevisionID, DayID, Start
               FROM 
                    LunchBreak 
               WHERE 
                        Username=? 
                    AND RevisionID=LatestRevision() 
                    AND DayID=?";

    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_activity_id)
                        or DB_lib::fail($dbh, "Failed to get latest lunchtime booking");

    if(my @row = $sth->fetchrow_array){
        my $activity_booking = {};
        $activity_booking->{"username"}    = $row[0];
        $activity_booking->{"revision_id"} = $row[1];
        $activity_booking->{"day_id"}      = $row[2];
        $activity_booking->{"start"}       = $row[3];
    }
    else{
        DB_lib::fail($dbh, "Failed to fetch rows for latest lunchtime booking");
    }
    return $activitiy_booking;
}

sub get_sum_penalties{
    my ($dbh) = @_;
    my $sum_penalties = get_penalty_latest($dbh, "SumPenalties");
    return $sum_penalties;
}

sub get_room_clash_penalty{
    my ($dbh) = @_;
    my $room_clash_penalty = get_penalty_latest($dbh, "SumPenaltiesRoomClash");
    return $room_clash_penalty;
}

sub get_room_over_capacity_penalty{
    my ($dbh) = @_;
    my $room_over_capacity_penalty = get_penalty_latest($dbh, "SumPenaltiesRoomOverCapacity");
    return $room_over_capacity_penalty;
}

sub get_student_clash_penalty{
    my ($dbh) = @_;
    my $student_clash_penalty = get_penalty($dbh, "SumPenaltiesStudentClash");
    return $student_clash_penalty;
}

sub get_staff_clash_penalty{
    my ($dbh) = @_;
    my $staff_clash_penalty = get_penalty_latest($dbh, "SumPenaltiesStaffClash");
    return $staff_clash_penalty;
}

sub get_student_lunch_clash_penalty{
    my ($dbh) = @_;
    my $student_lunch_penalty = get_penalty_latest($dbh, "SumPenaltiesStudentLunch");
    return $student_lunch_penalty;
}

sub get_staff_lunch_clash_penalty{
    my ($dbh) = @_;
    my $staff_lunch_penalty = get_penalty_latest($dbh, "SumPenaltiesStaffLunch");
    return $staff_lunch_penalty;
}

sub get_room_clash_activities{
    my ($dbh) = @_;
    return get_activity_list($dbh, "LatestRoomClashes");
}

sub get_room_over_capacity_activities{
    my ($dbh, $view_name) = @_;
    my $sql               = "SELECT ActivityID,CapacityNeeded FROM LatestRoomOverCapacity";
    my $sth               = $dbh->prepare($sql);

    my $sth->execute()
        or DB_lib::fail($dbh, "While grabbing activities and capacities from LatestRoomOverCapacity");

    my @over_capacities;
    while (my @row = $sth->fetchrow_array) {
        my $over_cap = {};
        $over_cap->{"activity_id"}     = $row[0];
        $over_cap->{"capacity_needed"} = $row[1];
        push @over_capacities, $over_cap;
    }
    return @over_capacities;

}

sub get_student_clash_activities{
    my ($dbh) = @_;
    return get_activity_list($dbh, "LatestStudentClashActivities");
}

sub get_staff_clash_activities{
    my ($dbh) = @_;
    return get_activity_list($dbh, "LatestStaffClashActivities");
}

sub get_student_lunch_clashes{
    my ($dbh) = @_;
    return get_lunch_clashes_list($dbh, "LatestStudentLunchClashes");
}

sub get_staff_lunch_clash_days{
    my ($dbh) = @_;
    return get_lunch_clashes_list($dbh, "LatestStaffLunchClashes");
}

sub get_lunch_clashes_list{
    my ($dbh, $view_name) = @_;
    my $sql               = "SELECT ActivityID, DayID FROM $view_name";
    my $sth               = $dbh->prepare($sql);

    my $sth->execute()
        or DB_lib::fail($dbh, "While grabbing lunch clash from $view_name");

    my @clashing_lunches;
    while (my @row = $sth->fetchrow_array) {
        my $lunch_clash = {};
        $lunch_clash->{"activity_id"} = $row[0];
        $lunch_clash->{"day_id"}      = $row[1];
        push @clashing_lunches, $lunch_clash;
    }
    return @clashing_lunches;
}

sub get_activitiy_list{
    my ($dbh, $view_name) = @_;
    my $sql               = "SELECT ActivityID FROM $view_name";
    my $sth               = $dbh->prepare($sql);

    my $sth->execute()
        or DB_lib::fail($dbh, "While grabbing activity list from $view_name");

    my @clashing_activities;
    while (my @row = $sth->fetchrow_array) {
        push @clashing_activities, $row[0];
    }
    return @clashing_activities;
}

sub get_latest_penalty{
    my ($dbh, $view_name) = @_;

    my $sql             = "SELECT $view_name(LatestRevision())";
    my $sth             = $dbh->prepare($sql);

    my $sth->execute()
        or DB_lib::fail($dbh, "Get $view_name");

    while (my @row = $sth->fetchrow_array) {
        $row_count += 1;
        $penalty = $row[0];
    }

    my $too_many_or_too_little_rows_returned = ($row_count != 1);

    if($too_many_or_too_little_rows_returned){
        die "While fetching from $view_name, too many rows returned: $row_count";
    }
    else{
        return $penalty;
    }
}

sub validate_activity_booking{
    my $unsafe_a_b = shift;
    my $safe_a_b = {};

    my $unsafe_activity_id = $unsafe_a_b->{"activity_id"};
    my $unsafe_revision_id = $unsafe_a_b->{"revision_id"};
    my $unsafe_start       = $unsafe_a_b->{"start"};
    my $unsafe_day         = $unsafe_a_b->{"day"};
    my $unsafe_room        = $unsafe_a_b->{"room"};

    $safe_a_b->{"activity_id"} = validate_id($unsafe_activity_id);
    $safe_a_b->{"revision_id"} = validate_id($unsafe_revision_id);
    $safe_a_b->{"start"}       = validate_start($unsafe_start);
    $safe_a_b->{"day"}         = validate_day($unsafe_day);
    $safe_a_b->{"room"}        = RoomDB::validate_code($unsafe_room);

    return $safe_a_b;
}

sub validate_id{
    my $id = shift;

    if($id =~ /[^0-9]/){
        die "invalid id $id";
    };
    return $id;
}

sub validate_start{
    my $start = shift;
    
    if($start =~ /[^0-9\.]/){
        die "invalid start given $start";
    }
    
    my $start = $start;
    return $start;
}

sub validate_day{
    my $day = shift;
    if($day =~ /[^0-9]/ || $day < 0 || $day > 6){
        die "invalid duration $day";
    }
    return $day;
}

1;
