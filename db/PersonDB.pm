#!/usr/bin/perl -w
package PersonDB;
use DB_lib;

sub get_function_ref_hash_ref{
    my $function_ref = {"add" => \&add,
                        "edit" => \&edit,
                        "delete" => \&del};
    return $function_ref;
}

sub add{
    my ($unsafe_person, $dbh) = @_;

    my $safe_person     = validate_person($unsafe_person);

    my $sql             = 'INSERT INTO Person (Username, Name, Type) '
                          . 'VALUES (?,?,?)';
    my $sth             = $dbh->prepare($sql);

    $sth->execute($safe_person->{"username"}, $safe_person->{"name"}, $safe_person->{"type"})
                    or DB_lib::fail($dbh, "Person Add");
    return $sth;
}

sub edit{
    my ($unsafe_old_person, $unsafe_new_person, $dbh) = @_;
    my $safe_new_person = validate_person($unsafe_new_person);
    my $safe_old_person = validate_person($unsafe_old_person);

    my $sql = 'UPDATE Person SET Username=?, Name=?, Type=? WHERE Username=? AND Name=? AND Type=?';
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_new_person->{"username"}, $safe_new_person->{"name"}, $safe_new_person->{"type"}
                 , $safe_old_person->{"username"}, $safe_old_person->{"name"}, $safe_old_person->{"type"})
                    or DB_lib::fail($dbh, "Person Edit");
    return $sth;
}

sub del{
    my ($unsafe_person, $dbh)  = @_;

    my $safe_person = validate_person($unsafe_person);
    my $sql         = 'DELETE FROM Person WHERE Username=? AND Name=? AND Type=?';

    my $sth = $dbh->prepare($sql);
    $sth->execute($safe_person->{"username"}, $safe_person->{"name"}
                  , $safe_person->{"type"})
                    or DB_lib::fail($dbh, "Person Delete");
    return $sth;
}

sub select_all{
    my ($dbh) = shift;

    my $sql = 'SELECT Username, Name, Type FROM Person';
    my $sth = $dbh->prepare($sql);
    $sth->execute()
                    or DB_lib::fail($dbh, "Person Select All");
    return $sth;
}

sub validate_person{
    my $unsafe_person    = shift;
    my $safe_person      = {};

    my $unsafe_name      = $unsafe_person->{"name"};
    my $unsafe_username  = $unsafe_person->{"username"};
    my $unsafe_type      = $unsafe_person->{"type"};

    $safe_person->{"name"}     = validate_name($unsafe_name);
    $safe_person->{"username"} = validate_username($unsafe_username);
    $safe_person->{"type"}     = validate_type($unsafe_type);

    return $safe_person;
}

sub validate_name{
    my $unsafe_name = shift;
    $unsafe_name =~ s/[^A-Za-z\ ]//g;
    my $safe_name = $unsafe_name;
    return $safe_name;
}

sub validate_username{
    my $unsafe_username = shift;
    $unsafe_username =~ s/[^A-Za-z0-9]//g;
    my $safe_username = $unsafe_username;
    return $safe_username;
}

sub validate_type{
    my $unsafe_type = shift;
    my $is_student  = $unsafe_type eq "Student";
    my $is_staff    = $unsafe_type eq "Staff";

    if($is_student || $is_staff) {
        return $unsafe_type;
    }
    else {
        die "$unsafe_type is invalid and probably very very unsafe";
    }
}

1;
