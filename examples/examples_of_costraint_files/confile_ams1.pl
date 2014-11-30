
$edge_x = sqrt ( ( abs($v[0][2][0] - $v[0][1][0]) **2 ) + ( abs($v[0][2][1] - $v[0][1][1]) **2 ) );
$height = $v[0][5][2] - $v[0][1][2];
$edge_y = $v[0][4][1] - $v[0][1][1];
$present_volume = ($edge_x * $edge_y * $edge_z);

$edge_new_y = ($basevalue * ( 1 / ( $height * $edge_x ) ) ); 
$center_edge_new_y = ( $v[0][1][1] + ( $edge_new_y /2) ); $center_edge_new_y = sprintf("%.5f", $center_edge_new_y );
$difference_centers = ($center_edge_old_y - $center_edge_new_y) ; $difference_centers = sprintf("%.5f", $difference_centers );
$new_y = ( $v[0][1][1] + $edge_new_y ); $new_y = sprintf("%.5f", $new_y );

$v[0][3][1] = $new_y;
$v[0][4][1] = $new_y;
$v[0][7][1] = $new_y;
$v[0][8][1] = $new_y;
$v[0][19][1] = $new_y;
$v[0][20][1] = $new_y;
$v[0][21][1] = $new_y;
$v[0][22][1] = $new_y;
$v[0][9][1] = $center_edge_new_y;
$v[0][10][1] = $center_edge_new_y;
$v[0][15][1] = $v[0][15][1] - $difference_centers;
$v[0][16][1] = $v[0][16][1] - $difference_centers;
$v[0][17][1] = $v[0][17][1] - $difference_centers;
$v[0][18][1] = $v[0][18][1] - $difference_centers;
$v[0][23][1] = $v[0][23][1] - $difference_centers;
$v[0][24][1] = $v[0][24][1] - $difference_centers;
$v[0][25][1] = $v[0][25][1] - $difference_centers;
$v[0][26][1] = $v[0][26][1] - $difference_centers;

1;
