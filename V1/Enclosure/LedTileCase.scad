$fn = 180;

// See also...
// https://www.youtube.com/watch?v=_vxVo6bJa1k

showBase = false;
showCover = true;
showModels = false;

pcbWidth = 100;
pcbHeight = 100;

pcbPaddingXAxis = 10;
pcbPaddingYAxis = 10;

// Thickness of the wall.
wallThickness = 1.5;

curveRadius = 3; 

// How think the bottom wall of the base is.
baseInnerThickness = 1.5;

// Overall size
// Y Size
height = pcbHeight + (2*pcbPaddingYAxis)-0.5;
echo("Height (Y)" , height);

// X axis size.
width = pcbWidth + (2*pcbPaddingXAxis) -0.5;
echo("Width (X)" , width);

// How deep the base box is.
// This excludes the very bottom wall.
baseDepth = 10;
echo("Base Depth (X)" , baseDepth);

overallThickness = 24;
// LIFX Tile is 1" (24mm thick)


// Support positions on the PCBs, relatec to the PCB corner.
// does not include bezel/wall thinckness offsets
pcbSupportPositions = []; // [[4,36,0],[96,4,0]];
// LED PCB
//pcbSupportPadPositions = [[80,20,0],[20,80,0],[20,20,0],[80,80,0]];
pcbSupportPadPositions = [[80,20,0],[20,80,0]];
pcbSupportPinPositions = [[20,20,0],[80,80,0]];

// Proto PCB
//pcbSupportPadPositions = [[5,5,0],[95,5,0],[95,95,0],[5,95,0]];
//pcbSupportPinPositions = [];

//pcbSupportPinPositions = [];
pcbSupportHeight = 10;
pcbThickness = 1.2;

// If to include the top/... cutouts for interlocking slots and cable entry/exit

includeLeftCutouts = true;
includeTopCutouts = false;
includeBottomCutouts = false;
includeRightCutouts = true;
includePowerEntry = true;

module showModels() {
    translate([10,10,pcbSupportHeight-baseInnerThickness]) {
        showPcbModel();
    }
}

module pcbModelHole(x,y) {
    translate([x, y, -0.1]) {
        cylinder(d=3, h=4);
    }
}

module showPcbModel() {
    difference() {
        union() {
            // PCB
            cube([100,100,pcbThickness]);
            
            
            // Vertical left connector
            translate([0,74,pcbThickness]) {
                cube([6,16,10]);
            }
            
            // Vertical right connector
            translate([100-6,74,pcbThickness]) {
                cube([6,16,10]);
            }
            
            // DC In.
            translate([51-6,100-8,pcbThickness]) {
                cube([12,8,10]);
            }
            
            beamHeight = overallThickness - (pcbSupportHeight + pcbThickness);
            
            // LEDs
            translate([5,5,pcbThickness]) {
                for (y=[0:30:90]) {
                    for (x=[0:30:90]) {
                        translate([x,y,0]) {
                            cylinder(d1=3,d2=30,h=beamHeight);
                            cylinder(d=3,h=beamHeight);
                        }
                    }
                }
                
            }
        }
        union() {
            pcbModelHole(20,20);
            pcbModelHole(20,80);
            pcbModelHole(80,80);
            pcbModelHole(80,20);
        }
    }
}

// -----------------------------------------
// -----------------------------------------
module GenericBase(xDistance, yDistance, zHeight, zAdjust) {
	    
    // NB: base drops below 0 line by the curve radius so we need to compensate for that
	translate([curveRadius,curveRadius, zAdjust]) {
		minkowski()
		{
			// 3D Minkowski sum all dimensions will be the sum of the two object's dimensions
			cube([xDistance-(curveRadius*2), yDistance-(curveRadius*2), (zHeight /2)]);
			cylinder(r=curveRadius,h= (zHeight/2) + curveRadius);
		}
	}
}



module RoundedTop(xDistance, yDistance, zHeight) {
    
