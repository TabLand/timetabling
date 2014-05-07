#!/usr/bin/perl -w
package TimetableDB;
use DB_lib;
use RoomDB;
use PersonDB;
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

sub increment_revisions{
    my $dbh           = shift;
    my $timetable_sql = 'CALL IncrementTimetableRevision()';
    my $lunch_sql     = 'CALL IncrementLunchBreakRevision()';

    my $sth           = $dbh->prepare($timetable_sql);
    $sth->execute 
        or DB_lib::fail($dbh, "Increment Timetable");

    $sth              = $dbh->prepare($lunch_sql);
    $sth->execute 
        or DB_lib::fail($dbh, "Increment Lunch");
}

sub change_activity_booking{
    my ($dbh, $unsafe_activity) = @_;
    my $safe_activity = validate_activity_booking($unsafe_activity);

    my $sql = "UPDATE TimetableHistory SET Day=?, Start=?, RoomCode=? WHERE ActivityID=? AND RevisionID=?";
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_activity->{"day"}
                 ,$safe_activity->{"start"}
                 ,$safe_activity->{"room_code"}
                 ,$safe_activity->{"activity_id"}
                 ,$safe_activity->{"revision_id"})
                        or DB_lib::fail($dbh, "Failed to update activity booking");
}

sub change_lunchtime{
    my ($dbh, $unsafe_lunchtime) = @_;
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
                 ,$safe_lunchtime->{"day_id"})
                        or DB_lib::fail($dbh, "Failed to update activity booking");
}

