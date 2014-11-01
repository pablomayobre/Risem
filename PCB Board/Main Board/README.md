Main Board
==========
This is the main board of the project **RISEM**. It has many modules that allow for all the interactions that are needed. These modules are the following:

*    *USB Connection:* The main board needs to be connected to the PC in order to get the Azimuth, Elevation and Frequency.

*    *Motor Controllers:* There are two motors in an AzEl Rotor, both of them are stepper motors that need to be controlled individually, for this task the board is equiped with two L297-L298 pairs, which support steppers motors up to 2A.

*    *Serial Connection:* The frequency of the Yaesu FT-857D is corrected through the use of a Serial-CAT cable, which transforms the TTL CAT signals of the Yaesu into RS-232 USART signals, in the main board a MAX232 converts the RS-232 signals into TTL signals again, in order to connect the USART module in the PIC to the Yaesu CAT module.

*    *LCD Connection:* A requirement for this project is the use of an LCD, this project is designed to support characters displays (16x2 or 16x4) with 5x7 characters.

*    *Programming Header:* The board allows to reprogram the PIC whenever there is a firmware update through a programming header.

*    *GPIO:* The port A was left unused, this pins are free so they can be used for future extensions.