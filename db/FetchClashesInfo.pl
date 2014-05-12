#!/usr/bin/perl -w
use TimetableDB;
use HTTP_lib;
use CGI;
use JSON;

fetch_clashes_info();

sub fetch_clashes_info{
    my $dbh = DB_lib::connect();

    HTTP_lib::send_json_headers();

    my @lunch_clashes  = TimetableDB::get_latest_lunch_clashes($dbh);
    my @person_clashes = TimetableDB::get_latest_person_clashes($dbh);
    my @room_clashes   = TimetableDB::get_latest_room_clashes($dbh);
    my @room_over_caps = TimetableDB::get_latest_room_over_capacities($dbh);

    DB_lib::disconnect($dbh);

    my @clashes = (@lunch_clashes, @person_clashes, @room_clashes, @room_over_caps);

    my $json_text = to_json(\@clashes, { utf8 => 1, pretty => 1 } ); 
    print $json_text;
}
