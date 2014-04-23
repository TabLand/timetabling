#!/usr/bin/perl -w
package DB_lib;
use DBI;
use strict;
use warnings;
use PASS;

sub connect{
    my $dbh = DBI->connect("dbi:mysql:" . PASS::DB_NAME,PASS::DB_USER,PASS::DB_PASSWORD)
        or die "Connection Error:" . DBI->errstr . "\n";
    return $dbh;
}

sub haha{
    return "haha";
}

sub disconnect{
    my $dbh = shift;
    $dbh->disconnect();
}

1;
