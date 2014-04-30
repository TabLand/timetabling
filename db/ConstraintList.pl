#!/usr/bin/perl -w
use strict;
use warnings;
use ResourceList;
use ConstraintDB;

output_constraint_list();

sub output_constraint_list{
    my $constraint_keys = ["type","penalty",];
    ResourceList::output_resource_list($constraint_keys, \&ConstraintDB::select_all);
}
