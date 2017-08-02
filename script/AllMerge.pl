
#############################################################################
#name:AllMerge#perl2exe_exclude "Text//Glob.pm";
#function:merging mutilfiles bases on left colume 
#version:1.0
#Date:2015-8-31
#E-Mail:wjlong0318@163.com
#usage:put your all files(only csv format) and this program into the same folder,the run the program
#############################################################################

use strict;
use File::DosGlob 'glob';
print"...............starting............\n";

my @filenames=glob('*.csv');
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

print"...............completed............\n";
<>
