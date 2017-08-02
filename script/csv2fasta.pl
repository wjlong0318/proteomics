#perl csv2fasta
use strict;
use File::Spec;

my @files=glob '*.csv';
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