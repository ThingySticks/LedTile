$fn=90;

module semisphere() {
    difference() {
    union() {
        sphere(d=20);
    }
    union() {
        translate([-25,-25,-100]) {
            cube([50,50,100]);
        }
    }
}
}

difference() {
    union() {
        cylinder(d=10, h=3.1);
        translate([0,0,3]) {
            cylinder(d=26, h=2);
            semisphere();
        }
        
  
    }
    union() {
        // Neopixel cutput.
        translate([-3,-3,-0.1]) {
            cube([6,6,2]);
        }
        
        
        /*
        translate([-25,-25,-100]) {
            cube([50,50,100]);
        }
        */
    }
}