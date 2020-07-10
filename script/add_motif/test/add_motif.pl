use strict;
use 5.010;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

print "####################################################\n";
print "##                                               ###\n";
print "##      ####       ###     ######   ##   #####   ###\n";
print "##     ##  ##     #   #      ##     ##   ##      ###\n";
print "##    ##    ##   #     #     ##     ##   #####   ###\n";
print "##   ##      ##   #   #      ##     ##   ##      ###\n";
print "##  ##       ##    ###       ##     ##   ##      ###\n";
print "##                                               ###\n";
print "####################################################\n";
print "## add_motif 1.01                                  ##\n";
print "## Date:20170814                                  ##\n";
print "## Copyright\@2017 WANG                            ##\n";
print "####################################################\n";
&usage;
print "-----------------------------------------------------\n";
print "------------------   START   ------------------------\n";
my $start_time = localtime;    
my $end_time;
eval{
my $FILE_PATTERN;
my $motif_path;
if (defined($ARGV[0])) { 
    $FILE_PATTERN = "$ARGV[0]\\*.csv";
	$motif_path="$ARGV[0]\\phos.motif";
	
}elsif(!defined($ARGV[0])){
    $FILE_PATTERN = "*.csv";
	$motif_path="phos.motif";
}
#my $FILE_PATTERN = "*.fasta";
my @files        = glob($FILE_PATTERN);     ###glob
die "we can't find the csv files: $!" if(  @files < 1 );
use strict;
use File::DosGlob 'glob';
print"...............starting............\n";
my @motifs=();
print"get motif.....................\n";
@motifs=&get_motif($motif_path);
print"read files.....................\n";
foreach my $filename (@files){
    print "reading $filename.....\n";
	add_motif($filename);
}
sub add_motif{
    my ($filename)=@_;
    open (SOURCE,$filename) || die "Can't open $filename: $!";
    open (RESULT,">$filename\.motif") || die "Can't open result file: $!";
    
	while(<SOURCE>){
	    my $line = $_;
        chomp($line);		
        my @cells=split(/\,/,$line);
		my $newline=join(",",@cells);
		$cells[-1]=~ tr/[A-Z]/[a-z]/;
		#print "$cells[-1]\n";
	foreach my $motif (@motifs){
	#print "$cells[-1]:::$motif\n";
		if ($cells[-1]=~m/$motif/){
		$newline="$newline,$motif";
		}else{
		$newline="$newline,NA";
		}
}
print RESULT "$newline\n";
	}
close SOURCE;
close RESULT;
}

sub get_motif{
    my ($filename)=@_;
	my @motifs;
    open (MOTIF,$filename) || die "Can't open motif file: $!";
    while(<MOTIF>){
	my $line =format_motif($_);
    push @motifs,$line;
	}
	return @motifs;
}
sub format_motif{
    my ($line)= @_;
	chomp($line);
    $line=~ tr/[A-Z]/[a-z]/;
    return $line;	   
}
sub usage {
  print "# add motif for sequence windows basing on last column\n";
  print "# Usage:   perl add_motif.pl [filepath]\n";
  print "# Usage:   if you do not use parameter,you could put csv files and add_motif.pl file into same folder\n";
  print "# Example: perl add_motif.pl input\n";
  print "#          perl add_motif.pl\n";
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