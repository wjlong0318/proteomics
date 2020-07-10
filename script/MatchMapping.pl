#############################################################################
#name:MatchMapping
#function:merging mutilfiles bases on left colume 
#version:1.0
#Date:2015-1-18
#E-Mail:wjlong0318@163.com
#usage:put your all files(only csv format) and this program into the same folder,the run the program
#############################################################################

use strict;
use File::Spec;
use Data::Dumper;

print"...............starting............\n";
my $mydir=".";
my %filenames;
my @gene_list;
###read files' name in the current folder#####
opendir DH,$mydir or die "cannot open $mydir:$!";
my %root;
foreach my $file(readdir DH){
    my $temfile=File::Spec->catfile($mydir,$file);
    #print "one file in $mydir is ",$temfile,"\n";
	if ($temfile=~/.+\.csv/){
	    #$temfile=~s/\.csv//;
        $filenames{$temfile}=0;  		
	 }
}
closedir DH;
####read files and store into the hash
my $file_count=0;
foreach my $filename (sort keys %filenames){
    print "reading $filename.....\n";
    open (SOURCE,$filename) || die "Can't open $filename: $!";
	$file_count++;
    while(<SOURCE>){
	    my $line = $_;
        chomp($line);		
        my @cells=split(/\,/,$line);
		#$filenames{$filename}=scalar @cells;
		chomp($cells[0]);
		$cells[0]=~s/\s//;
        $cells[0]=~ tr/[A-Z]/[a-z]/;
        my $gene=$cells[0];		
	    if($gene ~~ @gene_list){
	    }else{
	        push @gene_list,$gene; 
			#print "genelist:",@gene_list,"\n"; 
	    }
        shift(@cells);		
		my $anotation=join("|",@cells);
		#print "$anotation\n";
	    $root{$file_count}{$gene}=$anotation;		
    }
	close(SOURCE);
}

####output summary file#####
print "output summary file\n";
open (RESULT,">summary.out") || die "Can't open summary.csv: $!";
#print "genelist",@gene_list;
#my $header="gene list";
#foreach my $head_name (keys %filenames){
#    $header="$header,$head_name"."," x ($filenames{$head_name}-2);	
#} 
print RESULT join(",","gene list",sort keys %filenames),"\n";
foreach my $gene (@gene_list){
    
	my $line=$gene;
    foreach my $i (1 .. $file_count){
	    if (exists $root{$i}{$gene}){
		    $line="$line,$root{$i}{$gene}";
		}else{
		    $line="$line,NA";		
		}
	}
	#print "$line\n";
	print RESULT "$line\n";

}
#print "genelist",@gene_list; 
print "root:",Dumper(%root); 

print"...............completed............\n";
<>
