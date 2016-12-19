$fn=24; // sides for circle
d=0.1;  // delta for extra cut

kcw=18; // key cap width
kch=1; // key cap height
kce=7;  // key cap elevation

kd=19;  // key distance
cw=14;  // chamber width
ch=12;  // chamber height
whr=3;  // wiring hole radius

tpt=2.5; // top plate thickness
shw=3.3; // stabilizer hole width
shl=14;  // stabilizer hole length
shd=12;  // stabilizer hole distance to switch center
shs=0.7; // stabilizer hole shift

pcbu = 1.27;    // PCB unit
apx = -3*pcbu;  // A pin center x coordinate
apy = 2*pcbu;   // A pin center y coordinate
apz = ch/2-7;   // A pin center z coordinate
bpx = 2*pcbu;   // B pin center x coordinate
bpy = 4*pcbu;   // B pin center y coordinate
bpz = ch/2-8;   // A pin center z coordinate

mpt=1.5; // mount plate thickness
chw=5;   // clip hole width
chh=2;   // clip hole height
chd=0.5; // clip hole depth

base_gap=3.5;

module cell(x=0,y=0) {
  translate([x*kd,y*kd,0]) difference() {
    union() {
      cube([kd+base_gap,kd+base_gap,ch], center=true);
      // uncomment this line to show key caps
      //translate([0,0,ch/2+kch/2+kce]) color("grey") cube([kcw,kcw,kch], center=true);
    }
    cube([cw,cw,ch+2*d], center=true);

    // clip holes
    translate([0,0,ch/2-mpt-chh/2]) cube([chw,cw+2*chd,chh], center=true);

    // wiring holes
    translate([0,apx,apz]) rotate([0,-90,0])
      cylinder(r=whr,h=kd+2*d+base_gap, center=true);
    translate([apx,0,apz]) rotate([90,0,0])
      cylinder(r=whr,h=kd+2*d+base_gap, center=true);
  }
}

module cell2x1(x=0,y=0) {
  translate([x*kd+kd/2,y*kd,ch/2-tpt/2]) cube([kd*2,kd,tpt], center=true);
}

module hole2x1(x=0,y=0) {
  translate([x*kd,y*kd,0]) translate([kd/2,0,0]) {
    cube([cw,cw,ch+d*2], center=true);
    translate([0,0,ch/2-mpt-chh/2]) cube([chw,cw+2*chd,chh], center=true);
    translate([-shd,-shs,ch/2-tpt/2]) cube([shw,shl,tpt+d*2], center=true);
    translate([shd,-shs,ch/2-tpt/2]) cube([shw,shl,tpt+d*2], center=true);
  }
}

module cell1x2(x=0,y=0) {
  translate([x*kd,y*kd,0]) rotate([0,0,90]) cell2x1(0,0);
}

module hole1x2(x=0,y=0) {
  translate([x*kd,y*kd,0]) rotate([0,0,90]) hole2x1(0,0);
}

module column(x=0,y1=0,y2=0) {
  for (y=[y1:y2-1]) {
    cell(x,y);
  }
  cell(x,y2+0.16);
}

module thumb_index_columns() {
  translate([-2*kd-3.8,0,7.4]) rotate([0,20,0])
    difference() {
      union() {
        translate([-kd,0,0]) column(0,-2,3);

        column(0,-2,3);
        cell2x1(-1,-2);
      }
      hole2x1(-1,-2);
    }
}

module middle_column() {
  translate([-kd-2.2,0,1.9]) rotate([0,10,0]) column(0,-2,3);
}

module ring_pinky_columns(cols=6) {
  difference() {
    union() {
      column(0,-2,3);
      column(1,-2,3);
      cell2x1(0,-2);
    }
    hole2x1(0,-2);
  }
  difference() {
    union() {
      column(2,-2,3);
      column(3,-2,3);
      cell2x1(2,-1);
      cell2x1(2,0);
    }
    hole2x1(2,-1);
    hole2x1(2,0);
  }
  difference() {
    union() {
      column(4,-2,3);
      column(5,-2,3);
      cell1x2(4,0);
    }
    hole1x2(4,0);
  }
}

module keyboard(flat_cols=6) {
  thumb_index_columns();
  middle_column();
  ring_pinky_columns(flat_cols);
}

module thumb_index_mask() {
  translate([-2*kd-3.8,0,7.4]) rotate([0,20,0])
    translate([-kd/2-base_gap,kd/2,0])
    cube([kd*2+base_gap*2+1.1,kd*7+2*d,ch+2*d], center=true);
}

module ring_pinky_mask() {
  translate([kd*3-base_gap*2,kd/2,0])
    cube([kd*6+base_gap*2-1.2,kd*7+2*d,ch+2*d], center=true);
}

module thumb_index_only() {
  intersection() {
    keyboard();
    thumb_index_mask();
  }
}
module middle_column_only() {
  difference() {
    keyboard();
    thumb_index_mask();
    ring_pinky_mask();
  }
}

module ring_pinky_only() {
  intersection() {
    keyboard();
    ring_pinky_mask();
  }
}

module keyboard_parts() {
  translate([-2,0,0]) thumb_index_only();
  middle_column_only();
  translate([2,0,0]) ring_pinky_only();
}

module side_plug(y=-2.5) {
  module hole_plug() {
    translate([0*kd,y*kd+(y<0?-spt:spt),0]) cube([kd+base_gap,spt*2,ch-2*d], center=true);
  }
  difference() {
    union() {
      hole_plug();
      translate([-kd-2.2,0,1.9]) rotate([0,10,0]) hole_plug();
      translate([-2*kd-3.8,0,7.4]) rotate([0,20,0]) hole_plug();
    }
    keyboard();
  }
  spt = 2;  // side plug thickness
}

//keyboard();
keyboard_parts();
//rotate([0,180-20,0]) translate([kd*3,-kd/2,0]) thumb_index_only();
//rotate([0,180-10,0]) translate([kd*1,-kd/2,0]) middle_column_only();
//rotate([0,180-0,0]) translate([-kd*2.5,-kd/2,0]) ring_pinky_only();
//rotate([90,0,0]) side_plug(-2.5);
//rotate([-90,0,0]) side_plug(3.5+0.16);
