package ModuleGrabber;
use Module;
use strict;
use warnings;
use LWP::Simple;

sub main
{
    my $data = get("http://sws.city.ac.uk/tt1314/js/lists/citymodules.js");
    print $data;
}
 
main();
