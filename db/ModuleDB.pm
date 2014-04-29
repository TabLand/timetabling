#!/usr/bin/perl -w
package ModuleDB;
use strict;
use warnings;

sub get_function_ref_hash_ref{
    my $function_ref = {"add" => \&add,
                        "edit" => \&edit,
                        "delete" => \&del};
    return $function_ref;
}

sub add{
    my ($unsafe_module, $dbh) = @_;
    my $safe_module = validate_module($unsafe_module);

    my $sql         = 'INSERT INTO Module (Code,Name) VALUES (?,?)';
    my $sth         = $dbh->prepare($sql);
    $sth->execute($safe_module->{"code"}, $safe_module->{"name"})
                    or DB_lib::fail($dbh, "Module Add");
    return $sth;
}

sub edit{
    my ($unsafe_old_module, $unsafe_new_module, $dbh) = @_;

    my $new_module_safe = validate_module($unsafe_new_module);
    my $old_module_safe = validate_module($unsafe_old_module);

    my $sql             = 'UPDATE Module SET Code=?, Name=? WHERE Code=? AND Name=?';
    my $sth             = $dbh->prepare($sql);
    $sth->execute($new_module_safe->{"code"}, $new_module_safe->{"name"}
                  ,$old_module_safe->{"code"}, $old_module_safe->{"name"})
                    or DB_lib::fail($dbh, "Module Edit");
    return $sth;
}

sub del{
    my ($unsafe_module, $dbh) = @_;
    
    my $safe_module = validate_module($unsafe_module);
    my $sql         = 'DELETE FROM Module WHERE Code=? AND Name=?';

    my $sth         = $dbh->prepare($sql);
    $sth->execute($safe_module->{"code"}, $safe_module->{"name"})
                    or DB_lib::fail($dbh, "Module Delete");
    return $sth;
}

sub select_all{
    my ($dbh)   = shift;
    my $sql     = 'SELECT Code,Name FROM Module';
    my $sth     = $dbh->prepare($sql);
    $sth->execute
            or DB_lib::fail($dbh, "Module Select All");
    return $sth;
}

sub validate_code{
    my $unsafe_code = shift;
    $unsafe_code    =~ s/[^A-Za-z0-9\#\&\-]//g;
    my $safe_code   = $unsafe_code;
    return $safe_code;
}

sub validate_name{
    my $unsafe_name = shift;
    $unsafe_name =~ s/[^A-Za-z\ ]//g;
    my $safe_name   = $unsafe_name;
    return $safe_name;
}

sub validate_module{
    my $unsafe_module = shift;
    my $safe_module = {};

    my $unsafe_name = $unsafe_module->{"name"};
    my $unsafe_code = $unsafe_module->{"code"};

    $safe_module->{"name"} = validate_name($unsafe_name);
    $safe_module->{"code"} = validate_code($unsafe_code);

    return $safe_module;
}

1;
