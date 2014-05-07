#!/usr/bin/perl -w
use TimetableDB;
use DB_lib;
use HTTP_lib;

initialise_schedules();

sub initialise_schedules{
    my $dbh = DB_lib::connect();
    TimetableDB::initialise($dbh);
    DB_lib::disconnect($dbh);
    HTTP_lib::send_plain_text_headers();
}
