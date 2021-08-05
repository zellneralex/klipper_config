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
SELECT_PA NOZZLE=[nozzle_diameter] FILAMENT=[filament_settings_id]
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


## A word of Warning
Since I have heard people tring to copy my tmc optimization.
All driver_xxx values used in tmc.cfg are optimized for the physical drivers hocked up in the different slots and the motors I use.
**Do not copy these driver_xxx values** as there could harm and worst case damage your drivers or motors

I make my config public so that people can get ideas what you can do with macros and how to solve different problems. But I do not recommand to copy any macro from here blind without understanding what it does. 

## Disclaimer: Usage of this printer config happens at your own risk!
