#!/usr/bin/perl -w
use TimetableDB;
use HTTP_lib;
use CGI;
use JSON;

fetch_penalties();

sub fetch_penalties{
    my $dbh = DB_lib::connect();

    HTTP_lib::send_json_headers();
    my @sum_penalties = TimetableDB::get_sum_penalties_all_revisions($dbh);
    DB_lib::disconnect($dbh);

    my $json_text = to_json(\@sum_penalties, { utf8 => 1, pretty => 1 } ); 
    print $json_text;
}
