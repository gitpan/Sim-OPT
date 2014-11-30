# THIS MODULE USES THE PERCENTAGE OF WINDOWS CALCULATED IN THE MAIN BLOCK OF CODE: $value_reshape_window


					
$x_wall_base_right =  (  $v[0][4][0] - $v[0][1][0] )  ; # YOU CAN MAKE THIS MORE GENERAL
$y_wall_base_right = (  $v[0][4][1] - $v[0][1][1] )  ; # YOU CAN MAKE THIS MORE GENERAL
$z_wall_height_right =  ( $v[0][8][2] - $v[0][4][2]) ; # YOU CAN MAKE THIS MORE GENERAL
$x_wall_base_left =  (  $v[0][3][0] - $v[0][2][0] )  ; # YOU CAN MAKE THIS MORE GENERAL
$y_wall_base_left = (  $v[0][3][1] - $v[0][2][1] )  ; # YOU CAN MAKE THIS MORE GENERAL
$z_wall_height_left =  ( $v[0][6][2] - $v[0][2][2]) ; # YOU CAN MAKE THIS MORE GENERAL

$x_base_centre_right = (( abs( $v[0][4][0] - $v[0][1][0])  / 2 ) +  min( $v[0][4][0], $v[0][1][0] ) ); # YOU CAN MAKE THIS MORE GENERAL
$y_base_centre_right = ( ( abs(  $v[0][4][1] - $v[0][1][1] ) / 2 ) + min( $v[0][4][1], $v[0][1][1] ) ); # YOU CAN MAKE THIS MORE GENERAL
$height_centre_right = ( ( abs( $v[0][8][2] - $v[0][4][2]) / 2 ) +  $v[0][4][2] ); # YOU CAN MAKE THIS MORE GENERAL
$x_base_centre_left = (( abs( $v[0][2][0] - $v[0][3][0])  / 2 ) +  min( $v[0][2][0], $v[0][3][0] ) ); # YOU CAN MAKE THIS MORE GENERAL
$y_base_centre_left = ( ( abs(  $v[0][2][1] - $v[0][3][1] ) / 2 ) + min( $v[0][2][1], $v[0][3][1] ) ); # YOU CAN MAKE THIS MORE GENERAL
$height_centre_left = ( ( abs( $v[0][6][2] - $v[0][2][2]) / 2 ) +  $v[0][2][2] ); # YOU CAN MAKE THIS MORE GENERAL

$wall_base_right = sqrt( ($x_wall_base_right ** 2) + ($y_wall_base_right ** 2 ));
$wall_area_right = $z_wall_height_right * $wall_base_right;
$window_area_right = $wall_area_right * $value_reshape_window_right;
$height_width_ratio_right = ($z_wall_height_right / $wall_base_right);
$window_height_right = sqrt (abs ( ($window_area_right) * $height_width_ratio_right ) );
$window_base_right = ( $window_height_right /  $height_width_ratio_right) ;
$wall_base_left = sqrt( ($x_wall_base_left ** 2) + ($y_wall_base_left ** 2 ));
$wall_area_left = $z_wall_height_left * $wall_base_left;
$window_area_left = $wall_area_left * $value_reshape_window_left;
$height_width_ratio_left = ($z_wall_height_left / $wall_base_left);
$window_height_left = sqrt (abs ( ($window_area_left) * $height_width_ratio_left ) );
$window_base_left = ( $window_height_left /  $height_width_ratio_left) ;




	$proportion_base_x_base_right = ($x_wall_base_right / $wall_base_right );
	$x_window_base_component_right = ($window_base_right * $proportion_base_x_base_right);
	$y_window_base_component_right = sqrt ( ( $window_base_right ** 2) - ( $x_window_base_component_right ** 2 ));
	$proportion_base_x_base_left = ($x_wall_base_left / $wall_base_left );
	$x_window_base_component_left = ($window_base_left * $proportion_base_x_base_left);
	$y_window_base_component_left = sqrt ( ( $window_base_left ** 2) - ( $x_window_base_component_left ** 2 ));


			
$window_x_1_right = $x_base_centre_right + ( $x_window_base_component_right / 2 ); 			$window_x_1_right = sprintf("%.5f", $window_x_1_right);
$window_x_2_right = $x_base_centre_right - ( $x_window_base_component_right / 2 );			$window_x_2_right = sprintf("%.5f", $window_x_2_right);
$window_y_1_right = $y_base_centre_right + ( $y_window_base_component_right / 2 ); 			$window_y_1_right = sprintf("%.5f", $window_y_1_right);
$window_y_2_right = $y_base_centre_right - ( $y_window_base_component_right / 2 );			$window_y_2_right = sprintf("%.5f", $window_y_2_right);								
$window_z_1_right = $height_centre_right - ( $window_height_right / 2 ); 				$window_z_1_right = sprintf("%.5f", $window_z_1_right);
$window_z_2_right = $height_centre_right + ( $window_height_right / 2 );				$window_z_2_right = sprintf("%.5f", $window_z_2_right);				
$v[0][23][0] = $window_x_1_right; 
$v[0][24][0] = $window_x_2_right;
$v[0][25][0] = $window_x_2_right;
$v[0][26][0] = $window_x_1_right;
$v[0][23][1] = $window_y_1_right; 
$v[0][24][1] = $window_y_2_right;
$v[0][25][1] = $window_y_2_right;
$v[0][26][1] = $window_y_1_right;
$v[0][23][2] = $window_z_1_right;
$v[0][24][2] = $window_z_1_right;
$v[0][25][2] = $window_z_2_right;
$v[0][26][2] = $window_z_2_right;
$window_x_1_left = $x_base_centre_left + ( $x_window_base_component_left / 2 ); 			$window_x_1_left = sprintf("%.5f", $window_x_1_left);
$window_x_2_left = $x_base_centre_left - ( $x_window_base_component_left / 2 );				$window_x_2_left = sprintf("%.5f", $window_x_2_left);
$window_y_1_left = $y_base_centre_left + ( $y_window_base_component_left / 2 ); 			$window_y_1_left = sprintf("%.5f", $window_y_1_left);
$window_y_2_left = $y_base_centre_left - ( $y_window_base_component_left / 2 );				$window_y_2_left = sprintf("%.5f", $window_y_2_left);								
$window_z_1_left = $height_centre_left - ( $window_height_left / 2 ); 					$window_z_1_left = sprintf("%.5f", $window_z_1_left);
$window_z_2_left = $height_centre_left + ( $window_height_left / 2 );					$window_z_2_left = sprintf("%.5f", $window_z_2_left);				
$v[0][15][0] = $window_x_2_left; 
$v[0][16][0] = $window_x_1_left;
$v[0][17][0] = $window_x_1_left;
$v[0][18][0] = $window_x_2_left;
$v[0][15][1] = $window_y_2_left; 
$v[0][16][1] = $window_y_1_left;
$v[0][17][1] = $window_y_1_left;
$v[0][18][1] = $window_y_2_left;
$v[0][15][2] = $window_z_1_left;
$v[0][16][2] = $window_z_1_left;
$v[0][17][2] = $window_z_2_left;
$v[0][18][2] = $window_z_2_left;



# END BLOCK



1;