    union() {       
        // Lower part with all rounded edges.
        translate([curveRadius,curveRadius,zHeight-curveRadius]) {
            difference() {
                union() {
                    minkowski()
                    {
                        // 3D Minkowski sum all dimensions will be the sum of the two object's dimensions
                        cube([xDistance-(curveRadius*2), yDistance-(curveRadius*2), curveRadius]);
                        // This does every edge of the cube.
                        sphere(r=curveRadius);
                    }
                }
                
                union() {
                    // Cut off above the bottom (or top) 2/3s of the rounded cube to leave only the 
                    // curved part and very edge.
                    // This really only matters where the height < (3 x curveRadius)
                    translate([-curveRadius,-curveRadius, - (curveRadius)]) {
                        cube([xDistance + 0.01, yDistance +0.01, curveRadius*2]);
                    }
                } 
            }
        }  
        
//wallHeight+baseInnerThickness +  == very top.
    echo("cover zHeight",zHeight);    
wallHeight = (coverDepth - curveRadius);
    echo("cover wallHeight",wallHeight);   
        
        
        
        // coverDepth

        // Upper part with rounded coners and flat top/bottom.
        translate([curveRadius,curveRadius, curveRadius]) {
           // #cube([xDistance-(curveRadius*2), yDistance-(curveRadius*2), wallHeight + curveRadius]);
            minkowski()
            {
                // 3D Minkowski sum all dimensions will be the sum of the two object's dimensions
                cube([xDistance-(curveRadius*2), yDistance-(curveRadius*2), wallHeight/2]);
                cylinder(r=curveRadius,h= wallHeight/2);
            }
        }
    }
}


// -----------------------------------------
// Main body for base case.
// -----------------------------------------
module OuterWall() {

innerCutoutOffset = wallThickness;
    
echo("baseDepth",baseDepth);
    
	difference() {
		union() {
                
            // Compensate for the rounding missing
            translate([0,0,-curveRadius]) {
                GenericBase(width, height, baseDepth-curveRadius);
            }
		}
		union() {
			// Cut out the bulk of the inside of the box.
			// Outerwall padding = 5
			// Move in 5, down 5 and up 2 to provide an 
			// outline of 5x5 with 2 base.
            // Make it much bigger in Z axis to ensure clearing
			translate([innerCutoutOffset, innerCutoutOffset, baseInnerThickness]) {
				GenericBase(width - (innerCutoutOffset * 2), 
									height - (innerCutoutOffset *2), 
									(baseDepth - baseInnerThickness) +10,
                                    -curveRadius);
			}
		}
	}
}


module pcbSupport(position, height) {
        
    // Offset the position for it's PCB position
    translate(position) {
        difference() {
            union() {            
                cylinder(d=6, h=height, $fn=50);
            }
            union() {
                translate(0,0,baseInnerThickness) {
                    cylinder(d=screwHoldSize, h=height, $fn=50);
                }
            }
        }
    }
}

module pcbSupportPad(position, height) {
    color("green") {
        // Lift off the Z axis floor a little to stop the 
        // edges sticking out where the mount is on a curved conrer.
        translate(position) {
            difference() {
                union() {
                    cylinder(d=8, h=height);
                }
                union() {
                    translate([0,0,2.1]) {
                        cylinder(d=4.2, h=height-2);    
                    }
                }
            }
        }
    }
}

// Hole for screw to go through from the base to the top.
module pcbSupportScrewHole(position, height) {
       
    // Offset the position for it's PCB position
    /*
    translate(position) {
        cylinder(d=6, h=height);
        cylinder(d=2.9, h=height + (pcbThickness*2));    
    }
    */
    
    color("blue") {
        // Lift off the Z axis floor a little to stop the 
        // edges sticking out where the mount is on a curved conrer.
        translate(position) {
            difference() {
                
                cylinder(d=8, h= (height));
                cylinder(d=3.6, h= (height) + (pcbThickness*2) + baseInnerThickness);    
            }
        }
    }
}

module pcbSupportPin(position, height) {
       
    // Offset the position for it's PCB position
    translate(position) {
        cylinder(d=6, h=height);
        translate([0,0,height-0.1]) {
            // Should be a 3.2mm home
            cylinder(d1=3.0, d2=2.6, h=(pcbThickness*3));    
        }
    }
}

module countersink(position) {
       
