#!/usr/bin/perl
package Student;
use Moose;

has '_id' => (is => 'rw', isa => 'Int');
has '_username' => (is =>'rw', isa => 'Str');
has '_course' => (is =>'rw', isa => 'Str');
has '_name' => (is => 'rw', isa => 'Str');
has '_modulegroup' => (is=>'rw', isa => 'ModuleGroupManager');

sub check_clashes{}
sub add_booking{}
sub remove_booking{}
