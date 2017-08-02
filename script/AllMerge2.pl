
#############################################################################
#name:AllMerge#perl2exe_exclude "Text//Glob.pm";
#function:merging mutilfiles bases on left colume
#version:1.0
#Date:20160508
#E-Mail:wjlong0318@163.com
#usage:put your all files(only csv format) and this program into the same folder,the run the program
#############################################################################

use strict;
#use File::DosGlob 'glob';
use 5.010;
use Text::CSV_XS;
use Spreadsheet::ParseExcel;
use Spreadsheet::XLSX;
use Tk;
print "...............starting............\n";
my $mw = MainWindow->new;
$mw->geometry("550x300");
$mw->title("AllMerge2");

my $main_menu = $mw->Menu();
$mw->configure( -menu => $main_menu );
my $file_menu =
  $main_menu->cascade( -label => "File", -underline => 0, -tearoff => 0 );
$file_menu->command(
    -label     => "Open Files",
    -underline => 0,
    -command   => \&merge
);
$file_menu->command(
    -label     => "Exit",
    -underline => 0,
    -command   => sub { exit }
);
my $help_menu =
  $main_menu->cascade( -label => "help", -underline => 0, -tearoff => 0 );
$help_menu->command( -label => "help", -underline => 0, -command => \&help );
my $message = "AllMerge v2.0\nCopyright 2016 WANG\nAll rights reserved.\n";
$help_menu->command(
    -label     => "about",
    -underline => 0,
    -command   => sub { $mw->messageBox( -message => $message, -type => "ok" ) }
);

sub help {
    my $message = "Please email to WANG(<wjlong0318\@163.com>)";
    $mw->messageBox( -message => $message, -type => "ok" );

}

my $scroll_text = $mw->Scrollbar();

my $main_text = $mw->Text(
    -yscrollcommand => [ 'set',     $scroll_text ],
    -background     => 'white',
    -foreground     => 'black',
    -font           => [ 'courier', '12' ]
);

$scroll_text->configure( -command => [ 'yview', $main_text ] );

$scroll_text->pack( -side => "right", -expand => "no", -fill => "y" );
$main_text->pack(
    -side   => "left",
    -anchor => "w",
    -expand => "yes",
    -fill   => "both"
);
$main_text->insert( "end",
        "#" x 20
      . "\nAllMerge v2.0\nEMAIL:wjlong0318\@163.com\nCopyright 2016 WANG\nAll rights reserved.\n"
      . "#" x 20 );
MainLoop;

my %root;
my %lenline;
my @gene_list;
my @mergefiles;
my @filenames = ();

