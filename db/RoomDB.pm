#!/usr/bin/perl -w
package RoomDB;
use DB_lib;

sub get_function_ref_hash_ref{
    my $function_ref = {"add" => \&add,
                        "edit" => \&edit,
                        "delete" => \&del};
    return $function_ref;
}

sub add{
    my ($unsafe_room, $dbh) = @_;

    my $safe_room     = validate_room($unsafe_room);

    my $sql             = 'INSERT INTO Room (Code, Capacity) '
                          . 'VALUES (?,?)';
    my $sth             = $dbh->prepare($sql);

    $sth->execute($safe_room->{"code"}, $safe_room->{"capacity"})
                    or DB_lib::fail($dbh, "Room Add");
    return $sth;
}

sub edit{
    my ($unsafe_old_room, $unsafe_new_room, $dbh) = @_;
    my $safe_new_room = validate_room($unsafe_new_room);
    my $safe_old_room = validate_room($unsafe_old_room);

    my $sql = 'UPDATE Room SET Code=?, Capacity=? WHERE Code=? AND Capacity=?';
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_new_room->{"code"}, $safe_new_room->{"capacity"}
                 , $safe_old_room->{"code"}, $safe_old_room->{"capacity"})
                    or DB_lib::fail($dbh, "Room Edit");
    return $sth;
}

sub del{
    my ($unsafe_room, $dbh)  = @_;

    my $safe_room = validate_room($unsafe_room);
    my $sql         = 'DELETE FROM Room WHERE Code=? AND Capacity=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($safe_room->{"code"}, $safe_room->{"capacity"})
                    or DB_lib::fail($dbh, "Room Delete");
    return $sth;
}

sub select_all{
    my ($dbh) = shift;

    my $sql = 'SELECT Code,Capacity FROM Room';
    my $sth = $dbh->prepare($sql);
    $sth->execute()
                    or DB_lib::fail($dbh, "Room Select All");
    return $sth;
}

sub validate_room{
    my $unsafe_room    = shift;
    my $safe_room      = {};

    my $unsafe_code      = $unsafe_room->{"code"};
    my $unsafe_capacity  = $unsafe_room->{"capacity"};

    $safe_room->{"code"}     = validate_code($unsafe_code);
    $safe_room->{"capacity"} = validate_capacity($unsafe_capacity);

    return $safe_room;
}

sub validate_code{
    my $unsafe_code = shift;
    $unsafe_code =~ s/[^A-Za-z0-9]//g;
    my $safe_code = $unsafe_code;
    return $safe_code;
}

sub validate_capacity{
    my $unsafe_capacity = shift;
    $unsafe_capacity =~ s/[^0-9]//g;
    my $safe_capacity = $unsafe_capacity;
    return $safe_capacity;
}

1;
