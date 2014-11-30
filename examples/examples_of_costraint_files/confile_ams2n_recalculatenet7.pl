
my @centerfront = ( ( $v[0][11][0] + ($v[0][12][0] - $v[0][11][0] ) / 2) , ( $v[0][11][1] + ($v[0][12][1] - $v[0][11][1] ) / 2) , ($v[0][14][2] / 2) );
my @centereast = ( ( $v[0][15][0] + ($v[0][16][0] - $v[0][15][0] ) / 2) , ( $v[0][15][1] + ($v[0][16][1] - $v[0][15][1] ) / 2) , ($v[0][18][2] / 2) );
my @centerback = ( ( $v[0][20][0] + ($v[0][19][0] - $v[0][20][0] ) / 2) , ( $v[0][20][1] + ($v[0][19][1] - $v[0][20][1] ) / 2) , ($v[0][22][2] / 2) );
my @centerwest = ( ( $v[0][24][0] + ($v[0][23][0] - $v[0][24][0] ) / 2) , ( $v[0][24][1] + ($v[0][23][1] - $v[0][24][1] ) / 2) , ($v[0][25][2] / 2) );
		

push ( @winpoints , [@centerfront] );
push ( @winpoints , [@centereast] );
push ( @winpoints , [@centerback] );
push ( @winpoints , [@centerwest] );

foreach my $winpoint (@winpoints)
{
	@windowpoints = @{$winpoint};
	
	foreach my $obspoint (@obspoints)
	{
		my @obstructionpoints = @{$obspoint};
		my $xlenght = ( $obstructionpoints[0] - $windowpoints[0] );
		my $ylenght = ( $obstructionpoints[1] - $windowpoints[1] );
		my $xytruedistance = sqrt ( ( $xlenght ** 2 ) + ( $ylenght ** 2 ) );
		my $heightdifference = ($obstructionpoints[2 ] - $windowpoints[2] );
		push( @differences, [ $xytruedistance, $heightdifference ] );
	}
}
		
$windimxfront =  sqrt( ( ($v[0][12][0] - $v[0][11][0]) ** 2) + ( ($v[0][12][1] - $v[0][11][1]) ** 2) ); $windimxfront = sprintf ("%.3f", $windimxfront );
$windimyfront = ($v[0][14][2] - $v[0][11][2])  ; $windimyfront = sprintf ("%.3f", $windimyfront );
$windimxback =  sqrt( ( ($v[0][19][0] - $v[0][20][0]) ** 2) + ( ($v[0][19][1] - $v[0][20][1]) ** 2) ) ; $windimxback = sprintf ("%.3f", $windimxback );
$windimyback = ($v[0][22][2] - $v[0][19][2])  ; $windimyback = sprintf ("%.3f", $windimyback );
$windimxeast =  sqrt( ( ($v[0][16][0] - $v[0][15][0]) ** 2) + ( ($v[0][16][1] - $v[0][15][1]) ** 2) ) ; $windimxeast = sprintf ("%.3f", $windimxeast );
$windimyeast = ($v[0][18][2] - $v[0][15][2])  ; $windimxeast = sprintf ("%.3f", $windimxeast );
$windimxwest =  sqrt( ( ($v[0][23][0] - $v[0][24][0]) ** 2) + ( ($v[0][23][1] - $v[0][24][1]) ** 2) ) ; $windimxwest = sprintf ("%.3f", $windimxwest );
$windimywest = ($v[0][26][2] - $v[0][23][2])  ; $windimywest = sprintf ("%.3f", $windimywest );

@windimsfront = ( $windimxfront , $windimyfront ) ; 
@windimsback = ( $windimxback , $windimyback ) ;
@windimseast = ( $windimxeast , $windimyeast ) ; 
@windimswest = ( $windimxwest , $windimywest ) ;

push (@windsims, [@windimsfront]);
push (@windsims, [@windimsback]);
push (@windsims, [@windimseast]);
push (@windsims, [@windimswest]);

foreach my $windsim (@windsims)
{
	my $windarea = $$windsim[0] * $$windsim[1];
	push (@windareas, $windarea);
}

$jointfront = ( ( ( $windimsfront[0] * 2 ) + ($windimsfront[1] * 2 ) )  * 1.5 );  $jointfront = sprintf("%.3f", $jointfront );
$jointback = ( ( ( $windimsback[0] * 2 ) + ($windimsback[1] * 2 ) )  * 1.5 ); $jointback = sprintf("%.3f", $jointback );
$jointeast = ( ( ( $windimseast[0] * 2 ) + ($windimseast[1] * 2 ) )  * 1.5 ); $jointeast = sprintf("%.3f", $jointeast );
$jointwest = ( ( ( $windimswest[0] * 2 ) + ($windimswest[1] * 2 ) )  * 1.5 ); $jointwest = sprintf("%.3f", $jointwest );
push (@jointlenghts, $jointfront);
push (@jointlenghts, $jointback);
push (@jointlenghts, $jointeast);
push (@jointlenghts, $jointwest);

my $ratio;
foreach my $difference ( @differences)
{
	@diff = @{$difference};
	if ($diff[1] != 0)
	{ $ratio = ( $diff[0] / $diff[1] ); }
	push (@ratios, $ratio);

	$minratio = min(@ratios);
	if ( $minratio > 2 ){ $nodesdata[$counternode][2] = "c"; } 
	elsif ( ( $minratio  >= 1 ) and ($minratio  <= 2 ) )  { $nodesdata[$counternode][2] = "g"; } 
	elsif ( $minratio  < 1 )  { $nodesdata[$counternode][2] = "k"; } 
	$write = $minratio;
	$counternode++;
}							

# END BLOCK HERE




1;