sub get_activity_booking_latest{
    my ($dbh, $unsafe_activity_id) = @_;
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

    my $activity_booking = {};
    if(my @row = $sth->fetchrow_array){
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
    my ($dbh, $unsafe_username, $unsafe_day_id) = @_;
    my $safe_day_id = validate_day($unsafe_day_id);
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

    $sth->execute($safe_username, $safe_day_id)
                        or DB_lib::fail($dbh, "Failed to get latest lunchtime booking");
    my $activity_booking = {};
    if(my @row = $sth->fetchrow_array){
        $activity_booking->{"username"}    = $row[0];
        $activity_booking->{"revision_id"} = $row[1];
        $activity_booking->{"day_id"}      = $row[2];
        $activity_booking->{"start"}       = $row[3];
    }
    else{
        DB_lib::fail($dbh, "Failed to fetch rows for latest lunchtime booking");
    }
    return $activity_booking;
}

sub get_sum_penalties{
    my ($dbh) = @_;
    my $sum_penalties = get_latest_penalty($dbh, "SumPenalties");
    return $sum_penalties;
}

sub get_room_clash_penalty{
    my ($dbh) = @_;
    my $room_clash_penalty = get_latest_penalty($dbh, "SumPenaltiesRoomClash");
    return $room_clash_penalty;
}

sub get_room_over_capacity_penalty{
    my ($dbh) = @_;
    my $room_over_capacity_penalty = get_latest_penalty($dbh, "SumPenaltiesRoomOverCapacity");
    return $room_over_capacity_penalty;
}

sub get_student_clash_penalty{
    my ($dbh) = @_;
    my $student_clash_penalty = get_latest_penalty($dbh, "SumPenaltiesStudentClash");
    return $student_clash_penalty;
}

sub get_staff_clash_penalty{
    my ($dbh) = @_;
    my $staff_clash_penalty = get_latest_penalty($dbh, "SumPenaltiesStaffClash");
    return $staff_clash_penalty;
}

sub get_student_lunch_clash_penalty{
    my ($dbh) = @_;
    my $student_lunch_penalty = get_latest_penalty($dbh, "SumPenaltiesStudentLunch");
    return $student_lunch_penalty;
}

sub get_staff_lunch_clash_penalty{
    my ($dbh) = @_;
    my $staff_lunch_penalty = get_latest_penalty($dbh, "SumPenaltiesStaffLunch");
    return $staff_lunch_penalty;
}

sub get_room_clash_activities{
    my ($dbh) = @_;
    return get_activity_list($dbh, "LatestRoomClashes");
}

sub get_room_over_capacity_activities{
    my ($dbh) = @_;
    return get_activity_list($dbh, "LatestRoomOverCapacity");
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

sub get_staff_lunch_clashes{
    my ($dbh) = @_;
    return get_lunch_clashes_list($dbh, "LatestStaffLunchClashes");
}

sub get_lunch_clashes_list{
    my ($dbh, $view_name) = @_;
    my $sql               = "SELECT ActivityID, DayID, Username FROM $view_name";
    my $sth               = $dbh->prepare($sql);

    $sth->execute()
        or DB_lib::fail($dbh, "While grabbing lunch clash from $view_name");

    my @clashing_lunches;
    while (my @row = $sth->fetchrow_array) {
        my $lunch_clash = {};
        $lunch_clash->{"activity_id"} = $row[0];
        $lunch_clash->{"day_id"}      = $row[1];
        $lunch_clash->{"username"}    = $row[2];
        push @clashing_lunches, $lunch_clash;
    }
    return @clashing_lunches;
}

sub get_activity_list{
    my ($dbh, $view_name) = @_;
    my $sql               = "SELECT ActivityID FROM $view_name";
    my $sth               = $dbh->prepare($sql);

    $sth->execute()
        or DB_lib::fail($dbh, "While grabbing activity list from $view_name");

    my @clashing_activities;
    while (my @row = $sth->fetchrow_array) {
        push @clashing_activities, $row[0];
    }
    return @clashing_activities;
}

sub get_room_replacements{
    my ($dbh, $unsafe_activity_id) = @_;
    my $safe_activity_id           = validate_id($unsafe_activity_id);
    my $sql                        = "SELECT Code FROM RoomReplacements WHERE ActivityID = ?";
    my $sth                        = $dbh->prepare($sql);

    $sth->execute($safe_activity_id)
        or DB_lib::fail($dbh, "Screwed up while grabbing room replacements");

    my @room_replacements;
    while (my @row = $sth->fetchrow_array) {
        my $room_replacement = $row[0];
        push @room_replacements, $room_replacement;
    }
    return @room_replacements;
}

sub get_latest_penalty{
    my ($dbh, $func_name) = @_;

    my $sql             = "SELECT $func_name(LatestRevision())";
    my $sth             = $dbh->prepare($sql);

    $sth->execute()
        or DB_lib::fail($dbh, "Get $func_name");
    my $penalty =0;
    if (my @row = $sth->fetchrow_array) {
        $penalty = $row[0];
    }
    else {
        die "While fetching from $func_name, no rows returned";
    }

    return $penalty;
}

sub validate_lunchtime_booking{
    my $unsafe_l_b = shift;
    my $safe_l_b = {};

    my $unsafe_start    = $unsafe_l_b->{"start"};
    my $unsafe_revision = $unsafe_l_b->{"revision_id"};
    my $unsafe_username = $unsafe_l_b->{"username"};
    my $unsafe_day_id   = $unsafe_l_b->{"day_id"};

    $safe_l_b->{"start"}       = validate_start($unsafe_start);
    $safe_l_b->{"revision_id"} = validate_id($unsafe_revision);
    $safe_l_b->{"username"}    = PersonDB::validate_username($unsafe_username);
    $safe_l_b->{"day_id"}      = validate_day($unsafe_day_id);

    return $safe_l_b;
}

sub validate_activity_booking{
    my $unsafe_a_b = shift;
    my $safe_a_b = {};

    my $unsafe_activity_id = $unsafe_a_b->{"activity_id"};
    my $unsafe_revision_id = $unsafe_a_b->{"revision_id"};
    my $unsafe_start       = $unsafe_a_b->{"start"};
    my $unsafe_day         = $unsafe_a_b->{"day"};
    my $unsafe_room        = $unsafe_a_b->{"room_code"};

    $safe_a_b->{"activity_id"} = validate_id($unsafe_activity_id);
    $safe_a_b->{"revision_id"} = validate_id($unsafe_revision_id);
    $safe_a_b->{"start"}       = validate_start($unsafe_start);
    $safe_a_b->{"day"}         = validate_day($unsafe_day);
    $safe_a_b->{"room_code"}        = RoomDB::validate_code($unsafe_room);

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
