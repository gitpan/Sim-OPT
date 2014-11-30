								# THIS MODULE USES THE PERCENTAGE OF WINDOWS CALCULATED IN THE MAIN BLOCK OF CODE: $value_reshape_window

														
								$x_wall_base =  (  $v[0][3][0] - $v[0][4][0] )  ; # YOU CAN MAKE THIS MORE GENERAL
								$y_wall_base = (  $v[0][3][1] - $v[0][4][1] )  ; # YOU CAN MAKE THIS MORE GENERAL
								$z_wall_height =  ( $v[0][8][2] - $v[0][4][2]) ; # YOU CAN MAKE THIS MORE GENERAL
								$x_base_centre = (( abs( $v[0][3][0] - $v[0][4][0])  / 2 ) +  min( $v[0][3][0], $v[0][4][0] ) ); # YOU CAN MAKE THIS MORE GENERAL
								$y_base_centre = ( ( abs(  $v[0][3][1] - $v[0][4][1] ) / 2 ) + min( $v[0][3][1], $v[0][4][1] ) ); # YOU CAN MAKE THIS MORE GENERAL
								$height_centre = ( ( abs( $v[0][8][2] - $v[0][4][2]) / 2 ) +  $v[0][4][2] ); # YOU CAN MAKE THIS MORE GENERAL

								$wall_base = sqrt( ($x_wall_base ** 2) + ($y_wall_base ** 2 ));
								$wall_area = $z_wall_height * $wall_base;
								$window_area = $wall_area * $value_reshape_window;
								$height_width_ratio = ($z_wall_height / $wall_base);
								$window_height = sqrt (abs ( ($window_area) * $height_width_ratio ) );
								$window_base = ( $window_height /  $height_width_ratio) ;
								
								
								#if 
								#($y_wall_base == 0) {  $y_window_base_component = 0; $x_window_base_component = $window_base ; }
								#elsif ($x_wall_base == 0) { $x_window_base_component = 0; $y_window_base_component = $window_base ; }
								
								#else
								#{  
									$proportion_base_x_base = ($x_wall_base / $wall_base );
									$x_window_base_component = ($window_base * $proportion_base_x_base);
									$y_window_base_component = sqrt ( ( $window_base ** 2) - ( $x_window_base_component ** 2 ));
								#}
			
								$window_x_1 = $x_base_centre + ( $x_window_base_component / 2 ); 			$window_x_1 = sprintf("%.5f", $window_x_1);
								$window_x_2 = $x_base_centre - ( $x_window_base_component / 2 );			$window_x_2 = sprintf("%.5f", $window_x_2);
								$window_y_1 = $y_base_centre + ( $y_window_base_component / 2 ); 			$window_y_1 = sprintf("%.5f", $window_y_1);
								$window_y_2 = $y_base_centre - ( $y_window_base_component / 2 );			$window_y_2 = sprintf("%.5f", $window_y_2);								
								$window_z_1 = $height_centre - ( $window_height / 2 ); 					$window_z_1 = sprintf("%.5f", $window_z_1);
								$window_z_2 = $height_centre + ( $window_height / 2 );					$window_z_2 = sprintf("%.5f", $window_z_2);				
								$v[0][19][0] = $window_x_1; 
								$v[0][22][0] = $window_x_1;
								$v[0][21][0] = $window_x_2;
								$v[0][20][0] = $window_x_2;
								$v[0][19][1] = $window_y_1; 
								$v[0][22][1] = $window_y_1;
								$v[0][21][1] = $window_y_2;
								$v[0][20][1] = $window_y_2;
								$v[0][19][2] = $window_z_1;
								$v[0][22][2] = $window_z_2;
								$v[0][21][2] = $window_z_2;
								$v[0][20][2] = $window_z_1;
								
								print OUTFILEFEEDBACK "\n\n 8Aback. \$x_wall_base $x_wall_base,  \$y_wall_base  $y_wall_base , \$z_wall_height $z_wall_height ,  \$x_base_centre $x_base_centre,  \$y_base_centre $y_base_centre, \$proportion_base_x_base $proportion_base_x_base, \$height_centre $height_centre, \$wall_base $wall_base, \$wall_area $wall_area, \$window_area $window_area, \$value_reshape_window $value_reshape_window, \$height_width_ratio $height_width_ratio, \$window_height $window_height, \$window_base $window_base, \$y_window_base_component $y_window_base_component, \$x_window_base_component $x_window_base_component, \$window_x_1 $window_x_1, \$window_x_2 $window_x_2, \$window_y_1 $window_y_1, \$window_y_2 $window_y_2, \$window_z_1 $window_z_1, \$window_z_2 $window_z_2
								  \@sourcefiles: @sourcefiles, \@targetfiles: @targetfiles, \@configfiles: @configfiles,
							\@basevalues: @basevalues, \@swingvalues, @swingvalues,
							\$basevalue: $basevalue, \$targetfile: $targetfile, \$configfile: $configfile, 
							\$swingvalue: $swingvalue, \$sourceaddress: $sourceaddress, \$targetaddress: $targetaddress, \$configaddress: $configaddress, \$counteroperations: $counteroperations, 
								\$countervertex: $countervertex, \$countervert: $countervert, \$counterlines: $counterlines, \$line: $line, 
								\$rowelements[0]: $rowelements[0], \$rowelements[1]: $rowelements[1], \$rowelements[2]: $rowelements[2], \$rowelements[3]: $rowelements[3], 
								\$rowelements[0]: $rowelements[0], \$rowelements[1]: $rowelements[1], \$rowelements[2]: $rowelements[2], \$rowelements[3]: $rowelements[3],  
								\$v[0][1][0]: $v[0][1][0], \$v[0][1][1]: $v[0][1][1], \$v[0][1][2]: $v[0][1][2], 
								\n\n";
								print OUTFILEFEEDBACK "Dumper \@v: "; print OUTFILEFEEDBACK Dumper(@v);
								print OUTFILEFEEDBACK "\n\n \$v[0][0][0]: $v[0][0][0], \$v[0][0][1]: $v[0][0][1], \$v[0][0][2]: $v[0][0][2],
								\$v[0][1][0]: $v[0][1][0], \$v[0][1][1]: $v[0][1][1], \$v[0][1][2]: $v[0][1][2],
								\$v[0][2][0]: $v[0][2][0], \$v[0][2][1]: $v[0][2][1], \$v[0][2][2]: $v[0][2][2],
								\$v[0][3][0]: $v[0][3][0], \$v[0][3][1]: $v[0][3][1], \$v[0][3][2]: $v[0][3][2],
								\$v[0][4][0]: $v[0][4][0], \$v[0][4][1]: $v[0][4][1], \$v[0][4][2]: $v[0][4][2],
								\$v[0][5][0]: $v[0][5][0], \$v[0][5][1]: $v[0][5][1], \$v[0][5][2]: $v[0][5][2],
								\$v[0][6][0]: $v[0][6][0], \$v[0][6][1]: $v[0][6][1], \$v[0][6][2]: $v[0][6][2],
								\$v[0][7][0]: $v[0][7][0], \$v[0][7][1]: $v[0][7][1], \$v[0][7][2]: $v[0][7][2],
								\$v[0][8][0]: $v[0][8][0], \$v[0][8][1]: $v[0][8][1], \$v[0][8][2]: $v[0][8][2],
								\$v[0][9][0]: $v[0][9][0], \$v[0][9][1]: $v[0][9][1], \$v[0][9][2]: $v[0][9][2],
								\$v[0][10][0]: $v[0][10][0], \$v[0][10][1]: $v[0][10][1], \$v[0][10][2]: $v[0][10][2],
								\$v[0][11][0]: $v[0][11][0], \$v[0][11][1]: $v[0][11][1], \$v[0][11][2]: $v[0][11][2],
								\$v[0][12][0]: $v[0][12][0], \$v[0][12][1]: $v[0][12][1], \$v[0][12][2]: $v[0][12][2],
								\$v[0][13][0]: $v[0][13][0], \$v[0][13][1]: $v[0][13][1], \$v[0][13][2]: $v[0][13][2],
								\$v[0][14][0]: $v[0][14][0], \$v[0][14][1]: $v[0][14][1], \$v[0][14][2]: $v[0][14][2],
								\$v[0][15][0]: $v[0][15][0], \$v[0][15][1]: $v[0][15][1], \$v[0][15][2]: $v[0][15][2],
								\$v[0][16][0]: $v[0][16][0], \$v[0][16][1]: $v[0][16][1], \$v[0][16][2]: $v[0][16][2],
								\$v[0][17][0]: $v[0][17][0], \$v[0][17][1]: $v[0][17][1], \$v[0][17][2]: $v[0][17][2],
								\$v[0][18][0]: $v[0][18][0], \$v[0][18][1]: $v[0][18][1], \$v[0][18][2]: $v[0][18][2],
								\$v[0][19][0]: $v[0][19][0], \$v[0][19][1]: $v[0][19][1], \$v[0][19][2]: $v[0][19][2],
								\$v[0][20][0]: $v[0][20][0], \$v[0][20][1]: $v[0][20][1], \$v[0][20][2]: $v[0][20][2],
								\$v[0][21][0]: $v[0][21][0], \$v[0][21][1]: $v[0][21][1], \$v[0][21][2]: $v[0][21][2],
								\$v[0][22][0]: $v[0][22][0], \$v[0][22][1]: $v[0][22][1], \$v[0][22][2]: $v[0][22][2],
								\$v[0][23][0]: $v[0][23][0], \$v[0][23][1]: $v[0][23][1], \$v[0][23][2]: $v[0][23][2],
								\$v[0][24][0]: $v[0][24][0], \$v[0][24][1]: $v[0][24][1], \$v[0][24][2]: $v[0][24][2],
								\$v[0][25][0]: $v[0][25][0], \$v[0][25][1]: $v[0][25][1], \$v[0][25][2]: $v[0][25][2],
								\$v[0][26][0]: $v[0][26][0], \$v[0][26][1]: $v[0][26][1], \$v[0][26][2]: $v[0][26][2],"
								;
								

								
								# END BLOCK
								
								
								
								
								1;

