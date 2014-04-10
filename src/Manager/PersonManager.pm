#!/usr/bin/perl
package PersonManager;
use strict;
use warnings;
use Person;
use XML::LibXML qw( );

sub new{
	my ($class) = @_;
	my $self = {
		_persons => {}
	};
	bless $self, $class;
	return $self;
}

sub add{
	my ($self, $person) = @_;
	$self->{_persons}{$person->get_username()} = $person;
}
sub remove{
	my ($self, $person) = @_;
	delete $self->{_persons}{$person->get_username()};
}
sub get{
	my ($self, $username) = @_;
	if($self->contains($username)) return $self->{_persons}{$username};
}
sub get_all{
	my $self = shift;
	return values $self->{_persons};
}
sub contains{
	my ($self, $username) = @_;
	if(defined $self->{_persons}{$username}){
		return 1;
	}
	else {
		return 0;
	}
}
sub parseXML{
	my ($self, $filepath) = @_;
	my $parser = XML::LibXML->new();
	my $document = $parser->parse_file($filepath);
	my $root = $document->documentElement();
	my @people = $root->getChildrenByTagName("Person");
	for my $person (@people){
		my $username = $person->getChildrenByTagName("Username");
		my $name = $person->getChildrenByTagName("Name");
		$self->add(new Person($username, $name));
	}
}
