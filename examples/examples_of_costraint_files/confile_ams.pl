# BEGIN CONFIGFILE

$edge_x = sqrt ( ( abs($v[0][2][0] - $v[0][1][0]) **2 ) + ( abs($v[0][2][1] - $v[0][1][1]) **2 ) );
$edge_y = sqrt ( ( abs($v[0][4][0] - $v[0][1][0]) **2 ) + ( abs($v[0][4][1] - $v[0][1][1]) **2 ) ); 
$this_area = ( $edge_x * $edge_y);
$new_height = ( $basevalue / $this_area);  $new_height = sprintf("%.3f", $new_height );


$v[0][5][2] = $new_height;
$v[0][6][2] = $new_height;
$v[0][7][2] = $new_height;
$v[0][8][2] = $new_height;


# END CONFIGFILE

1;
