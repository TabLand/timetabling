#!/usr/bin/perl
use ModuleManager;
use ActivityGrabber;
use strict;
use warnings;

my $module_manager = new ModuleManager();
$module_manager->parseXML("Modules.xml");
my $activity_grabber = new ActivityGrabber($module_manager);
$activity_grabber->process_grabs();
