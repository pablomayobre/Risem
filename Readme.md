#Risem

[Risem](https://positive07.github.io/Risem/) is the final school project that we (my team and I) will work on.

We go to a Technical School and in our last year in this Highschool we make a final project to show the things that we learned over the last six years.

##Team

The team is composed by three persons:

*    Gutierrez Bianchi, Mora
*    Mayobre, Pablo Ariel
*    Mazzocca, Franco Gabriel

We are all students at the ESETP N°748 in Trelew, Chubut - Argentina, in the Electronics career. We are all 17 and in our last year of highschool (2014).

##The project

The school already has a Radio Station, with a HUGE Power Supply, a [Yaesu FT-857D](http://www.yaesu.com/indexVS.cfm?cmd=DisplayProducts&ProdCatID=102&encProdID=8CBB7C4BDBAF40129AD4253A4987523C) and other equipment.

Our aim is to use this station to receive images from the [NOAA Satellites](http://www.n2yo.com/satellites/?c=4), this can be done using a [Quadrifilar Helix (QFH)](http://www.g4ilo.com/qfh.html) antenna, but we wanted to use a [Crossed Yagi-Uda antenna](http://sv1bsx.50webs.com/antenna-pol/polarization.html), this means that we need to track the satellite and aim the antenna at it.

To reach our goal we intend to create a system composed of four main parts:

+   The antenna: A simple Yagi-Uda antenna calculated at the main frequency of the NOAA satellites
+   The rotator: A stepper motor drived, two axis rotator, that enables the antenna to move in azimuth and elevation
+   The controller system: Based around PIC micro-controller from [Microchip](http://www.microchip.com/). This communicates with the PC and commands the motors in the rotator
+   The software: A software that can communicate with the PIC through USB to send the data captured from GPredict

##Gpredict

[Gpredict](http://gpredict.oz9aec.net/) is a simple but really good software that can track satellites and calculate the azimuth, elevation and doppler effect correction in real time.

Also it can send this data over a TCP/IP connection to the [Hamlib's](http://sourceforge.net/projects/hamlib/) rigctld and rotctld utilities. The protocol for this two softwares is available so we can easily replace them with our own software.

##NOAA Satellites

Why NOAA Satellites? They are cool!

No reason really, this project will be left in the school so it can be used as a didactic tool. The system can work with any satellite really, you just need to replace the antenna.

##Software

As stated above the software interacts with Gpredict through a TCP connection, but it also needs to have a simple user interface, and communicate with the control board. 
To do this we decided to use [LÖVE](http://www.love2d.org/) since that is the software I'm used to. 

LÖVE doesnt provide any interface to communicate with USB peripherials by default, so in order to communicate with the PIC we coded an intermediate app in C# (Visual Studio Express 2013), this app is a TCP server which offers access to the SerialPort class in .NET Framework.
Since C#, Visual Studio and .NET Framework are not Open Source we decided to minimze the code made using it. The TCP server can be replaced for other software with the same functionality allowing to easily port this program to other platforms.

##Controller Board

The controller is a home-built PCB made around the [PIC 18F4550](http://www.microchip.com/wwwproducts/Devices.aspx?dDocName=en010300), which offers an USB connection (Simulating a serial connection), a 16x2 Character Display (Used to display additional info), 2x L297 and L298 Stepper Motor Drivers, and a MAX232 serial connection (for CAT or other serial protocol).

The PIC will be programmed using MPLAB and the C18 compiler. The PCB was designed using EAGLE CAD 6.4.0

##Rotator

This will consist of two stepper motors, one to control the azimuth of the antenna, and another one to control the elevation.

The rotor will also use 2 worm reductions (one for azimuth and the other for elevation) of 1:30 ratio, to increment the torque an precission of the rotator.

##Antenna

The antenna is not a crucial part of the project, this can be easily replaced with any antenna, so no design instructions or such will be uploaded to this repo

##License

This project is Licensed under *MIT License* and Copyrighted by Mora Gutierrez, Pablo Mayobre and Franco Mazzocca.


###Contact

We have a [Facebook page](http://www.facebook.com/RisemENET) (we dont update it really often so it's kind of empty).

Send me a mail at [pablo.a.mayobre@gmail.com](mailto:pablo.a.mayobre@gmail.com) for more info.