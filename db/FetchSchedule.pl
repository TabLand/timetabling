#!/usr/bin/perl -w
use TimetableDB;
use HTTP_lib;
use CGI;
use JSON;

fetch_schedule();

sub fetch_schedule{
    my $dbh = DB_lib::connect();

    HTTP_lib::send_json_headers();
    my $request = get_request();
    process_request($request, $dbh);

    DB_lib::disconnect($dbh);
}

sub get_request{
    my $cgi = new CGI;
    my $json_text = $cgi->param("view_request");
    my $request = from_json($json_text, { utf8  => 1 } );
    return $request;
}

sub process_request{
    my ($request, $dbh) = @_;
    my @schedule;

    if($request->{"type"} eq "Room"){
        @schedule = get_room_schedule($dbh, $request->{"code"});
    }
    elsif($request->{"type"} eq "Student" || $request->{"type"} eq "Staff"){
        @schedule = get_person_schedule($dbh, $request->{"code"});
    }
    my $json_text = to_json(\@schedule, { utf8 => 1, pretty => 1 } ); 
    print $json_text;
}

sub get_room_schedule{
    my ($dbh, $code) = @_;
    my @schedule = TimetableDB::get_room_schedule($dbh, $code);
    return @schedule;
}

sub get_person_schedule{
    my ($dbh, $username) = @_;
    my @activities = TimetableDB::get_person_activities_schedule($dbh, $username);
    my @lunches    = TimetableDB::get_person_lunches_schedule($dbh, $username);
    my @schedule   = (@activities, @lunches);
    return @schedule;
}
