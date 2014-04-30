#!/usr/bin/perl -w
use strict;
use warnings;
use ResourceList;
use ActivityPersonDB;

output_activity_person_list();

sub output_activity_person_list{
    my $activity_keys = ["code","module_name","type","group","username","person_name"];
    ResourceList::output_resource_list($activity_keys, \&ActivityPersonDB::select_all);
}