    // Offset the position for it's PCB position
    translate(position) {
        translate([0,0,- (baseInnerThickness )]) {
            // the actual countersink
            cylinder(d1=7, d2=3.6, h=baseInnerThickness+0.1);    
            // Make a hole through the base wall.
            cylinder(d=3.6, h=baseInnerThickness+0.1);    
        }
    }
}

module addCountersinks() {
    zOffset = -2.5; // -2 to get them on the very floor
    echo("baseInnerThickness",baseInnerThickness);
    
    // Offset the position for the case parameters.
    translate([wallThickness + pcbPaddingXAxis, wallThickness + pcbPaddingYAxis, zOffset]) {
                
        // Add PCB supports with pins to help alignment (and save on screws).
        for(pcbSupportPinPosition = pcbSupportPositions) {
            countersink(pcbSupportPinPosition, pcbSupportHeight+ 2.5);
        }
    }
}
module addPcbSupports() {
    
    // Offset to be ON the top of the base floor
    // otherwise Cura doesn't provide a strong support
    zOffset = -curveRadius + baseInnerThickness;
    echo("baseInnerThickness",baseInnerThickness);
    
    // Offset the position for the case parameters.
    translate([pcbPaddingXAxis, pcbPaddingYAxis, zOffset]) {
        
        // Add PCB supports with holes for screws through the base.
        for(pcbSupportPosition = pcbSupportPositions) {
            pcbSupportScrewHole(pcbSupportPosition, pcbSupportHeight);
        }
        
        // Add PCB supports with pins to help alignment (and save on screws).
        for(pcbSupportPinPosition = pcbSupportPinPositions) {
            pcbSupportPin(pcbSupportPinPosition, pcbSupportHeight);
        }
        
        // Add PCB supports with holes for screws through the base.
        for(pcbSupportPadPosition = pcbSupportPadPositions) {
            pcbSupportPad(pcbSupportPadPosition, pcbSupportHeight);
        }
    }
}

module interlockingCutouts() {
lockingThickness = 6;
    
    // -2 for base offset (curveRadius)
    translate([0,0,- (curveRadius+0.01)]) {
                
        // Left
        if (includeLeftCutouts) {
            translate([-1,(height-10)/2,0]) {
                cube([15+1, 10, lockingThickness]);
            }
            translate([15,height/2,0]) {
                cylinder(d=10, h=lockingThickness);
            }
        }
        
        // Right
        if (includeRightCutouts) {
            translate([width-15,(height-10)/2,0]) {
                cube([15+1, 10, lockingThickness]);
            }
            translate([width-15,height/2,0]) {
                cylinder(d=10, h=lockingThickness);
            }
        }
        
        // Top
        if (includeTopCutouts) {
            translate([(width-10)/2,height-15,0]) {
                cube([10, 15+1, lockingThickness]);
            }
            translate([width/2,height-15,0]) {
                cylinder(d=10, h=lockingThickness);
            }
        }
                    
        // Bottom
        if (includeBottomCutouts) {
            translate([(width-10)/2,-1,0]) {
                cube([10, 15+1, lockingThickness]);
            }
            translate([width/2,15,0]) {
                cylinder(d=10, h=lockingThickness);
            }
        }
    }
}

module extraCutouts() {
    
// At PCB 80.5)
sidePassthroughCableY = 90.5;
    
    translate([0,0,-(curveRadius+0.01)]) {
        
        // Top/Bottom cable cutouts for power cables.
        if (includeBottomCutouts) {
            translate([(width/2)-5,-2, 0]) {
                #cube([10,4,baseDepth+2]);
            }
        }
        
        // rear power entry
        if (includePowerEntry) {
            translate([width/2,height-7,0]) {
                cylinder(d=10, h=baseDepth+2);
            }
        }
        
        // bottom cable
        if (includeTopCutouts) {
            translate([(width/2)-5,height-3, 0]) {
                cube([10,4,baseDepth+2]);
            }
        }
        
        // Left/Right cable passthrough
        if (includeLeftCutouts) {
            translate([-1,sidePassthroughCableY-10, -1]) {
                cube([8+1,20,10]);
            }
        }
        
        if (includeRightCutouts) {
            translate([width-8,sidePassthroughCableY-10, -1]) {
                #cube([10,20,10]);
            }
        }
    }
}

