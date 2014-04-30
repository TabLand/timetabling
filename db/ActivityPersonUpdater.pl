#!/usr/bin/perl -w
use ResourceUpdater;
use ActivityPersonDB;

ResourceUpdater::update(ActivityPersonDB::get_function_ref_hash_ref());
