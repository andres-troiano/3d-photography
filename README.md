# 3D profilometry using laser triangulation

## Abstract

A 3D laser triangulation profilometry system consisting of two camera-laser pairs was calibrated. The visible field was scanned with a reference object used for the sizing of industrial products, in order to relate the points in the camera coordinate system with their corresponding ones in space. 3 variants of this method were studied, using different reference objects: a trapezoidal pattern, a hexagonal pattern, and an original design featuring 90 corners. These 3 variants were put to the test by measuring 3 cylindrical standards with diameters ranging from 140 mm to 177 mm, obtaining in all cases errors that did not exceed 135 μm. Two of the methods used are extensible to 6 camera-laser pairs.

## 1. Introduction

Three-dimensional scanning technologies play a vital role in a wide variety of industries and disciplines, including factory process control, the healthcare sector, civil engineering, forensics and archaeology. The primary purpose is to create images or 3D models of an object for various purposes, such as reverse engineering, quality testing, or reconstruction of historical artifacts.

### 1.1 Triangulation methods

Of the various existing 3D scanning methods, the most widely used are those in which the target is illuminated with a laser or a fringe pattern. Laser methods fall into 3 categories: triangulation, time of flight , and phase shift. In triangulation methods, a narrow band of light projected onto a three-dimensional surface produces a line of illumination that will look distorted from any perspective other than the projector (see figure below). Analysis of the shape of these linear images can then be used to make an accurate geometric reconstruction of the object's surface. There are four main components of a 3D triangulation system: the camera, the linear projector which is typically a laser, a mechanism that moves the object or laser-camera pair through the system's field of view, and the software to process the image. accurately capture and convert distances between pixels into height differences

<img src="images/triangulacion.png" width="400">

### 1.2 Quality control for tubular products

At the Tenaris research center, 3D profilometry equipment was developed to measure defects on the surface of tubular steel products. These tubes have diameters in the range of 5.5'' to 9 5/8'' (140 to 244 mm). International quality standards require that surface defects do not exceed 5% of the tube wall thickness, which ranges from 4.5 mm to 12 mm depending on the product. The defects to be resolved have dimensions ranging from 300 μm to 600 μm. For the present work, an equipment was developed, based on laser triangulations. There are precedents on commercial equipment of this kind by companies such  as IMS ans SMS.

For this purpose, a reduced system consisting of 2 arms instead of 6 was assembled, in order to capture the essential characteristics of the problem, such as the inclination between the arms and the distance to the center of the system. The figure below shows an assembly diagram.

<img src="images/2_brazos.png" width="400">

## 2. Experimental setup

In order to assemble a system like the one seen above, two lasers were used: an Osela Streamline and a Coherent StingRay, both 660 nm, with a fan angle of 20° and focused at 390 mm. The width of the laser line was approximately 200 µm. Automation Technology C2-2040 high-speed cameras were used, with a resolution of 2048 x 1088 pixels, which were operated at a speed of 333 fps. Spacecom Pyxis 12 lenses and Midopt BP660 bandpass filters with a useful range of 640-680 nm were used together with the cameras.

The cameras and lasers were mounted arranged in two arms with a relative inclination of 60°, with a camera-laser angle of 45°. The figure below shows a general view of the complete assembly.

<img src="images/vista_general.png" width="400">

## 3. Calibration with trapezoidal pattern