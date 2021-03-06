#!/lustre1/zeminz_pkuhpc/01.bin/perl-5.24/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $usage = "Usage:  perl  $0  <Pair>   <CellInfo>  >Out\n";
die $usage if @ARGV  !=2;

###  panC.VDJpair.txt  generated by vdj2pair.pl 
my $header1 = "";
my %pair = ();
my $ncol = 0;
open INV, $ARGV[0];
while (<INV>){
	# 0       1         2        3       4      5        6
	#pairID  CDR3.AB   VDJtype  cellID  libID  nUMI.A   nUMI.B
	chomp;
	my @t = split /\s+/;
	if ($.==1){
		$header1 = $_;
		$ncol = @t;
		next;
	}
	push @{$pair{$t[3]}}, $_;
}
close INV;

#print Dumper \%pair;exit;

###  CellInfo.txt  generated  by  panC_seu2info.R
open INC, $ARGV[1];
while (<INC>){
	# 0       1       2       3       3
	#cellID  libID   info1   info2   info3 ...
	chomp;
	my @t = split /\t/;
	my $cid = shift @t;
	my $lid = shift @t;
	my $info = join("\t", @t);
	if ($.==1){
		## header2
		print "$header1\t$info\n";
		next;
	}
	##### OUT
	if (exists $pair{$cid}){
		foreach my $this ( @{$pair{$cid}} ){
			print "$this\t$info\n";
		}
	}
	### add space line for un-recorded cells
	#else{
	#	my @spaces = ("-") x $ncol;
	#	$spaces[3] = $cid;
	#	$spaces[4] = $lid;
	#	print join("\t",@spaces) . "\t$info\n";
	#}
}
close INC;


