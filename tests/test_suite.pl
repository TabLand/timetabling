#!/usr/bin/perl
use warnings;
use strict;

use Test::Harness;
my @testfiles = `ls *.t`;
foreach my $testfile (@testfiles){
	chomp($testfile);
}
runtests(@testfiles);
