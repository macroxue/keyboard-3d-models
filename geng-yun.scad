$fn=24; // sides for circle
d=0.01;  // delta for extra cut

kd=19;  // key distance
cw=14;  // chamber width
ch= 8;  // chamber height

shw=3.3; // stabilizer hole width
shl=14;  // stabilizer hole length
shd=12;  // stabilizer hole distance to switch center
shs=0.7; // stabilizer hole shift

mpt=1.5; // mount plate thickness
chw=5;   // clip hole width
chh=2;   // clip hole height
chd=0.6; // clip hole depth

module teensy(x,y,z) {
  tl=36;  // teensy length
  tw=18;  // teensy width
  th=4;   // teensy height
  tbh=1;  // teensy board height
  tcl=6;  // teensy connector length
  tcw=8;  // teensy connector width
  tch=3;  // teensy connector height

  translate([x*kd, y*kd, z*kd]) rotate([0,90,180]) {
    cube([tbh,tl,tw]);
    color("white") translate([tbh,-1,tw/2-tcw/2]) cube([tch,tcl,tcw]);
  }
}

module case(left=false) {
  border = 2.5;
  length = 8.25*kd - border*2;
  width = 6.25*kd - border*2;
  corner = 5;
  wiring_hole = 6;
  support_width = 3.5;
  sink_unit = 2;
  thickness = 6;
  key_pos_left = [
    [5.25,0,1,0],[5.25,1,1,1],[5.25,2,1,1],[5.25,3.5,1,1],[5.25,4.5,1,1],[5.25,5.5,1,0],
    [4,0,1,0],[4,1,1,1],[4,2,1,2],[4,3,1,2],[4,4,1,1],[4,5,1,0],[4,6,1,0],
    [3,0,1,0],[3,1,1,1],[3,2,1,2],[3,3,1,2],[3,4,1,1],[3,5,1,0],[3,6,1.5,0],
    [2,0,1,0],[2,1,1,1],[2,2,1,2],[2,3,1,2],[2,4,1,1],[2,5,1,0],[2,6,1.75,0],
    [1,0,1,0],[1,1,1,1],[1,2,1,2],[1,3,1,2],[1,4,1,1],[1,5,2.25,0],
    [0,0,1.5,0],[0,1.5,1.5,0],[0,3,1.75,0],[0,4.75,1,0],[0,5.73,1.25,0],
  ];
  key_pos_right = [
    [5.25,0,1,0],[5.25,1,1,1],[5.25,2,1,1],[5.25,3.5,1,1],[5.25,4.5,1,1],[5.25,5.5,1,0],
    [4,0,1,0],[4,1,1,1],[4,2,1,2],[4,3,1,2],[4,4,1,1],[4,5,1,0],[4,6,1,0],
    [3,0,1,0],[3,1,1,1],[3,2,1,2],[3,3,1,2],[3,4,1,1],[3,5,1,0],[3,6,1.5,0],
    [2,0,1,0],[2,1,1,1],[2,2,1,2],[2,3,1,2],[2,4,1,1],[2,5,1,0],[2,6,2.25,0],
    [1,0,1,0],[1,1,1,1],[1,2,1,2],[1,3,1,2],[1,4,1,1],[1,5,1.5,0],
    [0,0,1.5,0],[0,1.5,1.5,0],[0,3,2,0],[0,5,1,0],[0,6,1.25,0],
  ];

  module key(row,col,size,sink=0) {
    translate([kd*(col+(size-1)/2)+border,kd*row+border,-sink*sink_unit-d]) {
      translate([-(kd-cw)/2,-(kd-cw)/2,thickness+d]) cube([kd+d,kd+d,sink*sink_unit+d*2]);
      cube([cw,cw,thickness+2*d]);
      translate([cw/2-chw/2,-chd,thickness-chh-mpt]) cube([chw,cw+chd*2,chh]);
    }
  }

  module keys() {
    if (left) for (k=key_pos_left) key(k[0],k[1],k[2],k[3]);
    else for (k=key_pos_right) key(k[0],k[1],k[2],k[3]);
  }

  module writing_left(row,col,height) {
    content = "耕";
    font = "WenQuanYi Micro Hei";
    translate([col*kd+16,row*kd,height+thickness-d]) rotate([0,180,0])
      linear_extrude(height+2*d) {
        text(content, font = font, size = 12);
      }
  }

  module writing_right(row,col,height) {
    content = "耘";
    font = "WenQuanYi Micro Hei";
    translate([col*kd,row*kd,thickness-d])
      linear_extrude(height+2*d) {
        text(content, font = font, size = 12);
      }
  }

  module front() {
    module fastener_holes() {
      module hole() {
        cylinder(r=1.5, h=thickness+d*2);
      }
      for (y=[0:1]) for (x=[0:1])
        translate([x*(length+2*border),y*(width+2*border),-1]) hole();
    }

    difference() {
      minkowski() {
        cube([length+border*2,width+border*2,thickness]);
        cylinder(r=corner,h=d);
      }
      keys();
      fastener_holes();
    }
    if (left) writing_left(5.4,7.1,2);
    else writing_right(5.4,7.1,2);
  }

  module back() {
    thickness = 2;

    module ribbon_hole(w,h) {
      translate([kd-w/2,width+corner+border-d,border+ch-h-0.5])
        cube([w,border+2*d,h+2*d]);
    }

    module usb_hole(w,h) {
      translate([7*kd+2,width+corner+border-d,border+2])
        cube([w,border+2*d,h+2*d]);
    }

    module plate() {
      difference() {
        union() {
          difference() {
            minkowski() {
              cube([length+border*2,width+border*2,ch+thickness]);
              cylinder(r=corner,h=d);
            }
            translate([border,border,thickness]) minkowski() {
              cube([length,width,ch+thickness]);
              cylinder(r=corner,h=d);
            }
          }
          // fasteners
          for (y=[0:1]) for (x=[0:1]) {
            translate([x*(length+2*border),y*(width+2*border),0])
              cylinder(r=4, h=ch+thickness);
            translate([x*(length+2*border),y*(width+2*border),0])
              cylinder(r1=1.5,r2=1.2, h=ch+thickness+4);
          }
        }

        usb_hole(8,3);
        ribbon_hole(9,3);

        // foot holes
        for (y=[0:5:5]) for (x=[1:1])
          translate([x*kd+kd-cw,y*kd+kd-cw,-d]) cube([cw,cw,thickness+2*d]);
      }
    }

    plate();
  }

  front();
  translate([0,0,-ch-10]) back();
}

module foot() {
  difference() {
    union() {
      cylinder(r=fr,h=fl,center=true);
      translate([0,0,-fl/2-sh/2]) cube([sw,sw,sh+d], center=true);
      translate([0,0,-fl/2-ph/2-sh/2]) cube([cw-0.2,cw-0.2,ph+d], center=true);
    }
    translate([0,0,fl/2]) rotate([0,20,0]) cube([cw,cw,3], center=true);
  }
  fl = 36;  // foot length
  fr = 3;   // foot radius
  ph = 5;   // plug height
  sw = cw+2;// stopper width
  sh = 2;   // stopper height
}

translate([-4*kd,-3*kd,0]) {
  case(left=false);
  translate([-kd,0,0]) mirror([1,0,0]) case(left=true);
  translate([-4,7,-1]) teensy(8,6,0);
  //foot();
}
