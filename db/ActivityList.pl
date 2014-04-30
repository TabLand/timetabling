#!/usr/bin/perl -w
use strict;
use warnings;
use ResourceList;
use ActivityDB;

output_activity_list();

sub output_activity_list{
    my $activity_keys = ["code","name","type","group","duration"];
    ResourceList::output_resource_list($activity_keys, \&ActivityDB::select_all);
}
