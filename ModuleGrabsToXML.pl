#!/usr/bin/perl
use Mojo::DOM;
use Data::Dumper;

my $directory = 'timetable_grabs/*.grab';
my @grabs = `ls $directory`;
my $working_directory  = `pwd`;

for my $grab (@grabs){
	my $module = clean_module_name($grab);
	print "Crunching $module.xml\n";
	my $text = get_file_contents($grab);
	my $dom = Mojo::DOM->new($text);
	my @collection = $dom->find("p, table.spreadsheet")->each;
	my $day = "Noday";
	my $xml_out = "";
	for my $element (@collection){
		if($element->type eq "p"){
			$day = get_day($element);
		}
		else{
			my @rows = $element->find("tr:not(.columnTitles)")->each;
			for my $row (@rows){
				my @tds = $row->find("td")->each;
				$xml_out .= tr_to_xml($day, \@tds);
			}
		}
	}
	save_xml("timetable_xml/$module.xml",$xml_out);
}

sub tr_to_xml{
	my ($day, $table_datas) = @_;
	my @tds = @$table_datas;
	my $start_time = $tds[0]->text;
	my $finish_time = $tds[1]->text;
	my $week = $tds[2]->text;
	my $module_code = $tds[3]->text;
	my $activity = $tds[4]->text;
	my $description = $tds[5]->text;
	my $joint = $tds[6]->text;
	my $student_numbers = $tds[7]->text;
	my $room = $tds[8]->text;
	my $lecturer = $tds[10]->text;
	my $xml = "<booking>\n\t<start>$start_time</start>\n";
	$xml .= "\t<end>$finish_time</end>\n";
	$xml .= "\t<week>$week</week>\n";
	$xml .= "\t<modulecode>$module_code</modulecode>\n";
	$xml .= "\t<activity>$activity</activity>\n";
	$xml .= "\t<desc>$description</desc>\n";
	$xml .= "\t<joint>$joint</joint>\n";
	$xml .= "\t<studentnos>$student_numbers</studentnos>\n";
	$xml .= "\t<room>$room</room>\n";
	$xml .= "\t<lecturer>$lecturer </lecturer>\n";
	$xml .= "\t<day>$day </day>\n</booking>\n";
}

sub get_day{
	my $element = shift;
	return $element->find(".labelone")->text;
}
sub get_file_contents{
	my $filepath = get_full_path(shift);
	open(my $file, "<", $filepath) or die "Unable to open file for reading, $!";;
	my $text = join('', <$file>);
	close($file);
	return $text;
}
sub save_xml{
	my ($filename, $xml) = @_;
	my $filepath = get_full_path(shift);
	open(my $file, ">", $filepath) or die "Unable to open file $filepath for writing, $!";;
	print $file $xml;
	close($file);
}
sub get_full_path{
	my $filename = shift;	
	my $full_filepath = $working_directory . "/" . $filename;
	$full_filepath =~ s/\n//g;
	return $full_filepath;
}
sub clean_module_name{
	my $module = shift;
	$module =~ s/timetable_grabs//g;
	$module =~ s/\.grab//g;
	$module =~ s/\///g;
	$module =~ s/\n//g;
	return $module;
}
