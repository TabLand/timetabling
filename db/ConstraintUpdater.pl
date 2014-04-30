#!/usr/bin/perl -w
use ResourceUpdater;
use ConstraintDB;

ResourceUpdater::update(ConstraintDB::get_function_ref_hash_ref());
