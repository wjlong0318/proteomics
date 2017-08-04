
#############################################################################
# Copyright (C) 2017, WANG Limited.                               #
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

use strict;
use 5.010;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

print "####################################################\n";
print "##                                               ###\n";
print "##    ####   ####      ###   #       #   ######  ###\n";
print "##     ##    #   #    #      ##     ##     ##    ###\n";
print "##     ##    #    #  #        ##   ##      ##    ###\n";
print "##     ##    #   #    #        ## ##       ##    ###\n";
print "##    ####   ####      ###       #         ##    ###\n";
print "##                                               ###\n";
print "####################################################\n";
print "## IDconvert 1.0                                  ##\n";
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
#my $FILE_PATTERN = "*.fasta";
my @files        = glob($FILE_PATTERN);     ###glob
die "we can't find the two fasta files: $!" if(  @files != 2 );
my ($a_file,$big_file);
my $big_size=0;
foreach my $fasta (@files){
    print "checking $fasta......\n";
	my ($first_header,$first_seq)=read_fisrt_seq($fasta);
	#print "$first_header\n$first_seq\n";
	my ($seq_type)=check_seq($first_seq);
	my $size = -s $fasta;
	#print "$size,$header_type,$ID,$seq_type\n";
	if ($size >$big_size){
	    ($a_file,$big_file)=($big_file,$fasta);
	}
}
print "start makeblastdb......\n";
system("makeblastdb -in $big_file -parse_seqids -dbtype prot");
print "start blastp......\n";
system("blastp -db  $big_file -query $a_file -max_target_seqs 1 -outfmt 10  -evalue 0.000001 -out out");


sub read_fisrt_seq{
    my ($file)=@_;
	open (SOURCE,$file) || die "Can't open $file: $!";
    my $protein_num=0;
	my $header="";
	my $seq="";
	while(<SOURCE>){
        if (/\>(.+)/){            
            $protein_num++;          
            $header=$1;
			if( $protein_num == 2 ){
                $header=~ s/\n//g;
			    $header=$header;
			    $seq=~ s/\n//g;
	            $seq=$seq;
			last;
	        }  
        }else{
		
            $seq=$seq.$_;
        }
    }
	return ($header,$seq);
}

sub check_seq{
     my ($seq)=@_;
    return "prot";
}
sub read_fasta{
    my ($file)=@_;
	my %ref;
	open my $in, '<',$file || die "Can't open $file: $!";
    my $code = do { local $/; <$in> };
    my @records= split(">",$code);
	print "aa:$records[1]";
	foreach my $item (@records){
	    my @lines= split("\n",$item);
		my $key= shift @lines;
		my $value=join("",@lines);
		$ref{$key}=$value;
	}
    return %ref
}

sub usage {
  print "# out file, seperated with comma, can be opened by excel \n";
  print "# query,subject,Identities,query match length,mismatches,gap openings,query start,query end,sbject start,sbject end,E Value,Score\n";
  print "# blastp -evalue 0.000001\n";
  print "# Usage:   perl IDconvert.pl [filepath]\n";
  print "# Usage:   if you do not use parameter,you could put two fasta files and IDconvert.pl file into same folder\n";
  print "# Example: perl IDconvert.pl input\n";
  print "#          perl IDconvert.pl\n";
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
