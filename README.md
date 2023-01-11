# 3D profilometry using laser triangulation

## Abstract

A 3D laser triangulation profilometry system consisting of two camera-laser pairs was calibrated. The visible field was scanned with a reference object used for the sizing of industrial products, in order to relate the points in the camera coordinate system with their corresponding ones in space. 3 variants of this method were studied, using different reference objects: a trapezoidal pattern, a hexagonal pattern, and an original design featuring 90 corners. These 3 variants were put to the test by measuring 3 cylindrical standards with diameters ranging from 140 mm to 177 mm, obtaining in all cases errors that did not exceed 135 μm. Two of the methods used are extensible to 6 camera-laser pairs.

## Introduction

Three-dimensional scanning technologies play a vital role in a wide variety of industries and disciplines, including factory process control, the healthcare sector, civil engineering, forensics and archaeology. The primary purpose is to create images or 3D models of an object for various purposes, such as reverse engineering, quality testing, or reconstruction of historical artifacts.

### Triangulation methods

Of the various existing 3D scanning methods, the most widely used are those in which the target is illuminated with a laser or a fringe pattern. Laser methods fall into 3 categories: triangulation, time of flight , and phase shift. In triangulation methods, a narrow band of light projected onto a three-dimensional surface produces a line of illumination that will look distorted from any perspective other than the projector (see figure below). Analysis of the shape of these linear images can then be used to make an accurate geometric reconstruction of the object's surface. There are four main components of a 3D triangulation system: the camera, the linear projector which is typically a laser, a mechanism that moves the object or laser-camera pair through the system's field of view, and the software to process the image. accurately capture and convert distances between pixels into height differences

<img src="images/triangulacion.png" width="600">