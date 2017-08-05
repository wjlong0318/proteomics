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
print "## fasta2csv 1.01                                  ##\n";
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
    $FILE_PATTERN = "$ARGV[0]\\*.fasta";
}elsif(!defined($ARGV[0])){
    $FILE_PATTERN = "*.fasta";
}
my @files=glob($FILE_PATTERN);
die "we can't find fasta files: $!" if( @files < 1 );



for my $file (@files){
   &fasta2csv($file);
}

sub fasta2csv2{
    my ($file)=@_;
	my %ref;
	open my $in, '<',$file || die "Can't open $file: $!";
    my $code = do { local $/; <$in> };
    my @records= split(">",$code);
	foreach my $item (@records){
	    my @lines= split("\n",$item);
		my $key= shift @lines;
		my $value=join("",@lines);
		$ref{$key}=$value;
	}
    return %ref
}



#声明变量
my $protein_num=-1;
my $protein_name;
my $seq;

sub fasta2csv{
my ($file)=@_;
#打开源文件、创建写入结果的文件
open (SOURCE,$file) || die "Can't open myfile: $!";
open (RESULT,">$file.csv") or die "can't open result:$!";
#在结果文件中写入表头
print RESULT "protein_num,protein_name,seq\n";
#开始读源文件
while(<SOURCE>){
    if (/\>(.+)/){            
        $protein_num++;
		#写入数据
        if( $protein_num ne 0 ){
            print "reading $protein_name***\n";
            #删除seq的所有空格
			$seq=~s/\s//g;
			##写入行数据
			print RESULT "$protein_num,$protein_name,$seq\n";
	    }            
        $seq='';
        $protein_name=$1;
		$protein_name=~s/\,/\|/g;
    }else{
        $seq=$seq.$_;
    }
}
print "reading $protein_name***";
$seq=~s/\s//g;
$protein_num++;
print RESULT "$protein_num,$protein_name,$seq\n";
#关闭文件
close RESULT;
close SOURCE;
}

sub usage {
  print "# function:convert fasta to csv\n"; 
  print "# version:1.01\n";
  print "# Usage:   perl fasta2csv.pl [filepath]\n";
  print "# Usage:   if you do not use parameter,you could put all csv files and fasta2csv.pl file into same folder,double-click\n";
  print "# Example: perl fasta2csv.pl input\n";
  print "#          perl fasta2csv.pl\n";
}

};

my $others;
if($@){
$others=$@;
print $others;
}
$end_time = localtime;
my $s = $end_time - $start_time;
print "\n---------------------  REPORT  -----------------------\n";
print "Start time is $start_time\n";
print "The end time is $end_time\n";    
print "The used time is: ", $s->minutes," minites.\n";
print "---------------------    END   -----------------------\n";

<>