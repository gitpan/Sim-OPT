# THIS MODULE USES THE PERCENTAGE OF WINDOWS CALCULATED IN THE MAIN BLOCK OF CODE: $value_reshape_window

														
								$x_wall_base =  (  $v[0][2][0] - $v[0][1][0] )  ; # YOU CAN MAKE THIS MORE GENERAL
								$y_wall_base = (  $v[0][2][1] - $v[0][1][1] )  ; # YOU CAN MAKE THIS MORE GENERAL
								$z_wall_height =  ( $v[0][5][2] - $v[0][1][2]) ; # YOU CAN MAKE THIS MORE GENERAL
								$x_base_centre = (( abs( $v[0][2][0] - $v[0][1][0])  / 2 ) +  min( $v[0][2][0], $v[0][1][0] ) ); # YOU CAN MAKE THIS MORE GENERAL
								$y_base_centre = ( ( abs(  $v[0][2][1] - $v[0][1][1] ) / 2 ) + min( $v[0][2][1], $v[0][1][1] ) ); # YOU CAN MAKE THIS MORE GENERAL
								$height_centre = ( ( abs( $v[0][5][2] - $v[0][1][2]) / 2 ) +  $v[0][1][2] ); # YOU CAN MAKE THIS MORE GENERAL
								
								
								$wall_base = sqrt( ($x_wall_base ** 2) + ($y_wall_base ** 2 ));
								$wall_area = $z_wall_height * $wall_base;
								$window_area = $wall_area * $value_reshape_window;
								$height_width_ratio = ($z_wall_height / $wall_base);
								$window_height = sqrt (abs ( ($window_area) * $height_width_ratio ) );
								$window_base = ( $window_height /  $height_width_ratio) ;
								
								$proportion_base_x_base = ($x_wall_base / $wall_base );
								$x_window_base_component = ($window_base * $proportion_base_x_base);
								$y_window_base_component = sqrt ( ( $window_base ** 2) - ( $x_window_base_component ** 2 ));
												
								$window_x_1 = $x_base_centre - ( $x_window_base_component / 2 ); 			$window_x_1 = sprintf("%.5f", $window_x_1);
								$window_x_2 = $x_base_centre + ( $x_window_base_component / 2 );			$window_x_2 = sprintf("%.5f", $window_x_2);
								$window_y_1 = $y_base_centre - ( $y_window_base_component / 2 ); 			$window_y_1 = sprintf("%.5f", $window_y_1);
								$window_y_2 = $y_base_centre + ( $y_window_base_component / 2 );			$window_y_2 = sprintf("%.5f", $window_y_2);								
								$window_z_1 = $height_centre - ( $window_height / 2 ); 					$window_z_1 = sprintf("%.5f", $window_z_1);
								$window_z_2 = $height_centre + ( $window_height / 2 );					$window_z_2 = sprintf("%.5f", $window_z_2);				
								$v[0][11][0] = $window_x_1; 
								$v[0][14][0] = $window_x_1;
								$v[0][13][0] = $window_x_2;
								$v[0][12][0] = $window_x_2;
								$v[0][11][1] = $window_y_1; 
								$v[0][14][1] = $window_y_1;
								$v[0][13][1] = $window_y_2;
								$v[0][12][1] = $window_y_2;
								$v[0][11][2] = $window_z_1;
								$v[0][14][2] = $window_z_2;
								$v[0][13][2] = $window_z_2;
								$v[0][12][2] = $window_z_1;
								
								
								# END BLOCK
								
											
								
								
								1;

