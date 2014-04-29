#!/usr/bin/perl -w
use strict;
use warnings;
use ResourceList;
use PersonDB;

output_person_list();

sub output_person_list{
    my $person_keys = ["username","name","type"];
    ResourceList::output_resource_list($person_keys, \&PersonDB::select_all);
}
