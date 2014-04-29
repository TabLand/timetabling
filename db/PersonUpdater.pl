#!/usr/bin/perl -w
use ResourceUpdater;
use PersonDB;

ResourceUpdater::update(PersonDB::get_function_ref_hash_ref());
