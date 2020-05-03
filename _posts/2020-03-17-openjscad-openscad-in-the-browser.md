---
layout: post
title:  OpenJSCAD - OpenSCAD in the browser
date:   2020-03-17 18:58 +0100
image:  pawel-szvmanski-_pQyE6ac9w0-unsplash.jpg
credit: https://unsplash.com/photos/_pQyE6ac9w0
tags:   CAD browser
---

> OpenSCAD is a free software application for creating solid 3D CAD (computer-aided design) objects. It is a script-only based modeller that uses its own description language … — [Wikipedia: OpenSCAD](https://en.wikipedia.org/wiki/OpenSCAD)

I just downloaded [OpenSCAD](http://www.openscad.org/) in the morning before I saw the [OpenJSCAD](https://openjscad.org/) link at Lobsters. Yes, it is nearly the same ... except that it runs in the browser. You can write OpenSCAD code and create an STL file that can be used for 3D printing.

When you open OpenJSCAD, there is already an example. I've scaled up the inner sphere / cube and moved it to the bottom:

```OpenSCAD
function main () {
  return union(
    difference(
      cube({size: 3, center: true}),
      sphere({r: 2, center: true})
    ),
    intersection(
      sphere({r: 1.7, center: true}),
      cube({size: 2.8, center: true})
    ).translate([0, 0, -0.1]) // move it to ground
  ).translate([0, 0, 1.5]).scale(10);
}
```

To render the code press Shift+Enter and with Generate STL you can download the STL code. The STL file can be used in a slicer program, for example Ultimaker Cura.

![OpenJSCAD Screenshot](/images/OpenJSCAD_Screenshot.png)

... and here is the result. I scaled it down by 50%, which was too small and therefore not stable 🤷‍♂️:

![OpenJSCAD 3D Printed](/images/OpenJSCAD_3dprint.jpg)
