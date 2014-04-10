#!/usr/bin/perl
package ModuleManager;
use strict;
use warnings;
use Module;
use XML::LibXML qw( );

sub new{
	my ($class) = @_;
	my $self = {
		_modules => {}
	};
	bless $self, $class;
	return $self;
}
sub parseXML{
	my ($self, $filepath) = @_;
	my $parser = XML::LibXML->new();
	my $document = $parser->parse_file($filepath);
	my $root = $document->documentElement();
	my @modules = $root->getChildrenByTagName("Module");
	for my $module (@modules){
		my $code = $module->getChildrenByTagName("Code");
		my $name = $module->getChildrenByTagName("Name");
		$self->add_module(new Module($code, $name));
	}
}
sub get_all_module_codes{
	my $self = shift;
	my @keys = (keys $self->{_modules});
	return @keys;
}
sub get_all_modules{
	my $self = shift;
	return values $self->{_modules};
}
sub add_module{
	my ($self, $module) = @_;
	$self->{_modules}{$module->get_code()} = $module;
}
sub remove_module{
	my ($self, $module) = @_;
	delete $self->{_modules}{$module->get_code()};
}
1;
