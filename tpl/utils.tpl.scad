
$fa=1.0;   // min angle
$fs=0.1;   // min segment
$fl=0.162; // layer height
$fd=0.4;   // nozzle diameter

// translate +z axis
module slide(z=$fl) {
  translate([0,0,z]) children();
}

module pivot(r=0) {
  rotate([r,90,-90]) children();
}

// translate z, then cylinder d=b, h=l
module shell(z=0, b, b2, l=$fl) {
  b2 = (b2==undef) ? b : b2;
  slide(z) cylinder(d1=b, d2=b2, h=l);
}

// like shell, but fuzz the diameter and position
module bore(z=0, b, b2, l=$fl) {
  shell(z=z-0.001, b=b+$fd, b2=b2, l=l+0.002);
}

// tone or embouchure hole
module hole(z=0, b, h, d, s, r=0, u=0, o=0) {
  s = (s==undef) ? d : s;
  rz=b/2;
  zo=sqrt(pow(rz+h,2)-pow(d/2,2));
  oh=rz+h-zo;
  do=d+tan(o)*2*oh;
  di=d+tan(u)*2*zo;
  zi=sqrt(pow(rz+$fd/2,2)-pow(di/2,2));
  ih=rz+h-zi-oh;
  slide(z) // position
    scale([1,1,s/d]) // eccentricity
      pivot(-r) // rotation
        union() {
          // shoulder cut
          shell(z=zo, b=d, b2=do, l=oh+0.001);
          // undercut
          shell(z=zi, b=di, b2=d, l=ih+0.001);
        }
}

// lip-plate
module plate(z=0, b, h, l, r=0) {
  od=b+2*h;
  slide(-l-h+z)
    rotate([0,0,r])
      hull() {
        shell(b=b);
        slide(h)
          intersection() {
            shell(b=od,l=2*l);
            slide(l) pivot() scale([1,od/l,1])
              shell(b=b, b2=2*l, l=od/2);
          }
        shell(z=2*l+2*h, b=b);
      }
}

module tenon(z=0, b, h, l) {
  slide(z) {
    hx=h+$fd/4;
    lz=l-hx;
    bx=b+2*hx;
    shell(b=bx, l=lz);
    shell(z=lz, b=bx, b2=b, l=hx);
  }
}