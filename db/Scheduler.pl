#!/usr/bin/perl -w
use TimetableDB;
use DB_lib;
use HTTP_lib;
use Readonly;
Readonly my $TIME_STEP     => 1;
Readonly my $DEBUG_ENABLED => 1;
use Data::Dumper;

schedule();

sub schedule{
    $| = 1;
    my $dbh = DB_lib::connect();

    TimetableDB::increment_revisions($dbh);
    my $sum_penalty = TimetableDB::get_sum_penalties($dbh);
    HTTP_lib::send_plain_text_headers();
    while($sum_penalty>0){
        debug("Old Sum Penalty: $sum_penalty");
        debug("Reducing Room Clashes ****************************");
        reduce_room_clashes($dbh);
        debug("Reducing Room OverCapacity ****************************");
        reduce_room_over_capacity($dbh);
        debug("Reducing Staff Activity Clashes ****************************");
        reduce_staff_activity_clashes($dbh);
        debug("Reducing Student Activity Clashes ****************************");
        reduce_student_activity_clashes($dbh);
        debug("Reducing Staff Lunch Clashes ****************************");
        reduce_staff_lunch_clashes($dbh);
        debug("Reducing Student Lunch Clashes ****************************");
        reduce_student_lunch_clashes($dbh);

        my $new_sum_penalty = TimetableDB::get_sum_penalties($dbh);
        debug("New Master Sum Penalty: $new_sum_penalty");
        if($new_sum_penalty >= $sum_penalty){
            debug("Failed to change timetable quality in last revision, deadlock possibly reached");
        }
        else{
            $sum_penalty = $new_sum_penalty;
        }
    }
    DB_lib::disconnect($dbh);
    debug("Finished Scheduling, woohoo!!");
}

sub reduce_room_clashes{
    my $dbh = shift;
    my $penalty_func_ref = \&TimetableDB::get_room_clash_penalty;

    my @room_clashing_activities = TimetableDB::get_room_clash_activities($dbh);
    improve_rooms($dbh, \@room_clashing_activities, $penalty_func_ref, 1);
}

sub reduce_room_over_capacity{
    my $dbh = shift;
    my $penalty_func_ref = \&TimetableDB::get_room_over_capacity_penalty;

    my @room_over_capacity_activities = TimetableDB::get_room_over_capacity_activities($dbh);
    improve_rooms($dbh, \@room_over_capacity_activities, $penalty_func_ref, 0);
}

sub reduce_staff_activity_clashes{
    my $dbh = shift;
    my $penalty_func_ref = \&TimetableDB::get_staff_clash_penalty;
    
    my @staff_clash_activities = TimetableDB::get_staff_clash_activities($dbh);
    improve_activities($dbh, \@staff_clash_activities, $penalty_func_ref);
}

sub reduce_student_activity_clashes{
    my $dbh = shift;
    my $penalty_func_ref = \&TimetableDB::get_student_clash_penalty;

    my @student_clash_activities = TimetableDB::get_student_clash_activities($dbh);
    improve_activities($dbh, \@student_clash_activities, $penalty_func_ref);
}

sub reduce_staff_lunch_clashes{
    my $dbh = shift;
    my $penalty_func_ref = \&TimetableDB::get_staff_lunch_clash_penalty;
    
    my @staff_lunch_clashes   = TimetableDB::get_staff_lunch_clashes($dbh);
    improve_lunchtimes_and_activities($dbh, \@staff_lunch_clashes, $penalty_func_ref);
}

sub reduce_student_lunch_clashes{
    my $dbh = shift;
    my $penalty_func_ref = \&TimetableDB::get_student_lunch_clash_penalty;

    my @student_lunch_clashes   = TimetableDB::get_student_lunch_clashes($dbh);
    improve_lunchtimes_and_activities($dbh, \@student_lunch_clashes, $penalty_func_ref);
}

sub improve_activities{
    my ($dbh, $activity_list_ref, $penalty_func_ref) = @_;
    my @activities = @$activity_list_ref;

    for my $activity_id (@activities){
        my $sum_penalty = $penalty_func_ref->($dbh);
        while($sum_penalty > 0){
            improve_activity($dbh, $activity_id);
            my $new_sum_penalty = $penalty_func_ref->($dbh);
            if($new_sum_penalty < $sum_penalty){
                return;
            }
        }
    }
}

sub improve_lunchtimes_and_activities{
    my ($dbh, $lunch_clash_list_ref, $penalty_func_ref) = @_;
    my @lunch_clashes = @$lunch_clash_list_ref;

    for my $lunch_clash (@lunch_clashes){
        my $sum_penalty = $penalty_func_ref->($dbh);
        while($sum_penalty > 0){
            improve_lunchtime($dbh, $lunch_clash);
            my $new_sum_penalty = $penalty_func_ref->($dbh);
            if($new_sum_penalty >0) {
                improve_activity($dbh, $lunch_clash->{"activity_id"});
            }
            if($new_sum_penalty < $sum_penalty){
                return;
            }
        }
    }
}

