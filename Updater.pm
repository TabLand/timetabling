#!/usr/bin/perl
package Updater;
use strict;
use warnings;
use File;
use CGI;
use XML::Validate;

sub update{
    my $filename = shift;
    print "Content-type: text/plain\n\n";

    my $cgi = new CGI;
    my $validator = new XML::Validate(Type => 'LibXML');
    my $xml =  $cgi->param("xml");
    my $valid_xml = 0;

    if((length $xml)){
        $valid_xml = $validator->validate($xml);
    }

    if($valid_xml != 0){
        File::write_to_file($filename,$xml);
        print "success!";
    }
    else{
        print "failure!, Invalid xml\n";
    }
}
1;