// -----------------------------------------
// Base
// -----------------------------------------
module Base() {
    	
	difference() {
		union() 
		{
			// Outer base wall
			OuterWall();
            addPcbSupports();
		}		
		union() 
		{
            addCountersinks();
            
            translate([0,0,-(curveRadius+0.1)]) {
                translate([7,113,0]) {
                   cylinder(d=4, h=4);
                }
                
                translate([113,7,0]) {
                    cylinder(d=4, h=4);
                }
                
                translate([7,7,0]) {
                    cylinder(d=4, h=4);
                }
                
                translate([113,113,0]) {
                    cylinder(d=4, h=4);
                }
            }
            
            // Implement in case specific file...
            extraCutouts();
            
            interlockingCutouts();
		}
	}
}

// -----------------------------------------
// Cover
// -----------------------------------------


coverDepth = 6;
coverThickness= 1.5;
jointDepth = 4;

module CoverMainBody() {

innerCutoutOffset = wallThickness;
    
echo("coverDepth",coverDepth);
echo("coverThickness", coverThickness);
    
	difference() {
		union() {
                
            // Compensate for the rounding missing
            translate([0,0,-curveRadius]) {
                GenericBase(width, height, coverDepth-curveRadius);
            }
		}
		union() {
			// Cut out the bulk of the inside of the box.
			// Outerwall padding = 5
			// Move in 5, down 5 and up 2 to provide an 
			// outline of 5x5 with 2 base.
            // Make it much bigger in Z axis to ensure clearing
			translate([innerCutoutOffset, innerCutoutOffset, -0.1]) {
				GenericBase(width - (innerCutoutOffset * 2), 
									height - (innerCutoutOffset *2), 
									(coverDepth-curveRadius - coverThickness),
                                    -curveRadius);
			}
		}
	}
}


module coverToBaseJoint() {
    
innerCutoutOffset = 1.5;
jointOverlap = 2;
coverThickness = 1.5;
jointTollerance = 0.2;
    
echo("coverDepth",coverDepth);
echo("coverThickness", coverThickness);
    
jointWidth = width-((wallThickness+jointTollerance)*2);
jointHeight = height-((wallThickness+jointTollerance)*2);
    
    translate([wallThickness+0.1, wallThickness+0.1, 0]) {
    
        difference() {
            union() {
                    
                // Compensate for the rounding missing
                translate([0,0,-curveRadius]) {
                    GenericBase(jointWidth, jointHeight, jointDepth+jointOverlap);
                }
            }
            union() {
                // Cut out the bulk of the inside of the box.
                // Outerwall padding = 5
                // Move in 5, down 5 and up 2 to provide an 
                // outline of 5x5 with 2 base.
                // Make it much bigger in Z axis to ensure clearing
                translate([innerCutoutOffset, innerCutoutOffset, -0.1]) {
                	GenericBase(jointWidth - (innerCutoutOffset * 2), 
                                        jointHeight - (innerCutoutOffset *2), 
                                        (jointDepth+jointOverlap + 2),
                                        -curveRadius);
                }
            }
        }
    }
}

module Cover() {
    

    
echo("coverDepth",coverDepth);
echo("coverThickness", coverThickness);
    
//paddedWallThickness = wallThickness+0.1;
//jointThickness = 1.5;
    
jointWidth = width-20;
jointHeight = height - 20; 
    
    
	   
	difference() {
		union() 
		{
            // Upper body
			CoverMainBody();
            
            translate([0,0,-jointDepth]) {
                coverToBaseJoint();
            }
		}		
		union() 
		{
            echo("Todo: Cutouts for ???");
		}
	}

}
// -----------------------------------------
//
// -----------------------------------------

module buildCase() {

    if (showBase) {
        Base();
    }

    if (showCover) {
        // Offset the cover
        //translate([0,0,100]) {
        translate([0,0,baseDepth+4]) {
            Cover();
        }
    }
}




buildCase();
if (showModels) {
    %showModels();
}