//OpenSCAD design for MKS SBase board. Includes Mounts for 2020 extrusion and parametric cooling fan.

//Configuration
//MKS SBase Dimensions
board_length = 146.5;
board_width = 95;
mount_diameter = 4;
mount_edge_space = 4;
board_height = 15;
board_thickness = 3;

//case configuration
board_extra_space = 2; //amount of space around the board before the walls start
board_extra_z = 10;
case_thickness = 3;
mount_under_clearance = 5; //clearance between the bottom of board and base
mount_pillar_size = 10;
include_vents = 1;
vent_count = 4;
vent_edge_space = 10; //clearance between inside wall and vent position.
thermistor_slot_z = 5;
thermistor_slot_length = 30;
power_slot_z = 15;

//start
//uses
use <BOSL/transforms.scad>;
use <BOSL/shapes.scad>;
$fs = 0.05;

box_outer_x = board_length + 2*board_extra_space + 2*case_thickness;
box_outer_y = board_width + 2*board_extra_space + 2*case_thickness+50;
box_outer_z = case_thickness*2 + mount_under_clearance+board_thickness+board_height+board_extra_z;
vent_width = (board_width-vent_edge_space)/(2*vent_count);
module mount_pillar(height=mount_under_clearance){
    cylinder(r=(mount_diameter+mount_edge_space+board_extra_space)/2,h=height);
}
module vent(width){
  translate([(board_length-vent_edge_space)/2,width/2,-0.5])
  rrect([board_length-vent_edge_space*2,width,case_thickness+1],center=false,r=1);
}
module base_plate (){

  difference(){
    union() {
      translate([box_outer_x/2,box_outer_y/2,0]) rrect([box_outer_x,box_outer_y,case_thickness-1],r=1,center=false);
      translate([(box_outer_x)/2,(box_outer_y)/2,case_thickness-1]) rrect([box_outer_x-case_thickness-1,box_outer_y-case_thickness-1,1],r=1,center=false);
      translate([case_thickness+board_extra_space,case_thickness+board_extra_space,case_thickness]) {
        place_copies([[mount_edge_space,mount_edge_space,0],[mount_edge_space,-mount_edge_space+board_width,0],[-mount_edge_space+board_length,mount_edge_space,0],[-mount_edge_space+board_length,-mount_edge_space+board_width,0]]) mount_pillar();
      }
    }
    /*difference(){
      translate([-0.1,-0.1,0]) cube([box_outer_x+0.2,box_outer_y+0.2,1.1]);
      translate([0.1+case_thickness/2,0.1+case_thickness/2,-0.10]) cube([box_outer_x-case_thickness,box_outer_y-case_thickness,1.3]);
    }*/
    //construct the fan vents
    line_of(p1=[case_thickness+board_extra_space+vent_edge_space/2,case_thickness+board_extra_space+vent_edge_space,0], p2=[case_thickness+board_extra_space+vent_edge_space/2,board_width+case_thickness-vent_edge_space-vent_width,0], n=vent_count) vent(vent_width);
    translate([case_thickness+board_extra_space,case_thickness+board_extra_space,-1]) {
      place_copies([[mount_edge_space,mount_edge_space,0],[mount_edge_space,-mount_edge_space+board_width,0],[-mount_edge_space+board_length,mount_edge_space,0],[-mount_edge_space+board_length,-mount_edge_space+board_width,0]]) cylinder(r=2,h=case_thickness+mount_under_clearance+10,center=false);
    }
    translate([case_thickness+board_extra_space,case_thickness+board_extra_space,-0.1]) {
      place_copies([[mount_edge_space,mount_edge_space,0],[mount_edge_space,-mount_edge_space+board_width,0],[-mount_edge_space+board_length,mount_edge_space,0],[-mount_edge_space+board_length,-mount_edge_space+board_width,0]]) cylinder(r=4,h=case_thickness/2,center=false);
    }
  }

}

module extrusion_mount() {
//creates the 2020 mount to bolt up somewher
cube([20,case_thickness,case_thickness]);
translate([0,0,case_thickness])
difference(){
  cube([20,case_thickness,20]);
  translate([10,-0.1,10])rotate([-90,0,0])cylinder(r=3,h=case_thickness+0.2);
}
translate([0,case_thickness,case_thickness])rotate([-90,0,0]) difference(){
  cube([20,case_thickness,20]);
  translate([10,-0.1,10])rotate([-90,0,0])cylinder(r=3,h=case_thickness+0.2);
}
}
module mount_pair(separation=30) {
  extrusion_mount();
  translate([20,0,0])cube([separation,case_thickness,case_thickness]);
  translate([20+separation,0,0]) extrusion_mount();
}

module top_box() {
  difference(){
    union() {
      difference(){
      translate([box_outer_x/2,box_outer_y/2,0]) rrect([box_outer_x,box_outer_y,box_outer_z],r=1,center=false);
      translate([box_outer_x/2,box_outer_y/2,case_thickness]) rrect([box_outer_x-case_thickness,box_outer_y-case_thickness,box_outer_z-case_thickness+1],r=1,center=false);
      line_of(p1=[case_thickness+board_extra_space+vent_edge_space/2,case_thickness+board_extra_space+vent_edge_space,0], p2=[case_thickness+board_extra_space+vent_edge_space/2,board_width+case_thickness-vent_edge_space-vent_width,0], n=vent_count) vent(vent_width);
      }
      translate([case_thickness+board_extra_space,case_thickness+board_extra_space,case_thickness]) {
        place_copies([[mount_edge_space,mount_edge_space,0],[mount_edge_space,-mount_edge_space+board_width,0],[-mount_edge_space+board_length,mount_edge_space,0],[-mount_edge_space+board_length,-mount_edge_space+board_width,0]]) mount_pillar(board_height+board_extra_z);
      }
    }
    //long cutout for thermistor cables.
    translate([case_thickness+board_extra_space+15,-1,case_thickness])cube([thermistor_slot_length,case_thickness+2,mount_under_clearance+board_thickness+thermistor_slot_z]);
    translate([case_thickness+board_extra_space+15+board_length/2,-1,0.1+box_outer_z/2])cube([board_length/2-30,case_thickness+2,mount_under_clearance+board_thickness+power_slot_z]);
    //bolt holes
    translate([case_thickness+board_extra_space,case_thickness+board_extra_space,-1]) {
      place_copies([[mount_edge_space,mount_edge_space,0],[mount_edge_space,-mount_edge_space+board_width,0],[-mount_edge_space+board_length,mount_edge_space,0],[-mount_edge_space+board_length,-mount_edge_space+board_width,0]]) cylinder(r=2,h=box_outer_z+10,center=false);
    }
    //head recess
    translate([case_thickness+board_extra_space,case_thickness+board_extra_space,-0.1]) {
      place_copies([[mount_edge_space,mount_edge_space,0],[mount_edge_space,-mount_edge_space+board_width,0],[-mount_edge_space+board_length,mount_edge_space,0],[-mount_edge_space+board_length,-mount_edge_space+board_width,0]]) cylinder(r=4,h=case_thickness/2,center=false);
    }
  }
}
/*translate([-box_outer_x-30,0,0]) */
top_box();
/*base_plate();
translate([0,box_outer_y/2-(20+box_outer_y/8),0])rotate([0,0,90])mount_pair(box_outer_y/4);
translate([box_outer_x/2-(20+box_outer_x/8),box_outer_y,0])mount_pair(box_outer_x/4);*/
