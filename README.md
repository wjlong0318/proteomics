

	#proteomics utilities	
[proteomics web](https://protutilities.sourceforge.io/)


=======Copyright

		Copyright (C) 2017, WANG Limited.
		contact:wjlong0318@163.com
		
		This script is free software. You can redistribute and/or                 
		modify it under the terms of the GNU General Public License              
		as published by the Free Software Foundation; either version 2           
		of the License or, (at your option), any later version.                  
                                                                          
		These modules are distributed in the hope that they will be useful,       
		but WITHOUT ANY WARRANTY; without even the implied warranty of            
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the              
		GNU General Public License for more details.    

		
 

=======	IDconvert.pl

		script/IDconvert.pl 20170804		
		function:fasta file blast fasta file for id matching
				 out file, seperated with comma, can be opened by excel
		out file format:
			query,subject,Identities,query match length,mismatches,
			gap openings,query start,query end,sbject start,sbject end,E Value,Score
		blastp -evalue 0.000001
		Usage:   perl IDconvert.pl [filepath]
		Usage:   if you do not use parameter,
		         you could put two fasta files and IDconvert.pl file into same folder,
				 then double-click
		Example: perl IDconvert.pl input
			     perl IDconvert.pl
				 
======= AllMerge.pl

		script/AllMerge.pl 20170804
		function:merging mutilfiles(CSV) bases on left colume
		version:1.01
		Usage:   perl AllMerge.pl [filepath]
		Usage:   if you do not use parameter,
		         you could put all csv files and AllMerge.pl file into same folder,
				 then Double-click
		Example: perl Almerge.pl input
                 perl Almerge.pl

======= csv2fasta.pl

		script/csv2fasta.pl 20170804
		function:convert csv to fasta
		version:1.01
		Usage:   perl csv2fasta.pl [filepath]
		Usage:   if you do not use parameter,
		         you could put all csv files and csv2fasta.pl file into same folder,
				 double-click
		Example: perl csv2fasta.pl input
                 perl csv2fasta.pl
		
======= fasta2csv.pl

		script/fasta2csv.pl 20170804
		function:convert fasta to csv
		version:1.01
		Usage:   perl fasta2csv.pl [filepath]
		Usage:   if you do not use parameter,
		         you could put all csv files and fasta2csv.pl file into same folder,
				 double-click
		Example: perl fasta2csv.pl input
                 perl fasta2csv.pl

======= md5.pl

		script/md5.pl 20170804
		function:caculate MD5 value of all files in  current folder
		version:1.01		
		Usage:put all files and MD5.pl file into same folder,double-click

======= add_motif.pl		
 
		script/add_motif.pl 20170814
		function:add motif for sequence windows basing on last column\n";
		Usage:   perl add_motif.pl [filepath]\n";
		Usage:   if you do not use parameter,you could put csv files and add_motif.pl file into same folder\n";
		Example: perl add_motif.pl input\n";
				 perl add_motif.pl\n";
