
#############################################################################
# Copyright (C) 2017, WANG Limited.                                         #
#                                                                           #
# This script is free software. You can redistribute and/or                 #
# modify it under the terms of the GNU General Public License               #
# as published by the Free Software Foundation; either version 2            #
# of the License or, (at your option), any later version.                   #
#                                                                           #
# These modules are distributed in the hope that they will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the              #
# GNU General Public License for more details.                              #
#############################################################################
#############################################################################

use strict;
use 5.010;
use File::Spec;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;


print "####################################################\n";
print "## csv2fasta 1.01                                  ##\n";
print "## Date:20170804                                  ##\n";
print "## Copyright\@2017 WANG                            ##\n";
print "####################################################\n";
&usage;
print "-----------------------------------------------------\n";
print "------------------   START   ------------------------\n";
my $start_time = localtime;    
my $end_time;
eval{
my $FILE_PATTERN;
if (defined($ARGV[0])) { 
    $FILE_PATTERN = "$ARGV[0]\\*.csv";
}elsif(!defined($ARGV[0])){
    $FILE_PATTERN = "*.csv";
}
my @files=glob($FILE_PATTERN);
die "we can't find csv files: $!" if( @files < 1 );


for my $file (@files){
   &csv2fasta($file);
}

sub csv2fasta{
    my ($file)=@_;
    print "file $file is running\n";
	open my $fh,"$file" or die $!;
    open my $out, '>', "$file.fasta" or die $!;
    
	while (<$fh>){
	    my @line = split(",",$_);
		print $out ">$line[0]\n";
        my @arr = $line[1]=~/.{80}/g;
		print $out "$_\n" for (@arr);
        my $tailstr = substr("$line[1]", 80*($#arr+1));
        print $out "$tailstr";		

     }

}

sub usage {
  print "# function:convert csv to fasta\n"; 
  print "# version:1.01\n";
  print "# Usage:   perl csv2fasta.pl [filepath]\n";
  print "# Usage:   if you do not use parameter,you could put all csv files and csv2fasta.pl file into same folder,double-click\n";
  print "# Example: perl csv2fasta.pl input\n";
  print "#          perl csv2fasta.pl\n";
}

};

my $others;
if($@){
$others=$@;
print $others;
}
#eval{&monitor;};
$end_time = localtime;
my $s = $end_time - $start_time;
print "\n---------------------  REPORT  -----------------------\n";
print "Start time is $start_time\n";
print "The end time is $end_time\n";    
print "The used time is: ", $s->minutes," minites.\n";
print "---------------------    END   -----------------------\n";

<>