#!/usr/bin/perl -w
package ResourceList;
use DB_lib;
use HTTP_lib;
use strict;
use warnings;
use JSON;

sub output_resource_list{
    my ($resource_keys_ref, $sth_func_ref) = @_;
    HTTP_lib::send_json_headers();
    my @resources = get_all_resources($resource_keys_ref, $sth_func_ref);
    my $json_text = to_json(\@resources, { utf8 => 1, pretty => 1 } ); 
    print $json_text;
}

sub get_all_resources{
    my ($resource_keys_ref, $sth_func_ref) = @_;
    my $dbh = DB_lib::connect();
    my $sth = $sth_func_ref->($dbh);
    my @resources;

    while (my @row = $sth->fetchrow_array) {
        my %resource =  key_value_arrays_to_resource($resource_keys_ref, \@row);
        push @resources, \%resource;
    }

    DB_lib::disconnect($dbh);

    return @resources;
}

sub key_value_arrays_to_resource{
    my ($keys_ref, $values_ref) = @_;
    my @keys = @$keys_ref;
    my @values = @$values_ref;

    my %resource;
    if(@keys <= @values){
        for(my $i = 0; $i < @keys; $i++){
            $resource{$keys[$i]} = $values[$i];
        }
    }
    return %resource;
}

1;
