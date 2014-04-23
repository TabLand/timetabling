#!/usr/bin/perl -w
use DB_lib;
use strict;
use warnings;

my $dbh = DB_lib::connect();

my $sql = "SELECT * FROM Module";
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: " . $dbh->errstr . "\n";

while (my @row = $sth->fetchrow_array) {
    print $row[0] . "," . $row[1] . "\n";
}
DB_lib::disconnect($dbh);
