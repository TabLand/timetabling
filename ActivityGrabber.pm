package ActivityGrabber;
#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent; 
use HTTP::Request::Common qw(POST);
use Data::Dumper;

sub new{
	my ($class, $module_manager) = @_;
	my $self = {
		_request => 0,
		_url => 'http://sws.city.ac.uk/tt1314/ShowTimetable.asp???',
		_browser => LWP::UserAgent->new(),
		_module_manager => $module_manager
	};
	bless $self, $class;
	return $self;
}
sub get_url{
	my $self = shift;
	return $self->{_url};
}
sub process_grabs{
	my $self = shift;
	my @module_codes = $self->get_module_manager()->get_all_module_codes();
	for my $module_code (@module_codes){
		print "Now grabbing $module_code's activities\n";
		$self->set_request($module_code);
		my $content = $self->grab();
		$self->save($module_code,$content);
	}
}
sub set_request{
	my ($self, $module_code) = @_;
	my $url = $self->get_url();
	$self->{_request} = POST $url,['filter' => 'undefined', 
		         'identifier'=> $module_code,
			 'days' =>'1-5',
			 'weeks'=>'6-20',
			 'Style'=>'TextSpreadsheet Object',
			 'objectclass'=>'Module'];
}
sub get_request{
	my $self = shift;
	return $self->{_request};
}
sub get_module_manager{
	my $self = shift;
	return $self->{_module_manager};
}
sub grab{
	my $self = shift;
	my $request = $self->get_request();
	my $response = $user_agent->request($request);
	if ($response->is_success) {
        	return $response->content;
	} else {
	        return "FAILED FAILED FAILED FAILED!" . $response->status_line . "\n";
	}
}
sub save{
	my ($self, $module_code, $content) = @_;
	open (FILE, ">timetable_grads/$module_code.html"); 
	print FILE $content; 
	close (FILE); 
}
