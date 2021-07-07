# klipper_config of a Voron V2.4

This is the config of my Voron 2.4 350mm3 Serial:V2.660

Be aware I see my config as WIP and it can and will change any time. I normally do only checkin stuff that is tested and run with the base klipper branch but I test also klipper PRs so it can happen that I oversee that from time to time and have stuff here that needs a special PR from klipper.

## Printer specific user variables
Since commit #d8f818a user defined variables are combined in a single macro '_USER_VARIABLE' you find it in the printer.cfg L214. The benefit of this is that you need to change these values only at a single location if you wants to reuse it on a other printer or need to change a value because something changed in your printer.  This macro contains hard coded values but also some calculated values based on limits defined in the printer.cfg. These variables are used in all other macros that needs one of these values.
Since it also contains calculeted values the macro needs to run at every klipper start once. That is realized by the delayed_gecode macro '_CHECK_VORON_CONFIG' that runs automatical at klipper start. It will check if '_USER_VARIABLE' is existing and run it or throw are warning in the console. You find it inside the printer.cfg L201

## Optinal Hardware detection
since commit #8b2d9f8 some optinal hardware is detected and the corosponding macros are only executed if this hardware was found. This should help adopt several macros but it is by no mean a universal config that you can use as a drop in for your printer and it will never be.
That you do not need to comment out macros of hardware that you do not have should be only seen as help I can only ask you to make you familiar with what you copy. 

## A word of Warning
Since I have heard people tring to copy my tmc optimization.
All driver_xxx values used in tmc.cfg are optimized for the physical drivers hocked up in the different slots and the motors I use.
**Do not copy these driver_xxx values** as there could harm and worst case damage your drivers or motors

I make my config public so that people can get ideas what you can do with macros and how to solve different problems. But I do not recommand to copy any macro from here blind without understanding what it does. 

## Disclaimer: Usage of this printer config happens at your own risk!
