#!/usr/bin/perl -w
use strict;
use warnings;
use ResourceList;
use ModuleDB;

output_module_list();

sub output_module_list{
    my $module_keys = ["code","name",];
    ResourceList::output_resource_list($module_keys, \&ModuleDB::select_all);
}