sub improve_rooms{
    my ($dbh, $activity_list_ref, $penalty_func_ref, $improve_activity_flag) = @_;
    my @activities = @$activity_list_ref;

    for my $activity_id (@activities){
        my $sum_penalty = $penalty_func_ref->($dbh);

        while($sum_penalty > 0){
            improve_room($dbh, $activity_id, $improve_activity_flag);
            my $new_sum_penalty = $penalty_func_ref->($dbh);
            if($new_sum_penalty < $sum_penalty){
                return;
            }
        }
    }
}

sub improve_activity{
    my ($dbh, $activity_id) = @_;
    debug("Improving single activity");
    my $sum_penalty     = TimetableDB::get_sum_penalties($dbh);
    my $best_booking    = TimetableDB::get_activity_booking_latest($dbh, $activity_id);
    my $current_booking = TimetableDB::get_activity_booking_latest($dbh, $activity_id);

    DAY_LOOP: for(my $day = 1; $day < 6; $day++){
        TIME_LOOP: for(my $start = 9; $start <= 17; $start = $TIME_STEP + $start){
            $current_booking->{"start"} = $start;
            $current_booking->{"day"}   = $day;

            TimetableDB::change_activity_booking($dbh, $current_booking);
            my $new_sum_penalty = TimetableDB::get_sum_penalties($dbh);

            debug_activity($current_booking, $new_sum_penalty);

            if($new_sum_penalty < $sum_penalty){
                $sum_penalty  = $new_sum_penalty;
                $best_booking = TimetableDB::get_activity_booking_latest($dbh, $activity_id);
                TimetableDB::increment_revisions($dbh);
                last DAY_LOOP;
            }
            if($new_sum_penalty == 0){
                last DAY_LOOP;
            }
        }
    }
    TimetableDB::change_activity_booking($dbh, $best_booking);
}

sub improve_lunchtime{
    my ($dbh, $lunchtime) = @_;
    debug("Improving single lunchtime");
    my $sum_penalty   = TimetableDB::get_sum_penalties($dbh);
    my $username      = $lunchtime->{"username"};
    my $day_id        = $lunchtime->{"day_id"};
    my $best_lunch    = TimetableDB::get_lunchtime_booking_latest($dbh, $username, $day_id);
    my $current_lunch = TimetableDB::get_lunchtime_booking_latest($dbh, $username, $day_id);

    LUNCH_LOOP: for(my $start = 12; $start <= 14; $start += $TIME_STEP){
        $current_lunch->{"start"} = $start;
        TimetableDB::change_lunchtime($dbh, $current_lunch);
        my $new_sum_penalty = TimetableDB::get_sum_penalties($dbh);

        debug_lunchtime($current_lunch, $new_sum_penalty);
    
        if($new_sum_penalty < $sum_penalty){
            $sum_penalty  = $new_sum_penalty;
            $best_lunch = TimetableDB::get_lunchtime_booking_latest($dbh, $username, $day_id);
            TimetableDB::increment_revisions($dbh);
            last LUNCH_LOOP
        }
        if($new_sum_penalty == 0){
            last LUNCH_LOOP;
        }
    }
    TimetableDB::change_lunchtime($dbh, $best_lunch);
}

sub improve_room{
    my ($dbh, $activity_id, $improve_activity_flag) = @_;
    debug("Improving single room");
    my $sum_penalty       = TimetableDB::get_sum_penalties($dbh);
    my $best_booking      = TimetableDB::get_activity_booking_latest($dbh, $activity_id);
    my $current_booking   = TimetableDB::get_activity_booking_latest($dbh, $activity_id);
    my @room_replacements = TimetableDB::get_room_replacements($dbh, $activity_id);

    ROOM_LOOP: for my $room_replacement (@room_replacements){
        $current_booking->{"room_code"} = $room_replacement;

        TimetableDB::change_activity_booking($dbh, $current_booking);

        if($improve_activity_flag) {
            improve_activity($dbh, $activity_id);
        }

        my $new_sum_penalty = TimetableDB::get_sum_penalties($dbh);
        if($new_sum_penalty < $sum_penalty){
            $sum_penalty  = $new_sum_penalty;
            $best_booking = TimetableDB::get_activity_booking_latest($dbh, $activity_id);
            TimetableDB::increment_revisions($dbh);
            last ROOM_LOOP;
        }
        if($new_sum_penalty == 0){
            last ROOM_LOOP;
        }
    }
    TimetableDB::change_activity_booking($dbh, $best_booking);
}

sub debug{
    my $text = shift;

    if($DEBUG_ENABLED){
        print "$text\n";
    }
}

sub debug_activity{
    my ($activity, $sum_penalty) = @_;

    my $start       = $activity->{"start"};
    my $day         = $activity->{"day"};
    my $room        = $activity->{"room_code"};
    my $activity_id = $activity->{"activity_id"};
    my $revision_id = $activity->{"revision_id"};

    debug("Type: Activity, ActivityID: $activity_id, Start: $start, Day: $day"
         .", Room: $room, RevisionID: $revision_id, PenaltySum: $sum_penalty");
}

sub debug_lunchtime{
    my ($lunch, $sum_penalty) = @_;

    my $start       = $lunch->{"start"};
    my $day         = $lunch->{"day_id"};
    my $username    = $lunch->{"username"};
    my $revision_id = $lunch->{"revision_id"};

    debug("Type: Lunch, Start: $start, Day: $day, Username: $username, RevisionID: $revision_id, "
         ."PenaltySum: $sum_penalty");
}
