# 3D profilometry using laser triangulation

0. [Abstract](#sec_0)<br>
1. [Introduction](#sec_1)<br>
    1.1 [Triangulation methods](#sec_11)<br>
    1.2 [Quality control for tubular products](#sec_12)<br>
2. [Experimental setup](#sec_2)<br>
3. [Calibration using trapezoidal standard](#sec_3)<br>
    3.1 [Algorithm for finding corners](#sec_31)<br>
    3.2 [Calibration algorithm](#sec_32)<br>

## Abstract <a class="anchor" id="sec_0"></a>

A 3D laser triangulation profilometry system consisting of two camera-laser pairs was calibrated. The visible field was scanned with a reference object used for the sizing of industrial products, in order to relate the points in the camera coordinate system with their corresponding ones in space. 3 variants of this method were studied, using different reference objects: a trapezoidal pattern, a hexagonal pattern, and an original design featuring 90 corners. These 3 variants were put to the test by measuring 3 cylindrical standards with diameters ranging from 140 mm to 177 mm, obtaining in all cases errors that did not exceed 135 μm. Two of the methods used are extensible to 6 camera-laser pairs.

## 1. Introduction <a class="anchor" id="sec_1"></a>

Three-dimensional scanning technologies play a vital role in a wide variety of industries and disciplines, including factory process control, the healthcare sector, civil engineering, forensics and archaeology. The primary purpose is to create images or 3D models of an object for various purposes, such as reverse engineering, quality testing, or reconstruction of historical artifacts.

### 1.1 Triangulation methods <a class="anchor" id="sec_11"></a>

Of the various existing 3D scanning methods, the most widely used are those in which the target is illuminated with a laser or a fringe pattern. Laser methods fall into 3 categories: triangulation, time of flight , and phase shift. In triangulation methods, a narrow band of light projected onto a three-dimensional surface produces a line of illumination that will look distorted from any perspective other than the projector (see figure below). Analysis of the shape of these linear images can then be used to make an accurate geometric reconstruction of the object's surface. There are four main components of a 3D triangulation system: the camera, the linear projector which is typically a laser, a mechanism that moves the object or laser-camera pair through the system's field of view, and the software to process the image. accurately capture and convert distances between pixels into height differences

<img src="images/triangulacion.png" width="400">

### 1.2 Quality control for tubular products <a class="anchor" id="sec_12"></a>

At the Tenaris research center, 3D profilometry equipment was developed to measure defects on the surface of tubular steel products. These tubes have diameters in the range of 5.5'' to 9 5/8'' (140 to 244 mm). International quality standards require that surface defects do not exceed 5% of the tube wall thickness, which ranges from 4.5 mm to 12 mm depending on the product. The defects to be resolved have dimensions ranging from 300 μm to 600 μm. For the present work, an equipment was developed, based on laser triangulations. There are precedents on commercial equipment of this kind by companies such  as IMS ans SMS.

For this purpose, a reduced system consisting of 2 arms instead of 6 was assembled, in order to capture the essential characteristics of the problem, such as the inclination between the arms and the distance to the center of the system. The figure below shows an assembly diagram.

<img src="images/2_brazos.png" width="400">

## 2. Experimental setup <a class="anchor" id="sec_2"></a>

In order to assemble a system like the one seen above, two lasers were used: an Osela Streamline and a Coherent StingRay, both 660 nm, with a fan angle of 20° and focused at 390 mm. The width of the laser line was approximately 200 µm. Automation Technology C2-2040 high-speed cameras were used, with a resolution of 2048 x 1088 pixels, which were operated at a speed of 333 fps. Spacecom Pyxis 12 lenses and Midopt BP660 bandpass filters with a useful range of 640-680 nm were used together with the cameras.

The cameras and lasers were mounted arranged in two arms with a relative inclination of 60°, with a camera-laser angle of 45°. The figure below shows a general view of the complete assembly.

<img src="images/vista_general.jpg" width="400">

## 3. Calibration using trapezoidal standard <a class="anchor" id="sec_3"></a>

As mentioned previously, the goal of this work is to calibrate the system by scanning the entire field of view of the cameras with a determined reference object fixed to the positioners, whose position is precisely known. Then a map is modeled that links the coordinate systems of the cameras with that of the positioners, with which it will be possible to determine the position in space of the target from the signal on the camera sensors. An Automation Technology trapezoidal standard was used. This standard was placed so that two of its corners are oriented towards the two cameras, as shown in the figure below. Corners 1 and 2 were detected with cameras 1 and 2 respectively.

<img src="images/trapecio_con_camaras_2.png" width="400">

### 3.1 Algorithm for finding corners <a class="anchor" id="sec_31"></a>

The purpose of this algorithm is to identify the 2 lines that make up the visible corner in the sensor (if there are any) and find their intersection. The steps of the algorithm are as follows:

1. First, a profile is identified in the central region of the scan.
2. Then all the profiles are ordered in order of proximity with respect to that first profile.
3. In the first profile, the user manually points out by clicking the approximate position of the corner to be found (see figure below).

<img src="images/eleccion_esquina.png" width="400">

4. Starting from the coordinates ($x_0$, $y_0$) given by the user, the algorithm divides the profile in two, to the left and to the right of $x_0$. Take a range of 40 pixels on either side of $x_0$ and fit each of the two regions by lines. It then performs an iteration in which it discards those points that are more than 3 standard deviations away from the fit, and refits with the remaining points. In this way, it finds the lines that best fit the two faces of the corner, and determines its coordinates from the intersection of these two lines.
5. Once the corner of the first profile is found, the algorithm continues with the next closest to the first. In this case it is no longer necessary for the user to provide an initial estimate of the position of the corner. Instead the algorithm takes a cutout of the first profile, made up of an environment of the corner, and compares the new profile with the corner already found until it identifies the region of the new profile that most resembles the previous corner. For this, the new profile and the previous corner are plotted superimposed, starting from the left end of the new profile (see figure below).

<img src="images/guess_next_corner/correlacion_paso_1.png" width="400">

A scan is made in which the previous corner is moved to the right, and at each point the difference between both profiles is calculated, as shown in figure below.

<img src="images/guess_next_corner/diferencia_paso_1.png" width="400">

The goal is to have a measure of how similar the two profiles are at each step of the scan. To do this, in each step all the points of the difference are added, that is, all the $y$ coordinates of the figure above. Figure below shows the result, where it can be seen that in the first 500 pixels, as well as in the last ones, the difference between the new profile and the previous corner is constant, because the new profile has a value constant in those regions.

<img src="images/guess_next_corner/perfil_Q.png" width="400">

However, this curve has a minimum, where the previous corner overlapped with the corner of the new profile (see figure below).

<img src="images/guess_next_corner/correlacion_final.png" width="400">

6. At coordinate $x$ of said minimum, the process described in step 4 is repeated to find the corner of the new profile.
7. The algorithm continues finding the corners of the remaining profiles, in order of closeness to the first, until it has 10 corners. Once that point is reached, the algorithm implements a faster method to obtain the first estimate of the corner. This method no longer consists in comparing with a reference corner, but in taking the 10 corners already found and plotting the $x$ coordinate of the corner (in pixels) based on the $x, y$ coordinates in millimeters of the corresponding profile. That is, the coordinates of the linear locators in which that profile was measured. This is shown in figure below in red dots. These points are fitted by a polynomial of degree 2, as shown in the same figure. The algorithm then takes the $x,y$ coordinates of the next profile (in millimeters) and uses them to evaluate the polynomial. In this way it obtains an estimate of the position of the corner in the new profile (blue dot in the figure below). Then proceed as in step 4 to find the coordinates accurately.

<img src="images/guess_next_corner/ajuste_mas_de_10.png" width="400">

8. The algorithm continues in this way until the profiles are exhausted.

Once all the profiles have been processed, the figure below is obtained, which shows the $x$ and $y$ coordinates of the positioners for which it was possible to find an intersection with one or the other camera.

<img src="images/intersecciones.png" width="400">

The figure below shows the coordinates in pixels of the intersections as a function of $x$ and $y$. After finding all available intersections with each camera, each was calibrated individually as described in the next section.

<img src="images/pxVsMm.png" width="400">

### 3.2 Calibration algorithm <a class="anchor" id="sec_32"></a>