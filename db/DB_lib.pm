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

sub disconnect{
    my $dbh = shift;
    $dbh->disconnect();
}

sub fail{
    my ($dbh, $action) = @_;
    print "Failure! during $action";
    die "SQL Error during $action: " . $dbh->errstr . "\n\n"
}

1;
