#!/lustre1/zeminz_pkuhpc/01.bin/perl-5.24/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $usage = "Usage:  perl  $0  <VDJ.format>   >Out\n";
die $usage if @ARGV  !=1;

###  panC.vdj.format.txt
my %pair = ();
open INV, $ARGV[0];
while (<INV>){
	# 0       1          2       3               4        5        6               7        8        9               10       11       12              13       14      15
	#cellID  patientID  libID   VDJtype Identifier.A1   CDR3.A1  nUMI.A1  Identifier.A2   CDR3.A2  nUMI.A2  Identifier.B1   CDR3.B1  nUMI.B1  Identifier.B2   CDR3.B2  nUMI.B2
	next if $.==1;
	chomp;
	my @t = split /\t/;
	my @a = ([$t[4],$t[5], $t[6]],  [$t[7], $t[8], $t[9]]);
	my @b = ([$t[10],$t[11],$t[12]], [$t[13],$t[14],$t[15]]);
	foreach my $this_a (@a){
		next if $this_a->[0] eq "-";
		foreach my $this_b (@b){
			next if $this_b->[0] eq "-";
			#name:  Identifier.A + Identifier.B
			my $id = "$this_a->[0]+$this_b->[0]";
			$pair{$id}{'CDR3.AB'} = "$this_a->[1]+$this_b->[1]";
			$pair{$id}{'VDJtype'} = $t[3];
			push @{$pair{$id}{'cellID'}}, $t[0];
			push @{$pair{$id}{'patientID'}}, $t[1];
			push @{$pair{$id}{'nUMI.A'}}, $this_a->[2];
			push @{$pair{$id}{'nUMI.B'}}, $this_b->[2];
		}
	}
}
close INV;

#print Dumper \%pair;exit;

### OUT
print "pairID\tCDR3.AB\tVDJtype\tcellID\tpatientID\tnUMI.A\tnUMI.B\n";
foreach my $pairID (sort keys %pair){
	my $nums = @{$pair{$pairID}{'cellID'}};
	my $out1 = "$pairID\t$pair{$pairID}{'CDR3.AB'}\t$pair{$pairID}{'VDJtype'}";
	foreach my $this_idx (0 .. $nums-1 ){
		print "$out1\t$pair{$pairID}{'cellID'}->[$this_idx]\t$pair{$pairID}{'patientID'}->[$this_idx]\t$pair{$pairID}{'nUMI.A'}->[$this_idx]\t$pair{$pairID}{'nUMI.B'}->[$this_idx]\n";
	}
}



