# VisProt for differential visual proteomics by electron microscopy

### About:
VisProt is a MATLAB-based package designed for electron microscopy image-processing and differential visual proteomics.

### Instructions:
1. Create a project directory and add the <i>vp</i> package. 

2. In the project directory create the folder <i>RawMicrographs</i>  that contains micrographs of different samples (eg: RawMicrographs/Sample1/, RawMicrographs/Sample2/, etc). 

2. Launch MATLAB in the project directory and initiate VisProt with either:
>> vp.MasterScript_matlab 

for particle picking with MATLAB (.tif micrographs) or

>> vp.MasterScript_gauto

for particle picking with Gautomatch (.mrc micrographs).

### Dependencies:
<ul>
<li>Supported platforms: MacOS/Linux</li>
<li>Matlab 9.0 (R2016a) or later</li>
<li>MATLAB Central File Exchange:
  <ol>
  <li>Cobeldick, Stephen (2012). Natural-Order Filename Sort</li>
  <li>Sigworth, Fred (2009). Imagic, MRC and DM3 file i/o</li>
  <li>Altman, Yair (2007). Findjobj - Find java handles of Matlab graphic objects</li>
  </ol></li>
<li>Relion-2.1</li>
<li>Gautomatch v0.53</li>
<li>CTFFIND-4.1.4 </li>
</ul>
