#!/usr/bin/perl -w
use ResourceUpdater;
use RoomDB;

ResourceUpdater::update(RoomDB::get_function_ref_hash_ref());
