#!/usr/bin/perl -w
package ResourceUpdater;
use DB_lib;
use HTTP_lib;
use strict;
use warnings;
use JSON;
use CGI;

sub update{
    my $dbh = DB_lib::connect();

    my $function_ref_hash_ref = shift;
    HTTP_lib::send_plain_text_headers();
    my $changes_ref = get_changes();
    make_changes($changes_ref, $function_ref_hash_ref, $dbh);

    DB_lib::disconnect($dbh);
}

sub get_changes{
    my $cgi = new CGI;
    my $json_text = $cgi->param("changes");
    my $changes_ref = from_json($json_text, { utf8  => 1 } );
    return $changes_ref;
}

#keys and values, essentially complete row
#use INSERT INTO ON DUPLICATE KEY UPDATE
sub make_changes{
    my ($changes_ref, $function_ref, $dbh) = @_;
    my @changes = @$changes_ref;

    for my $change (@changes){
        if($change->{"type"} eq "edition"){
            my $new = $change->{"new"};
            my $old = $change->{"old"};
            $function_ref->{"edit"}->($old, $new, $dbh);
        }
        elsif($change->{"type"} eq "addition"){
            my $resource = $change->{"resource"};
            $function_ref->{"add"}->($resource, $dbh);
        }
        elsif($change->{"type"} eq "deletion"){
            my $resource = $change->{"resource"};
            $function_ref->{"delete"}->($resource, $dbh);
        }
    }
}

1;
