use strict;
use Text::CSV_XS;
use 5.010;
use Data::Dumper;    
use Time::Piece;
use Time::Seconds;

print "-------------------START---------------------\n";


my $start_time = localtime;    
my $end_time;
eval{
my %root;	
my $tor=0.03;
my %sum;
my %stat;
my @filenames;
my @peak_list=(204.0867,186.0761,145.0495,163.0601,366.1395,528.1923,292.1027,274.0921,290.087,657.2349,819.2877,308.0976,290.087,511.177,673.2298,980.3201,964.3252,147.0652,129.0546,512.1974,803.2928);





mkdir("result");
my $logname="log";
open my $log, ">result\\$logname", or die "Error: Cannot open $logname."; 
   
my $result;
my @ms2_file=glob('*.mgf');
die "[Error]we can not find ms2 file" if (@ms2_file == 0);
foreach my $filename (@ms2_file){
    print "reading $filename.....\n";
	push @filenames, $filename;	
   
	my %mgf=import_mgf($filename,$log);
	&findpeak(\%mgf,$log);
	&output($filename,$log);
	
}


#print $log Dumper(%psm);
sub findpeak{

my ($mgf_ref,$log)=@_;
my %mgf=%{$mgf_ref};
foreach my $item_ms2(keys %mgf){
    
    #my $mz=sprintf('%.4f',$mgf{$item_ms2}{'mz'});
    #my $mz=$mgf{$item_ms2}{'mz'};
	#my $ms1_scan=$mgf{$item_ms2}{'ms1_scan'};
	my $ms2_scan=$mgf{$item_ms2}{'ms2_scan'};
	print "[Findpeaks]ms2:$ms2_scan\n";
	if(exists $mgf{$item_ms2}{'ms2'}){
	    my $peak_rt=int($mgf{$item_ms2}{'rt'}/60);
	    &scan2peakrt($mgf{$item_ms2}{'ms2'},\@peak_list,$peak_rt);    
	}else{
	    print $log "[ERROR]ms2:$ms2_scan does not found peaks\n";
	}

}
}

sub output{

my ($filename,$log)=@_;
 open my $result, ">result\\$filename.peak_rt.csv", or die "Error: Cannot open $filename.peak_rt.csv."; 

print $result "rt_bin";
foreach my $head (sort @peak_list){
print $result ",$head";
}
print $result "\n";
foreach my $bin (keys %root){
    print $result "$bin";
    foreach my $num (sort @peak_list){
        print $result ",$root{$bin}{$num}";
    }
    print $result "\n";
}
print $result "sum";
foreach my $num (sort @peak_list){
        print $result ",$sum{$num}";
}
print $result "\n";
print $result "ms2_num";
foreach my $num (sort @peak_list){
        print $result ",$stat{$filename}{'ms2_num'}";
}
print $result "\n";
print $result "identifed";
foreach my $num (sort @peak_list){
        my $identified=$sum{$num}/$stat{$filename}{'ms2_num'};
        print $result ",$identified";
}
print $result "\n";



close $result;
}

sub scan2peakrt{
    my ($scan,$peak_list,$peak_rt)=@_;
	my @peak_mz=@{$peak_list};
	my @peaks=split("\n",$scan);
	foreach my $peak (@peaks){
	    my ($mz,$intensity)=split(" ",$peak);
		foreach my $find_mz (@peak_mz){
		    if(abs($find_mz-$mz)<$tor){
			    
		        if(defined $root{$peak_rt}{$find_mz}){
                    $root{$peak_rt}{$find_mz}++;
                    $sum{$find_mz}++;
	        	}else{
		            $root{$peak_rt}{$find_mz}=1;
		            $sum{$find_mz}=1;
		        }
			
			}
		}
		   
		
		
	    
	}

}

#print $log Dumper(%root);
#print $log Dumper(%mgf);



sub import_mgf{
    
    my ($filename,$log) = @_;
    open FILE, "<$filename", or die "Error: Cannot open MGF."; 
  
    print "[i]Importing $filename ... \n";
    print $log "Importing $filename ... \n";
    my %mgf;
	my $spec_num=0;
	my $dataset=0;
	my $title="";
	my $ms1_scan=0;
	my $ms2_scan=0;
	my $ms2_last=0;
    while (<FILE>) {
        if ($_ =~ "^BEGIN IONS") { $dataset = $dataset + 1; 
		
		}elsif ($_ =~ /^TITLE/) {
			my $line=$_;
			if ($line =~ m/(.*\.(\d*)\..*)[\r\n]/) {
			           $spec_num++;
					   $title ="spectrum$spec_num";
                       $mgf{$title}{'title'}=$1;
                       $ms2_scan=$2;					   
			           #$title =$1;
					   if ($ms2_scan-$ms2_last>1){
					        $ms1_scan=$ms2_scan-1;
					   }
					   $ms2_last=$ms2_scan;
					   $mgf{$title}{'ms2_scan'}=$ms2_scan;
					   $mgf{$title}{'ms1_scan'}=$ms1_scan;
					   print "ms2:$ms2_scan\n";
					   $stat{$filename}{'ms2_num'}++;
					   $mgf{$title}{'ms2'}=""; }
			$line=uc($line);
		}elsif($title ne ""){
        if ($_ =~ "^PEPMASS") {
            my $mystring = $_;	
            if ($mystring =~ m/=(\d+\.\d+) ?/){$mgf{$title}{'mz'}= $1;
			    }#elsif($mystring =~ m/=(.*)[\r\n]/){ $mgf{$title}{'mz'}= $1;}
            if ($mystring =~ m/\s+(.*?)[\r\n]/) { $mgf{$title}{'abundance'} = $1 ;}
        } elsif ($_ =~ "^SCANS") {
            my $mystring = $_;
            if ($mystring =~ m/=(.*?)[\r\n]/) { $mgf{$title}{'scan_num'} = $1 }
        } elsif ($_ =~ "^CHARGE") {
            my $mystring = $_;
            if ($mystring =~ m/=(.*?)\+/) { $mgf{$title}{'charge'} = $1 }
        }elsif ($_ =~ "^.[0-9]") {
            my $ms2 = $_;
			$mgf{$title}{'ms2'} = "$mgf{$title}{'ms2'}$ms2";
		}elsif ($_ =~ "^RTINSECONDS") {
		    my $mystring = $_;
		    if ($mystring =~ m/=(.*?)[\r\n]/) { $mgf{$title}{'rt'} = $1 ;}
		}elsif ($_ =~ "^END IONS") {
		    
			if (exists $mgf{$title}{'charge'}){		
                $mgf{$title}{'monoisoptic_mw'} = $mgf{$title}{'mz'} * $mgf{$title}{'charge'} - ($mgf{$title}{'charge'} * 1.00728);
            }
			$title="";
		}
		}
    
    }
	
    return %mgf;

}

#print Dumper(%root);


$end_time = localtime;
my $s = $end_time - $start_time;
print $log "\n---------------------  REPORT  -----------------------\n";
print $log "Start time is $start_time\n";
print $log "The end time is $end_time\n";    
print $log "The used time is: ", $s->minutes," minites.\n";
print $log "---------------------    END   -----------------------\n";
close $log;


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
print "please press anykey ...\n";
<>