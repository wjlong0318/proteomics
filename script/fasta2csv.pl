#####################################
#从protein.fasta读取序列中,写入csv中#
#####################################
use strict;
use Time::Piece;
use Time::Seconds;

#输出初始时间
my $start_time = localtime;    
print "Start time is $start_time";

#声明变量
my $protein_num=-1;
my $protein_name;
my $seq;
my @files=glob '*.fasta';
for my $file (@files){
   &fasta2csv($file);
}

sub fasta2csv{
my ($file)=@_;
#打开源文件、创建写入结果的文件
open (SOURCE,$file) || die "Can't open myfile: $!";
open (RESULT,">$file.csv") or die "can't open result:$!";
#在结果文件中写入表头
print RESULT "protein_num,protein_name,seq\n";
#开始读源文件
while(<SOURCE>){
    if (/\>(.+)/){            
        $protein_num++;
		#写入数据
        if( $protein_num ne 0 ){
            print "reading $protein_name***\n";
            #删除seq的所有空格
			$seq=~s/\s//g;
			##写入行数据
			print RESULT "$protein_num,$protein_name,$seq\n";
	    }            
        $seq='';
        $protein_name=$1;
		$protein_name=~s/\,/\|/g;
    }else{
        $seq=$seq.$_;
    }
}
print "reading $protein_name***";
$seq=~s/\s//g;
$protein_num++;
print RESULT "$protein_num,$protein_name,$seq\n";
#关闭文件
close RESULT;
close SOURCE;
}
my $end_time = localtime;
my $s = $end_time - $start_time;
print "The end time is $end_time";    
print "The time of wasting  is: ", $s->minutes,"minites.";
print "\nThe $protein_num  proteins had alreadly writed \nplease press anykey continue~~~~~~";
<> 
 