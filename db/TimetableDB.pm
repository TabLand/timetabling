#!/usr/bin/perl -w
package TimetableDB;
use DB_lib;
use strict;
use warnings;

sub add{
    my ($unsafe_a_b, $dbh) = @_;

    my $safe_a_b = validate_activity_booking($unsafe_a_b);

    my $sql           = 'INSERT INTO TimetableHistory (RevisionID, ActivityID, Start, Day, RoomCode) '
                          . 'VALUES (?,?,?,?,?)';
    my $sth           = $dbh->prepare($sql);

    $sth->execute($safe_a_b->{"revision_id"}, $safe_a_b->{"activity_id"}
                  , $safe_a_b->{"start"}, $safe_a_b->{"day"}, $safe_a_b->{"room"})
                    or DB_lib::fail($dbh, "Timetable History Add");
    return $sth;
}

sub del{
    my ($unsafe_activity, $dbh)  = @_;

    my $safe_a_b = validate_activity_booking($unsafe_a_b);
    my $sql         = 'DELETE FROM TimetableHistory WHERE RevisionID=? AND ActivityID=?'
                      . ' AND Start=? AND Day=? AND RoomCode=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($safe_a_b->{"revision_id"}, $safe_a_b->{"activity_id"}
                  , $safe_a_b->{"start"}, $safe_a_b->{"day"}, $safe_a_b->{"room"})
                    or DB_lib::fail($dbh, "Timetable History Delete");
    return $sth;
}

sub select_all{
    my ($dbh, $unsafe_revision_id) = @_;
    my $safe_revision_id = validate_id($unsafe_revision_id);

    my $sql = 'SELECT ActivityID, Start, Day, RoomCode FROM TimetableHistory WHERE RevisionID=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($safe_revision_id)
                    or DB_lib::fail($dbh, "Activity Select All");
    return $sth;
}

sub check_clashes{
    my ($dbh, $unsafe_revision_id) = @_;
    my $safe_revision_id = validate_id($unsafe_revision_id);

    my $sql = 'SELECT ActivityBookingsA.ActivityID, ActivityBookingsA.Start, ActivityBookings.End 
               FROM
                    (SELECT T.ActivityID,T.Start, (T.Start+A.Duration) AS End 
                    FROM 
                        TimetableHistory AS T, Activity AS A 
                    WHERE 
                        T.RevisionID=? AND T.ActivityID IN (?)) 
                    AS ActivityBookingsA, ActivityBookingsA AS ActivityBookingsB

                WHERE   ActivityBookingsA.ActivityID != ActivityBookingsB.ActivityID AND
                        ActivityBookingsA.End > ActivityBookingsB.Start AND 
                        ActivityBookingsA.End <= ActivityBookingsB.End OR
                        ActivityBookingsB.End > ActivityBookingsA.Start AND 
                        ActivityBookingsB.End <= ActivityBookingsA.Start';
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
