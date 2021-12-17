#!/lustre1/zeminz_pkuhpc/01.bin/perl-5.24/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $usage = "Usage:  perl  $0  <in.VDJ>  <lib2patient.txt>  >Out\n";
die $usage if @ARGV  !=2;

my %lid2pid = ();
open L2P, $ARGV[1];
while(<L2P>){
	chomp;
	my @t = split /\t/;
	$lid2pid{$t[0]} = $t[1];
}
close L2P;

my %cellInfo = ();
if ($ARGV[0]=~/\.gz$/){
	open INV, "gzip -dc $ARGV[0]|";
}else{
	open INV, $ARGV[0];
}
while (<INV>){
	# 0         1        2          3                 4       5     6            7         8        9       10            11         12     13       14      15     16                17                          18
	# barcode   is_cell  contig_id  high_confidence  length  chain  v_gene       d_gene   j_gene    c_gene  full_length  productive  cdr3   cdr3_nt  reads   umis  raw_clonotype_id  raw_consensus_id            library.id
	next if $.==1;
	chomp;
	my @t = split /\t/;
	#next until ($t[1] eq "TRUE" && $t[3] eq "TRUE" && $t[10] eq "TRUE" && $t[11] eq 'True' && ($t[5] ne 'None' && $t[5] ne 'Multi'));
	next until ($t[1] =~ /TRUE/i && $t[3] =~ /TRUE/i && $t[10] =~ /TRUE/i && $t[11] =~ /True/i && ($t[5] !~ /None/ && $t[5] !~ /Multi/));
	my $this_chain = $t[5];
	my $this_detail = "$t[6]|$t[7]|$t[8]|$t[9]|$t[13]";
	my $patientID = $lid2pid{$t[18]};
	## save
	$cellInfo{$t[0]}{'patientID'} = $patientID;
	$cellInfo{$t[0]}{'libID'} = $t[18];
	$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'umi'} = $t[15];
	$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'read'} = $t[14];
	$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'umi.read'} = "$t[15].$t[14]";  # update at 2021.01.04: rank first by umis, then by reads
	#$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'v'} = $t[6];
	#$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'d'} = $t[7];
	#$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'j'} = $t[8];
	#$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'c'} = $t[9];
	#$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'cdr3nt'} = $t[13];
	$cellInfo{$t[0]}{'chains'}{$this_chain}{$this_detail}{'cdr3pep'} = $t[12];
}
close INV;

#print Dumper \%cellInfo; exit;

print "cellID\tpatientID\tlibID\tVDJtype\tIdentifier.A1\tCDR3.A1\tnUMI.A1\tIdentifier.A2\tCDR3.A2\tnUMI.A2\tIdentifier.B1\tCDR3.B1\tnUMI.B1\tIdentifier.B2\tCDR3.B2\tnUMI.B2\n";
foreach my $id (sort keys %cellInfo){
	## define 4 combs:   T_ab   T_gd   B_lh   B_kh
	my %comb = (
		'T_TRA_TRB' => {
			'count' => 0,
			'info' => '',
		},
		'T_TRG_TRD' => {
			'count' => 0,
			'info' => '',
		},
		'B_IGL_IGH' => {
			'count' => 0,
			'info' => '',
		},
		'B_IGK_IGH' => {
			'count' => 0,
			'info' => '',
		}
	);
	###  count each comb and save info
	foreach my $this_comb (sort keys %comb){
		my ($type, $c1, $c2) = split /_/, $this_comb;
		next unless (exists $cellInfo{$id}{'chains'}{$c1} && exists $cellInfo{$id}{'chains'}{$c2});
		## deal each chain (count only top2 for each chain)
		foreach my $this_c ($c1,$c2){
			my %tmp_hash = %{$cellInfo{$id}{'chains'}{$this_c}};
			my $n = 0;
			foreach my $this_detail (sort {$tmp_hash{$b}{'umi.read'} <=> $tmp_hash{$a}{'umi.read'}} keys %tmp_hash){  # update at 2021.01.04: rank first by umis, then by reads
				$n++;
				last if $n>2;
				$comb{$this_comb}{'count'} += $tmp_hash{$this_detail}{'umi'};
				if ($comb{$this_comb}{'info'}){
					$comb{$this_comb}{'info'} = "$comb{$this_comb}{'info'}\t$this_detail\t$tmp_hash{$this_detail}{'cdr3pep'}\t$tmp_hash{$this_detail}{'umi'}";
				}else{
					$comb{$this_comb}{'info'} = "$this_detail\t$tmp_hash{$this_detail}{'cdr3pep'}\t$tmp_hash{$this_detail}{'umi'}";
				}
			}
			## only have one 'detail' record
			if ($n==1){
				 $comb{$this_comb}{'info'} = "$comb{$this_comb}{'info'}\t-\t-\t-";
			}
		}
	}
	### choose the most abundant one comb, and output
	my $choose = (sort {$comb{$b}{'count'}<=>$comb{$a}{'count'}} keys %comb)[0];
	if ($comb{$choose}{'count'}>0){
		my ($type, $c1, $c2) = split /_/, $choose;
		print "$id\t$cellInfo{$id}{'patientID'}\t$cellInfo{$id}{'libID'}\t$choose\t$comb{$choose}{'info'}\n";
	}
}



