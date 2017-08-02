use strict;
use Digest::MD5;

my @files=glob("*");
open(my $result, ">summary.md5.txt" ) or die "Can't open 'summary.md5.txt': $!";
foreach my $filename (@files){
    print "calculate MD5 of $filename........\n"; 
    open( my $in, $filename ) or die "Can't open '$filename': $!";
    binmode($in);
    print $result Digest::MD5->new->addfile(*$in)->hexdigest, " $filename\n";
    close($in); 
}
close($result); 
print "completed .......\n";