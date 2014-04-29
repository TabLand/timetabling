package HTTP_lib;
use strict;
use warnings;

sub send_json_headers{
    print "Content-Type:application/json\n\n";
}

sub send_plain_text_headers{
    print "Content-Type:text/plain\n\n";
}

sub send_html_headers{
    print "Content-Type:text/html\n\n";
}

1;
