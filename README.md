# klipper_config of a Voron V2.4

This is the config of my Voron 2.4 350mm3 Serial:V2.660

Be aware I see my config as WIP and it can and will change any time. I normally do only checkin stuff that is tested and run with the base klipper branch but I test also klipper PRs so it can happen that I oversee that from time to time and have stuff here that needs a special PR from klipper.

## Printer specific user variables
Since commit #d8f818a user defined variables are combined in a single macro '_USER_VARIABLE' you find it in the printer.cfg L214. The benefit of this is that you need to change these values only at a single location if you wants to reuse it on a other printer or need to change a value because something changed in your printer.  This macro contains hard coded values but also some calculated values based on limits defined in the printer.cfg. These variables are used in all other macros that needs one of these values.
Since it also contains calculeted values the macro needs to run at every klipper start once. That is realized by the delayed_gecode macro '_CHECK_VORON_CONFIG' that runs automatical at klipper start. It will check if '_USER_VARIABLE' is existing and run it or throw are warning in the console. You find it inside the printer.cfg L201

## Optinal Hardware detection
Since commit #8b2d9f8 some optinal hardware is detected and the corosponding macros are only executed if this hardware was found. This should help adopt several macros but it is by no mean a universal config that you can use as a drop in for your printer and it will never be.
That you do not need to comment out macros of hardware that you do not have should be only seen as help I can only ask you to make you familiar with what you copy. 

## Improvements to QGL check
With the latest commit I changed the way how I check for a passing QGL. Now a separate macro is used that you can run afterwards. The only drawback here is that it cannot be part of PRINT_START as this errors out in case of a QGL fail. You need to add it to your slicer start gcode.
As an example, here is my PrusaSlicer setting:
```
M140 S0 ; needed so prusaslicer/superslicer doesn't add unneeded "wait for temps" by itself
M104 S0 ; needed so prusaslicer/superslicer doesn't add unneeded "wait for temps" by itself
PRINT_START EXTRUDER_TEMP=[first_layer_temperature] BED_TEMP=[first_layer_bed_temperature] LAYER_HEIGHT=[layer_height] SOAK=30 ; 30 min soak time
CHECK_QGL ; will detach probe and cancel print in case of an failing QGL
PRESSURE_ADVANCE_SELECT NOZZLE=[nozzle_diameter] FILAMENT=[filament_settings_id]
```
## Improvements to _USER_VARIABLE
With the latest commit I do a few improvements that hopefully make it clearer what is user defined and what values are made to be used in the macros: 
- to reduce the number of variables coordinates are now grouped in arrays in the format `[X,Y,Z]` or `[X,Y]`
- only values that are planned to be used in macros are defined as variables
- there is now a user setup block marked with:
```
###################################################################
##                     start of user defines                     ## 
## this needs to be changed for your printer                     ##
###################################################################
...
...
...
###################################################################
##                      end of user defines                      ## 
###################################################################
```
only values between these 2 marks need to be changed by the user
- variables inside the macro are clearer marked `user_...` are user defines all others are either calculated values or array grouping

The drawback is that it looks now like a massive wall of text, but I hope to get less questions about that part now.

## Use dictionaries for _USER_VARIABLE

Like the printer. object _USER_VARIABLES are now grouped in a handful of dictionaries. 
The big advantage of this is that you can use them like you are used to it. As an example:
```
printer['gcode_macro _USER_VARIABLE'].homing.z_endstop.x
```
this will be the x position of the z_endstop.

Following describes the variable as is today, that does not mean that there might be additions in the future that are not descript here:

**hw_ena** enables or disables extra hardware following are detected
- display  : true if display with neopixel in cfg
- chamber :  none/fan/sensor depending on cfg
- caselight : true if caselight is found in cfg
- filter :  true if filter is found in cfg
- runout : none/file/motion/switch depending on cfg
- relay : true if safety relais are found in cfg
- auto_z_offset : none/flexplate/z_calibz_calib+flexplate depends what is found in cfg
- mag_probe : true is a mag probe is found in cfg

**homing**
- z_endstop : [x,y,z,hop] x,y are the endstop coordinates, z is the minimum lift calculated from the endstop z_offset to do not press the pin and hop is the z hop for the G28 moves
- z_current : z motor current during homing and QGL commands
- accel : accereration during homing

**z_hop** : minimal z height for all movment

**speed** all speeds are defined in [mm/s]
- z_hop : speed for all z hop moves
- travel : speed for all travel moves
- dock : speed for the docking moves of the mag probe
- retract : retract and extrude speed 
- load : filament load speed
- wipe : wipe speed on the brush
- prime : prime line speed

**probe** these are only needed if you use a magnetic probe like klicky
- dock : [x,y] coordinates of the probe mount in dock position
- store : [x,y] coordinates of the probe mount in store position

**park** different park positions
- bed : [x,y,z] middle of bed, hight is user defined
- center : [x,y,z] middle of print volume
- frontlow : [x,y,z] front middle height is user defined
- front : [x,y,z] front middle height is user defined
- rear : [x,y,z] rear left height is user defined
- pause : [x,y,dz] x,y are the same position as purge, dz is the delta increase of the toolhead 
- park_at_cancel : Enable/Disable parkimg to the PAUSE position in CANCEL_PRINT

