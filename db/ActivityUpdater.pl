#!/usr/bin/perl -w
use ResourceUpdater;
use ActivityDB;

ResourceUpdater::update(ActivityDB::get_function_ref_hash_ref());
