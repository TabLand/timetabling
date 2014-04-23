#!/usr/bin/perl -w
use DB_lib;
use strict;
use warnings;
use JSON;

print "Content-Type:text/json\n\n";

my $dbh = DB_lib::connect();

my $sql = "SELECT * FROM Module";
my $sth = $dbh->prepare($sql);

$sth->execute or die "SQL Error: " . $dbh->errstr . "\n";

my @modules;

while (my @row = $sth->fetchrow_array) {
    my $module = {"name" => $row[0],
                   "code" => $row[1],};
    push @modules, $module;
}
DB_lib::disconnect($dbh);

print (encode_json {modules=>\@modules});