sub merge {

    my $dirname = $mw->chooseDirectory(
        -initialdir => '.',
        -title      => 'Choose a directory'
    );
    if ($dirname) { @filenames = glob("$dirname/*"); }

    #if (@filenames == ()){@filenames=glob('.\\*');}
    #print "@filenames\n";
    $main_text->insert( "end", "\n...............starting............\n" );
    foreach my $file (@filenames) {

        given ($file) {
            when (/\.csv$/) {
                say "$file:Name is csv";
                &csv2hash($file);
                push @mergefiles, $file;
            }
            when (/\.txt$/) {
                say "$file:Name is txt";
                &txt2hash($file);
                push @mergefiles, $file;
            }
            when (/\.xlsx$/) {
                say "$file:Name is xlsx";
                &xlsx2hash($file);
                push @mergefiles, $file;
            }
            when (/\.xls$/) {
                say "$file:Name is xls";
                &xls2hash($file);
                push @mergefiles, $file;
            }
            default { say "$file: unmatch"; }
        }

    }
    ####output summary file#####
    #print "output summary file......\n";
    $main_text->insert( "end", "output summary file......\n" );
    mkdir "result";
    open( my $result, ">result\\summary.csv" )
      or die "Can't open summary.csv: $!",$mw->messageBox( -message => "can not open the result file", -type => "ok" );
    foreach my $gene (@gene_list) {
        my $line = $gene;
        foreach my $filename (@mergefiles) {
            if ( exists $root{$filename}{$gene} ) {
                $line = "$line,$root{$filename}{$gene}";
            }
            else {
                $line = "$line" . ",NA" x $lenline{$filename};
            }
        }

        #print "$line\n";
        print $result "$line\n";

    }

    sub csv2hash {
        my ($file) = @_;
        #say "the $file to hash......";
        $main_text->insert( "end", "read the $file ......\n" );
        my $csv_format = Text::CSV_XS->new(
            {
                sep_char    => q{,},
                escape_char => q{\\},
                quote_char  => q{"},
            }
        );
		open my $io, "<", $file or die "$file: $!";
		my @data;
        while (my $row = $csv_format->getline ($io)) {
            push @data, $row;
     }
        $data[0][0] = "ACC";
        &do_annotation( $file, \@data );
    }

    sub txt2hash {
        my ($file) = @_;
        #say "read the $file......";
        $main_text->insert( "end", "read the $file......\n" );
        my @data;
        open my $in, '<', $file or $mw->messageBox( -message => "can not open the $file", -type => "ok" );#die "can not open the file";
        while ( my $line = <$in> ) {
            chomp($line);
            my @ones = split( /\t/, $line );
            push @data, \@ones;
        }
        $data[0][0] = "ACC";
        &do_annotation( $file, \@data );
    }

    sub xls2hash {
        my ($file) = @_;
        #say "the $file to hash......";
        $main_text->insert( "end", "read the $file......\n" );
        my $parser   = Spreadsheet::ParseExcel->new();
        my $workbook = $parser->parse($file);
        if ( !defined $workbook ) {
		    $mw->messageBox( -message => "can not open the $file", -type => "ok" );
            die $parser->error(), ".\n";
        }
        for my $worksheet ( $workbook->worksheets() ) {
            my ( $row_min, $row_max ) = $worksheet->row_range();
            my ( $col_min, $col_max ) = $worksheet->col_range();
            my @data;

            #$row_min=$row_min-1;
            #say "$row_min, $row_max,$col_min, $col_max\n";
            for my $row ( $row_min .. $row_max ) {
                my @ones;
                for my $col ( $col_min .. $col_max ) {
                    my $cell = $worksheet->get_cell( $row, $col );
                    if ($cell) {
                        push @ones, $cell->value();
                    }
                    else {
                        push @ones, "NA";
                    }
                }
                push @data, \@ones;
            }
            $data[0][0] = "ACC";
            &do_annotation( $file, \@data );
        }
    }

    sub xlsx2hash {
        my ($file) = @_;
        #say "the $file to hash......";
        $main_text->insert( "end", "read the $file......\n" );
        my $excel = Spreadsheet::XLSX->new($file);
        foreach my $sheet ( @{ $excel->{Worksheet} } ) {
            my @data;
            $sheet->{MaxRow} ||= $sheet->{MinRow};
            foreach my $row ( $sheet->{MinRow} .. $sheet->{MaxRow} ) {
                my @ones;
                $sheet->{MaxCol} ||= $sheet->{MinCol};
                foreach my $col ( $sheet->{MinCol} .. $sheet->{MaxCol} ) {
                    my $cell = $sheet->{Cells}[$row][$col];
                    if ($cell) {
                        push @ones, $cell->{Val};
                    }
                    else {
                        push @ones, "NA";
                    }
                }
                push @data, \@ones;
            }
            $data[0][0] = "ACC";
            &do_annotation( $file, \@data );    #\_$sheet->{Name}
        }

    }

    sub do_annotation {
        my ( $file, $data ) = @_;
        my @data    = @{$data};
        my $linenum = 0;
        foreach my $line (@data) {
            my @ones = @{$line};
            @ones = map { s/,/\_/; $_; } @ones;
            $lenline{$file} = $#ones if ( $#ones > $lenline{$file} );
            chomp( $ones[0] );
            $ones[0] =~ s/\s//;
            $ones[0] =~ tr/[a-z]/[A-Z]/;
            my $gene = $ones[0];
            if ( $gene ~~ @gene_list ) { }
            else {
                push @gene_list, $gene;
            }
            shift(@ones);

            #$file =~ s/.*\///;
            @ones = map { $_ . "($file)" } @ones if ( $linenum == 0 );
            $linenum++;
            my $anotation = join( ",", @ones );
            if ( $#ones < $lenline{$file} ) {
                my $less = $lenline{$file} - $#ones - 1;
                $anotation = "$anotation" . ",NA" x $less;
            }
            $root{$file}{$gene} = $anotation;
        }
    }

    #print Dumper(%root);
    #print "...............completed............\n";
    $main_text->insert( "end", "..............completed............\n" );
    $main_text->insert( "end", "The Merge-file is in the \n$dirname/result\n" );
}

