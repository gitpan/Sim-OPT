# TO DO: CHECK THE VICINITY of  windows' centres TO @obstacledata

my @centerfront = ( ( $v[0][11][0] + ($v[0][12][0] - $v[0][11][0] ) / 2) , ( $v[0][11][1] + ($v[0][12][1] - $v[0][11][1] ) / 2) , ($v[0][14][2] / 2) );
my @centereast = ( ( $v[0][15][0] + ($v[0][16][0] - $v[0][15][0] ) / 2) , ( $v[0][15][1] + ($v[0][16][1] - $v[0][15][1] ) / 2) , ($v[0][18][2] / 2) );
my @centerback = ( ( $v[0][20][0] + ($v[0][19][0] - $v[0][20][0] ) / 2) , ( $v[0][20][1] + ($v[0][19][1] - $v[0][20][1] ) / 2) , ($v[0][22][2] / 2) );
my @centerwest = ( ( $v[0][24][0] + ($v[0][23][0] - $v[0][24][0] ) / 2) , ( $v[0][24][1] + ($v[0][23][1] - $v[0][24][1] ) / 2) , ($v[0][25][2] / 2) );

my @winpoints = push ( @winpoint , [@centerfront], [@centereast], [@centerback], [@centerwest] );

foreach my $winpoint (@winpoints)
{
	my @windowpoint = @{$winpoint};
	foreach my $obspoint (@obspoints)
	{
		@obstructionpoint = @{$obspoint);
		my $xlenght = ( $obstructionpoint[0] - $windowpoint[0] );
		my $ylenght = ( $obstructionpoint[1] - $windowpoint[1] );
		my $truedistance = sqrt ( ( $xlenght ** 2 ) + ( $ylenght ** 2 ) );
		my $heightdifference = ($obstructionpoint[2 ] - $windowpoint[2] );
		@differences = push( @differences, [ $truedistance ], [ $heightdifference ] );
		
	}
	
}

foreach my $difference ( @differences)
{
	@diff = @{$difference};
	my $ratio = ( $diff[0] / $diff[1} );
	@ratios = push (@ratios, $ratio);
}

if ( min(@ratio) > 6 ){ $nodesdata[$counternode][2] = "c"; } 
elsif ( ( min(@ratio) >= 3 ) and ( min(@ratio) <= 6 ) )  { $nodesdata[$counternode][2] = "g"; } 
elsif ( ( min(@ratio) < 3 ) )  { $nodesdata[$counternode][2] = "k"; } 





