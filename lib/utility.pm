use strict;

package utility;
use base 'Exporter';


our @EXPORT = ('digest_protein','mods2hash', 'import_mgf', 'import_modifications', 'import_xlinkers','import_fasta');

my %protein_residuemass = (
    G => 57.02146,
    A => 71.03711,
    S => 87.03203,
    P => 97.05276,
    V => 99.06841,
    T => 101.04768,
    C => 103.00919,
    L => 113.08406,
    I => 113.08406,
    X => 113.08406,    # (L or I)
    N => 114.04293,
    O => 114.07931,
    B => 114.53494,    # (avg N+D)
    D => 115.02694,
    Q => 128.05858,
    K => 128.09496,
    Z => 128.55059,    #(avg Q+E)
    E => 129.04259,
    M => 131.04049,
    H => 137.05891,
    F => 147.06841,
    R => 156.10111,
    Y => 163.06333,
    W => 186.07931
  );

my $mass_of_proton    = 1.00728;
my $mass_of_hydrogen = 1.00783;

sub unique{
    my @arr=@_;
	my @arr_unique;
	if(@arr){
    my %count;
    @arr_unique = grep { ++$count{ $_ } < 2; } @arr;
	}
	return @arr_unique;
	
}
sub import_mgf{
    
    my ($filename,$log) = @_;
    open FILE, "<$filename", or die "Error: Cannot open MGF."; 
  
    print "Importing $filename ... \n";
    print $log "Importing $filename ... \n";
    my %mgf;
	my $dataset=0;
	my $title="";
    while (<FILE>) {
        if ($_ =~ "^BEGIN IONS") { $dataset = $dataset + 1; 
		
		}elsif ($_ =~ /^TITLE/) {
			my $line=$_;
			if ($line =~ m/=(.*?)[\r\n]/) { $title = $1; $mgf{$title}{'ms2'}=""; }
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
sub import_modifications{
    
    my ($filename,$log)=@_;
    open FILE, "<$filename", or die "Error: Cannot open modifications.ini"; 
    print $log "Importing $filename ... \n";
    print  "Importing $filename ... \n";
    my %mods;
	my $name="";

    while (<FILE>) {
	    if (/^name\d*=(.*) /) { $name =$1;$mods{$name}{'mass'}=-1; 
		   
		
		}elsif ($name ne "") {
            my $mystring = $_;
            if ($mystring =~ m/(\-?\d+\.\d+) (\-?\d+\.\d+)/) { $mods{$name}{'mass'}=$1;$name=""; } 
		}else{}
	}
	return %mods;
	
}
sub import_xlinkers{
    my ($filename,$log)=@_;
    open FILE, "<$filename", or die "Error: Cannot open xlink.ini"; 
    print "Importing $filename ... \n";
    print $log "Importing $filename ... \n";
    my %linkersets;
	my $name="";

    while (<FILE>) {
	    if (/^name\d*=(.*)\n/) { 
		    $name =$1;
			$linkersets{$name}{'mass'}=-1; 
			$linkersets{$name}{'aa'}=-1; 
			$linkersets{$name}{'aa2'}=-1; 
		   
		
		}elsif ($name ne "") {
            my $mystring = $_;
		
            if ($mystring =~ m/$name=(.*)/) {
             
			    my @linkinfo=split(" ",$1);
				$linkersets{$name}{'mass'}=$linkinfo[2];
				$linkersets{$name}{'aa'}=$linkinfo[0];
				$linkersets{$name}{'aa2'}=$linkinfo[1];
				$name=""; 
			} 
		}else{}
	}
	return %linkersets;
}
sub import_fasta{
	my ($db,$log) = @_;
    print "import $db\n";
    print $log "import $db\n";
	my %rh_id_seq;

	if ( defined($db) ) {
		if ( -e $db ) {
			my @seq = ();
			my $id  = '';
            my $header='';
			my $gene_name='';
			open( DB, $db ) or warn $!;
			while (<DB>) {
				my $line = $_;
				chomp($line);
				if ( substr( $line, 0, 1 ) eq '>' ) {
					if (defined $seq[0] ){
					$rh_id_seq{$id}{'seq'} = join( '', @seq );
					$rh_id_seq{$id}{'header'} = $header;
					$rh_id_seq{$id}{'gn'} = $gene_name;
					  }
					if ( $line =~ /^>([^\s]+)/ ) {
						$line =~ /^>([^\s]+)/;
						$id = $1;
						$header=$line;
						if ($line =~ /GN=(\w+) /){
						    $gene_name=$1;
						}
					}
					else {
						$id = '';
						$header='';
			            $gene_name='';
						
					}
					@seq = ();
				}
				elsif ( $line =~ /[A-Za-z]/ ) {
					push @seq, $line;
				}
			}
			close(DB);
			if (defined $seq[0] ){
			    $rh_id_seq{$id}{'seq'} = join( '', @seq );
				$rh_id_seq{$id}{'header'} = $header;
				$rh_id_seq{$id}{'gn'} = $gene_name;
			}

		}
		else {
			print "  Could not find $db!\n";
		}
	}
	else {
		print "  input fasta db not defined!\n";
	}

	return %rh_id_seq;
}
sub mods2hash{    
    
    my ($str)=@_;
	my %ref;
    my @mods=split("\,",$str);
	foreach my $a (@mods){
	     my @tem=split(":",$a);
	    $ref{$tem[0]}=$tem[1];
        		
	}
    return %ref;

}
sub digest_protein{    
	my ($fasta_ref, $min_pep_length, $nr_missed_cleavages, $min_pep_mass,
		$max_pep_mass )
	  = @_;

	my %peps;
	my %fasta=%{$fasta_ref};
    print "digest proteins...\n";
    foreach my $protein (keys %fasta){
	my $aa=$fasta{$protein}{'seq'};
	my @rh_pep;
	my $nr_pep = 0;

	my $aa_length = length($aa);
	my $last_pos  = $aa_length - 1;

	# optimized
	my ( $ra_starts, $ra_ends ) =
	  get_trypt_coor( $aa, $aa_length, $last_pos );

	# optimized
	my $nr_ends         = @$ra_ends;
	my $last_ends_index = $nr_ends - 1;
	my $count           = 0;

	# loop through all the starts
	for ( my $i = 0 ; $i < @$ra_starts ; $i++ ) {
		my $highest_end = $i + $nr_missed_cleavages;
		$highest_end = $last_ends_index if $highest_end > $last_ends_index;

		# loop through the ends
		for ( my $j = $i ; $j <= $highest_end ; $j++ ) {

			my $pep_length = $ra_ends->[$j] - $ra_starts->[$i] + 1;
			if ( $pep_length >= $min_pep_length ) {

				my $pep_aa = substr( $aa, $ra_starts->[$i], $pep_length );
				my $mass   = &get_pep_mass($pep_aa);
                my $temlen=length($pep_aa);
				#print "$temlen\n";
				# check the mass constraint for the peptide
				if ( $mass >= $min_pep_mass && $mass <= $max_pep_mass ) {
					$count++;
					
					if (exists $peps{$pep_aa}{'id'}){
					    $peps{$pep_aa}{'id'}="$peps{$pep_aa}{'id'};$protein";
						$peps{$pep_aa}{'pos'}="$peps{$pep_aa}{'pos'};$i";
					}else{
					    $peps{$pep_aa}{'id'}="$protein";
						$peps{$pep_aa}{'pos'}=$i;
					}
					
				}
			}
		}
	}
    }
    return %peps;	
}

sub get_trypt_coor {
	my ( $aa, $aa_length, $last_pos ) = @_;

	# save coordinates of all possible peptide starts and ends
	my @starts = ();
	my @ends   = ();

	push @starts, 0;

	# use of [KR][^P] not straightforward because of
	# problematic handling of ..KKK..
	while ( $aa =~ /[KR]/g ) {
		my $pos = pos($aa);
		if ( $pos <= $last_pos ) {
			if ( substr( $aa, $pos, 1 ) ne 'P' ) {
				push @starts, $pos;
				push @ends,   $pos - 1;
			}
		}
	}

	push @ends, $last_pos;

	return ( \@starts, \@ends );
}
sub get_pep_mass{
    #print "peptide fragment...\n";
    my ($seq) =@_;
	#print "$title";
	
	my $peptide_mass=0;
    my $terminalmass        = 1.0078250 * 2 + 15.9949146 * 1;
	
    
	#print "$seq";
    if ( defined $seq && $seq =~ /[ARNDCEQGHILKMFPSTWYV]/ ) {
	my @residues = split //, $seq;
	my $num=0;
	my $pep_len=@residues;
	
    my $residue_mass=$mass_of_proton;
	foreach my $residue (@residues){    #split the peptide in indivual amino acids
        $residue_mass=$residue_mass+$protein_residuemass{$residue}; 
	}
	
    $peptide_mass = $residue_mass + $terminalmass;
	}
    return $peptide_mass;

}