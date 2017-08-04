
#############################################################################
#name:ModMerge for 5600
#function:
#version:1.0
#Date:20160815
#E-Mail:wjlong0318@163.com
#usage:
#############################################################################
use strict;
use 5.010;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

print "####################################################\n";
print "##                                               ###\n";
print "##     ###    ###          ###      ######       ###\n";
print "##    #   #  #   #       ##   ##    ##   ##      ###\n";
print "##   #     ##     #     ##     ##   ##     ##    ###\n";
print "##  #      ##      #     ##   ##    ##   ##      ###\n";
print "## ##              ##      ###      ######       ###\n";
print "##                                               ###\n";
print "####################################################\n";
print "## ModMerge for AB SCIEX TripleTOF 5600           ##\n";
print "## PeptideSummary.txt export from ProteinPilot    ##\n";
print "## default: Cof >=95                              ##\n";
print "## Date:20160827                                  ##\n";
print "## Copyright\@2016 WANG                           ##\n";
print "####################################################\n";

print "-----------------------------------------------------\n";
print "------------------   START   ------------------------\n";
my $start_time = localtime;    
my $end_time;
eval{

my $FILE_PATTERN = "*.fasta";
my @files        = glob($FILE_PATTERN);     ###glob
die "we can't find the two fasta files: $!" if(  @files != 2 );
my ($a_file,$big_file);
my $big_size=0;
foreach my $fasta (@files){
    print "checking $fasta\n";
	my ($first_header,$first_seq)=read_fisrt_seq($fasta);
	#print "$first_header\n$first_seq\n";
	my ($header_type,$ID)=check_header($first_header);
	my ($seq_type)=check_seq($first_seq);
	my $size = -s $fasta;
	print "$size,$header_type,$ID,$seq_type\n";
	if ($size >$big_size){
	    ($a_file,$big_file)=($big_file,$fasta);
	}
}
my %a_file_ref=read_fasta($a_file);
system("makeblastdb -in $big_file -parse_seqids -dbtype prot");
mkdir("tem");
#foreach my $key ( keys %a_file_ref){
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
sub check_header{
    my ($header)=@_;
    return ('NA',$header);
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