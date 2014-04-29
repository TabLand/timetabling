#!/usr/bin/perl -w
use ResourceUpdater;
use ModuleDB;

ResourceUpdater::update(ModuleDB::get_function_ref_hash_ref());
