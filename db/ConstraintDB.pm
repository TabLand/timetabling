#!/usr/bin/perl -w
package ConstraintDB;
use DB_lib;
use strict;
use warnings;

sub get_function_ref_hash_ref{
    my $function_ref = {"edit" => \&edit};
    return $function_ref;
}

sub edit{
    my ($unsafe_old_constraint, $unsafe_new_constraint, $dbh) = @_;
    #no need to validate old constraint, new constraint contains everything we need
    my $safe_new_constraint = validate_constraint($unsafe_new_constraint);

    my $sql = 'UPDATE Constraints SET Penalty=? WHERE ConstraintType=?';
    my $sth = $dbh->prepare($sql);

    $sth->execute($safe_new_constraint->{"penalty"}, $safe_new_constraint->{"type"})
                    or DB_lib::fail($dbh, "Constraint Edit");
    return $sth;
}

sub select_all{
    my ($dbh) = shift;

    my $sql = 'SELECT ConstraintType, Penalty FROM Constraints';
    my $sth = $dbh->prepare($sql);
    $sth->execute()
                    or DB_lib::fail($dbh, "Constraint Select All");
    return $sth;
}

sub validate_constraint{
    my $unsafe_constraint = shift;
    my $safe_constraint   = {};

    my $unsafe_type    = $unsafe_constraint->{"type"};
    my $unsafe_penalty = $unsafe_constraint->{"penalty"};

    $safe_constraint->{"penalty"} = validate_penalty($unsafe_penalty);
    $safe_constraint->{"type"}    = validate_type($unsafe_type);

    return $safe_constraint;
}

sub validate_penalty{
    my $unsafe_penalty = shift;
    $unsafe_penalty =~ s/[^0-9\.]//g;

    if($unsafe_penalty < 0 || $unsafe_penalty > 100){
        die "Malformed penalty $unsafe_penalty sent!";
    }

    my $safe_penalty = $unsafe_penalty;
    return $safe_penalty;
}

sub validate_type{
    my $unsafe_type = shift;
    $unsafe_type =~ s/[^A-Za-z]//g;
    my $safe_type = $unsafe_type;
    return $safe_type;
}

1;
