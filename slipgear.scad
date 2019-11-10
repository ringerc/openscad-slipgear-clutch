
/*
 * Generate each tooth individually.
 *
 * The original verison generated a single polyhedron of all the teeth,
 * but the zero thickness edges confused CGAL and crashed it. Rather than
 * add a thin solid base, just make it distinct shapes.
 */
module gear_face(gear_radius, gear_face_angle, gear_nteeth)
{
    assert(gear_nteeth >= 4, "minimum 4 teeth");

    assert(gear_face_angle > 0 && gear_face_angle < 85,
           "gear_face_angle limited to range (0,85) degrees");

    intersection()
    {
        let(step = 360 / gear_nteeth)
        scale(gear_radius*1.1)
        for (a = [0 : step : 360.00001])
        {
            points =  [
                // center-of-teeth
                [0,0,0],
                // Outer bottom left
                [sin(a), cos(a), 0 ],
                // Outer top
                [
                    (sin(a)+sin(a+step))/2,
                    (cos(a)+cos(a+step))/2,
                    tan(gear_face_angle)*(sin(step)/2)
                ],
                // Outer bottom right
                [sin(a+step), cos(a+step), 0 ],
            ];
            faces = [
                [0, 1, 2],  // top left
                [0, 2, 3],  // top right
                [1, 3, 2],  // outer wall
                [0, 3, 1]   // bottom
            ];
            polyhedron(points=points, faces=faces);
        };
        
        cylinder(r1=gear_radius,
                 r2=gear_radius,
                 h=gear_radius*tan(gear_face_angle)/2);
    };
}


gear_nteeth = 16;
gear_radius = 20;
gear_face_angle = 45;

gear1_hole_radius = 1.95;
gear1_base_thickness = 8;

gear2_hole_radius = 2.20;
gear2_base_thickness = 4;
gear2_driver_length = 8;
gear2_driver_teeth = 15;
// TODO compute the pitch
gear2_driver_pitch = 562;

$fn=60;

// gear1
translate([-gear_radius*1.5,0,0])
difference()
{
    union()
    {
        translate([0,0,gear1_base_thickness-0.0001])
        gear_face(gear_radius, gear_face_angle, gear_nteeth);
        
        cylinder(r1=gear_radius, r2=gear_radius, h=gear1_base_thickness);
    };
    
    cylinder(r1=gear1_hole_radius,
             r2=gear1_hole_radius,
             h=gear1_base_thickness + gear_radius*tan(gear_face_angle)/2);
}

//gear2

use <MCAD/involute_gears.scad>;

translate([gear_radius*1.5, 0, gear2_driver_length])
difference()
{
    union()
    {
        translate([0,0,gear2_base_thickness-0.0001])
        gear_face(gear_radius, gear_face_angle, gear_nteeth);
        
        cylinder(r1=gear_radius, r2=gear_radius, h=gear2_base_thickness);

        translate([0, 0, -gear2_driver_length+0.0001])
        gear(
            number_of_teeth=gear2_driver_teeth,
            circular_pitch=gear2_driver_pitch,
            gear_thickness=gear2_driver_length,
            rim_thickness=gear2_driver_length,
            hub_thickness=gear2_driver_length,
            circles=0,
            bore_diameter=gear2_hole_radius*2
        );        
        
    };
    
    cylinder(r1=gear2_hole_radius,
             r2=gear2_hole_radius,
             h=gear2_base_thickness + gear_radius*tan(gear_face_angle)/2);
}
