# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



# ===========
# FUEL SYSTEM
# ===========

Fuel = {};

Fuel.new = func {
   var obj = { parents : [Fuel],

           tanksystem : Tanks.new()
         };

   obj.init();

   return obj;
};

Fuel.init = func {
   me.tanksystem.presetfuel();
}

Fuel.menuexport = func {
   me.tanksystem.menu();
}


# =====
# TANKS
# =====

# adds an indirection to convert the tank name into an array index.

Tanks = {};

Tanks.new = func {
# tank contents, to be initialised from XML
   var obj = { parents : [Tanks], 

           pumpsystem : Pump.new(),

           CONTENTLB : { "C" : 0.0, "1" : 0.0, "2" : 0.0, "3" : 0.0, "4" : 0.0, "R1" : 0.0, "R4" : 0.0 },
           TANKINDEX : { "C" : 0, "1" : 1, "2" : 2, "3" : 3, "4" : 4, "R1" : 5, "R4" : 6 },
           TANKNAME : [ "C", "1", "2", "3", "4", "R1", "R4" ],
           nb_tanks : 0,

           fillings : nil,
           tanks : nil
         };

    obj.init();

    return obj;
}

Tanks.init = func {
    me.tanks = props.globals.getNode("/consumables/fuel").getChildren("tank");
    me.fillings = props.globals.getNode("/systems/fuel/tanks").getChildren("filling");

    me.nb_tanks = size(me.tanks);

    me.initcontent();
}

# fuel initialization
Tanks.initcontent = func {
   var densityppg = 0.0;

   for( var i=0; i < me.nb_tanks; i=i+1 ) {
        densityppg = me.tanks[i].getChild("density-ppg").getValue();
        me.CONTENTLB[me.TANKNAME[i]] = me.tanks[i].getChild("capacity-gal_us").getValue() * densityppg;
   }
}

# change by dialog
Tanks.menu = func {
   var value = 0.0;

   value = getprop("/systems/fuel/tanks/dialog");
   for( var i=0; i < size(me.fillings); i=i+1 ) {
        if( me.fillings[i].getChild("comment").getValue() == value ) {
            me.load( i );

            # for aircraft-data
            setprop("/systems/fuel/presets",i);
            break;
        }
   }
}

# fuel configuration
Tanks.presetfuel = func {
   var fuel = 0;
   var dialog = "";

   # default is 0
   fuel = getprop("/systems/fuel/presets");
   if( fuel == nil ) {
       fuel = 0;
   }

   if( fuel < 0 or fuel >= size(me.fillings) ) {
       fuel = 0;
   } 

   # copy to dialog
   dialog = getprop("/systems/fuel/tanks/dialog");
   if( dialog == "" or dialog == nil ) {
       value = me.fillings[fuel].getChild("comment").getValue();
       setprop("/systems/fuel/tanks/dialog", value);
   }

   me.load( fuel );
}

Tanks.load = func( fuel ) {
   var presets = nil;
   var child = nil;
   var level = 0.0;

   presets = me.fillings[fuel].getChildren("tank");
   for( var i=0; i < size(presets); i=i+1 ) {
        child = presets[i].getChild("level-gal_us");
        if( child != nil ) {
            level = child.getValue();
        }

        # new load through dialog
        else {
            level = me.CONTENTLB[me.TANKNAME[i]] * constant.LBTOGALUS;
        } 
        me.pumpsystem.setlevel(i, level);
   } 
}

Tanks.transfertanks = func( dest, sour, pumplb ) {
   me.pumpsystem.transfertanks( dest, me.CONTENTLB[me.TANKNAME[dest]], sour, pumplb );
}


# ==========
# FUEL PUMPS
# ==========

# does the transfers between the tanks

Pump = {};

Pump.new = func {
   var obj = { parents : [Pump],

           tanks : nil 
         };

   obj.init();

   return obj;
}

Pump.init = func {
   me.tanks = props.globals.getNode("/consumables/fuel").getChildren("tank");
}

Pump.getlevel = func( index ) {
   var tankgalus = 0.0;

   tankgalus = me.tanks[index].getChild("level-gal_us").getValue();

   return tankgalus;
}

Pump.setlevel = func( index, levelgalus ) {
   me.tanks[index].getChild("level-gal_us").setValue(levelgalus);
}

Pump.transfertanks = func( idest, contentdestlb, isour, pumplb ) {
   var tankdestlb = 0.0;
   var tankdestgalus = 0.0;
   var maxdestlb = 0.0;
   var tanksourlb = 0.0;
   var tanksourgalus = 0.0;
   var maxsourlb = 0.0;

   tankdestlb = me.tanks[idest].getChild("level-gal_us").getValue() * constant.GALUSTOLB;
   maxdestlb = contentdestlb - tankdestlb;
   tanksourlb = me.tanks[isour].getChild("level-gal_us").getValue() * constant.GALUSTOLB;
   maxsourlb = tanksourlb - 0;

   # can fill destination
   if( maxdestlb > 0 ) {
       # can with source
       if( maxsourlb > 0 ) {
           if( pumplb <= maxsourlb and pumplb <= maxdestlb ) {
               tanksourlb = tanksourlb - pumplb;
               tankdestlb = tankdestlb + pumplb;
           }
           # destination full
           elsif( pumplb <= maxsourlb and pumplb > maxdestlb ) {
               tanksourlb = tanksourlb - maxdestlb;
               tankdestlb = contentdestlb;
           }
           # source empty
           elsif( pumplb > maxsourlb and pumplb <= maxdestlb ) {
               tanksourlb = 0;
               tankdestlb = tankdestlb + maxsourlb;
           }
           # source empty and destination full
           elsif( pumplb > maxsourlb and pumplb > maxdestlb ) {
               # source empty
               if( maxdestlb > maxsourlb ) {
                   tanksourlb = 0;
                   tankdestlb = tankdestlb + maxsourlb;
               }
               # destination full
               elsif( maxdestlb < maxsourlb ) {
                   tanksourlb = tanksourlb - maxdestlb;
                   tankdestlb = contentdestlb;
               }
               # source empty and destination full
               else {
                  tanksourlb = 0;
                  tankdestlb = contentdestlb;
               }
           }
           # user sees emptying first
           # JBSim only sees US gallons
           tanksourgalus = tanksourlb / constant.GALUSTOLB;
           me.tanks[isour].getChild("level-gal_us").setValue(tanksourgalus);
           tankdestgalus = tankdestlb / constant.GALUSTOLB;
           me.tanks[idest].getChild("level-gal_us").setValue(tankdestgalus);
       }
   }
}
