#!/lustre1/zeminz_pkuhpc/01.bin/perl-5.24/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $usage = "Usage:  perl  $0  <VDJ.format>   <CellInfo>  >Out\n";
die $usage if @ARGV  !=2;

###  panC.vdj.format.txt
my $header1 = "";
my %vdj = ();
my $ncol = 0;
open INV, $ARGV[0];
while (<INV>){
	# 0       1         2       3       4               5        6         7              8        9        10              11       12        13             14       15        ...
	#cellID  patientID libID   VDJtype Identifier.A1   CDR3.A1  nUMI.A1  Identifier.A2   CDR3.A2  nUMI.A2  Identifier.B1   CDR3.B1  nUMI.B1  Identifier.B2   CDR3.B2  nUMI.B2    ...
	chomp;
	my @t = split /\t/;
	if ($.==1){
		$header1 = $_;
		$ncol = @t;
		next;
	}
	$vdj{$t[0]} = $_;
}
close INV;


open INC, $ARGV[1];
while (<INC>){
	# 0       1       2       3
	#cellID  info1   info2   info3 ...
	chomp;
	my @t = split /\t/;
	my $cid = shift @t;
	my $info = join("\t", @t);
	if ($.==1){
		## header2
		print "$header1\t$info\n";
		next;
	}
	##### OUT
	if (exists $vdj{$cid}){
		print "$vdj{$cid}\t$info\n";
	}else{
        my @spaces = ("-") x $ncol;
        $spaces[0] = $cid;
        print join("\t", @spaces) . "\t$info\n";
    }
}
close INC;