**filament** all values are in mm
- load_distance : filament distance used in load macro to get the filament in clockworks
- load_extrude : additional distance used in load macro  
- unload_distance : filament distance used in the unload macro 
- retract : [end,pause,cancel] different retract/unretract distances 

**purge** all variables needed to for the purge bucket and brush
- purge : [x,y,z] coordinates to do the filament purge
- wipe  : 
  - start : [x,y,z] coordinates for the wipe start
  - end : [x,y,z] coordinates for the wipe start
  - offset : offset for each wipe move in Y direction
  - cnt : number of wipe moves
 
 **print_start** different variables used in PRINT_START
- bed_up : increase of bed temp for faster heat soak
- ival : interval between the loops while doing PRINT_START
- time : 
  - extruder : start time of heating the extruder to target (e.g 3 min before heat soak is over)
  - bed : start time of decreasing bed to target (e.g 3 min before heat soak is over)
- prime_mult : height multiplier for the layer hight during purge

**unload_sd** : unload sd file at PRINT_END or CANCEL_PRINT. Set this to False if you often reprint the same file 

**prime** 
- pos : [x,y,z] start poaition for the prime line
- dir : direction of the prime line valid inputs X+, X-, Y+, Y-
- spacing : distance between the two lines
- length_per_seg : prime line is separated in segments to make baby-stepping easier. This is the length of a single segment
- seg : number of segments per line
- extrude_per_seg : amount of filament per segment in mm

**respond** enable or disable the default of outputs to the console
- z_current : default behavior for output messages of _SET_Z_CURRENT macro 0: no output 1: console output
- acc : default behavior for output messages of _SET_LAYER 0: no output 1: console output
- probe_action : default behavior for output messages of _PROBE_ACTION macro 0: no output 1: console output
- layer : default behavior for output messages of _LAYER macro 0: no output 1: console output

**peripheral** values needed for different hardware
- filter (Nevermore Mini)
  - on_val : target speed when turned on 
  - warning : time in hours after the filter material change warning should be displayed
  - run_after_print : time in minutes that the filter should run after the print is finished 
- vent (Exhaust set up as temperature_fan)
  - on_val : target temperature the Exhaust should be set to suck the air out of the chamber
  - run_after_print : time in minutes that the filter should run after the print is finished
- caselight 
  - on_val : target output when led are turned on

**run**: used internal to detect that the _USER_VARIABLE was executed
                          
**This should be the last bigger change of the variables as I am now quiet happy with the readability of it.**

## Klipper Start (_INIT)
There is now only one delayed_gcode with initial_duration set. This should help to get the start behavior better controllable and more visibly. Add everything you want to run once after klipper start in there.
To be able to use to gnerated _USER_VARIABLE that is splitted in 2 parts. Add anything you need to excute in _EXECUTE_AT_INIT

## UnicodeDecodeError after update (26.12.2021)
I use a python 3 enviroment and for me the config is working but I get feedback from at least one user that get the following error:
```
Error loading template 'gcode_macro PRINT_START:gcode': UnicodeDecodeError: 'ascii' codec can't decode byte 0xc2 in position 2539: ordinal not in range(128)
Traceback (most recent call last): File "/home/pi/klipper/klippy/extras/gcode_macro.py", line 51, in __init__
```
We traced it down to the degree symbol (°) but I am not sure why that this seams to be a problem. So if you run in the same issue remove the degree symbol in the various output messages at the following macros
- PRINT_START
- PRINT_END
- FILAMENT_LOAD
- FILAMENT_UNLOAD
- NOZZLECLEAN
- CANCEL_PRINT
- PAUSE

## Removal from .variables.stb from github
I had it now several times that user by accident use my .variables.stb. This might lead to problems and I therefor removed it from github. 
The following shows the current structure:
```
[Variables]
filament_loaded = 'true'
filament_sensor = {'toolhead_runout': 0, 'runout': 1}
plates = {'array': [{'name': 'Mueller', 'offset': 0.0}, {'name': 'Energetics', 'offset': 0.0}, {'name': 'Texture', 'offset': -0.1}, {'name': 'En_Thick', 'offset': 0.0}], 'index': 0}
pressure_advance = [{'id': 'ESUN_ABS+_Black', 'val': [{'nozzle': 0.4, 'pa': 0.05, 'st': 0.04}, {'nozzle': 0.6, 'pa': 0.055, 'st': 0.04}]}, {'id': 'KVP_ABS_FL_Blue', 'val': [{'nozzle': 0.4, 'pa': 0.05, 'st': 0.04}]}]
print_stats = {'filament': 2779399.9760404243, 'time': {'filter': 99430, 'total': 3275045, 'service': 965583}}
```
Please use your file or start with an empty file. The macros will add the needed variables as soon you define a plate/filament or the time of an print is added


## A word of Warning
Since I have heard people tring to copy my tmc optimization.
All driver_xxx values used in tmc.cfg are optimized for the physical drivers hocked up in the different slots and the motors I use.
**Do not copy these driver_xxx values** as there could harm and worst case damage your drivers or motors

I make my config public so that people can get ideas what you can do with macros and how to solve different problems. But I do not recommand to copy any macro from here blind without understanding what it does. 

## Disclaimer: Usage of this printer config happens at your own risk!
