
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
#name:AllMerge#perl2exe_exclude "Text//Glob.pm";
#function:merging mutilfiles bases on left colume 
#version:1.01
#Date:20170805
#E-Mail:wjlong0318@163.com
#usage:put your all files(only csv format) and this program into the same folder,the run the program
#############################################################################
use strict;
use 5.010;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;


print "####################################################\n";
print "## AllMerge 1.01                                  ##\n";
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
my @filenames=glob($FILE_PATTERN);
die "we can't find csv files: $!" if( @filenames < 2 );
my %lenline;
my @gene_list;
my %root=&mutilcsv2hash(@filenames);

####output summary file#####
print "output summary file\n";
open (my $result,">summary.csv") || die "Can't open summary.csv: $!";
foreach my $gene (@gene_list){
	my $line=$gene;
    foreach my $filename (@filenames){
	    if (exists $root{$filename}{$gene}){
		    $line="$line,$root{$filename}{$gene}";
		}else{
		    $line="$line".",NA" x $lenline{$filename};		
		}
	}
	#print "$line\n";
	print $result "$line\n";

}

sub mutilcsv2hash{
    my %root;
    my @filename=@_;
    foreach my $filename (@filenames){
        print "reading $filename.....\n";
		my $linenum=0;
        open (my $source,$filename) || die "Can't open $filename: $!";
	    while(<$source>){
		    my $line = $_;
            chomp($line);		
            my @ones=split(/\,/,$line);
		    $lenline{$filename}=$#ones if ($#ones > $lenline{$filename});
		    chomp($ones[0]);
		    $ones[0]=~s/\s//;
            $ones[0]=~ tr/[A-Z]/[a-z]/;
            my $gene=$ones[0];		
	        if($gene ~~ @gene_list){}else{
	            push @gene_list,$gene;
		    }
            shift(@ones);
			@ones= map {$_."($filename)"}@ones if ($linenum == 0);
		    $linenum++;
		    my $anotation=join(",",@ones);
			if ($#ones < $lenline{$filename}){
			    my $less =  $lenline{$filename} - $#ones-1;  
			    $anotation="$anotation".",NA" x $less;
			}			
	        $root{$filename}{$gene}=$anotation;		
        }
	    close($source);
    }
	return %root;
}
sub usage {
  print "# function:merging mutilfiles(CSV) bases on left colume\n"; 
  print "# version:1.01\n";
  print "# Usage:   perl AllMerge.pl [filepath]\n";
  print "# Usage:   if you do not use parameter,you could put all csv files and AllMerge.pl file into same folder\n";
  print "# Example: perl Almerge.pl input\n";
  print "#          perl Almerge.pl\n";
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
