# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



# ======
# FLIGHT
# ======

Flight = {};

Flight.new = func {
   var obj = { parents : [Flight],

           flightcontrols : nil,

           FLIGHTSEC : 1.0,              # refresh rate

           SPOILEREXTEND : 1.0,
           SPOILERARM : 0.5,
           SPOILERRETRACT : 0.0,

           SPOILERSKT : 120.0
         };

   obj.init();

   return obj;
};

Flight.init = func {
   me.flightcontrols = props.globals.getNode("/controls/flight");
}

Flight.schedule = func {
   var aglft = 0.0;
   var speedkt = 0.0;

   if( me.flightcontrols.getChild("spoilers-lever").getValue() == me.SPOILERARM ) {
       aglft = constant.nonil( getprop("/instrumentation/radio-altimeter/indicated-altitude-ft") );
       speedkt = constant.nonil( getprop("/instrumentation/airspeed-indicator/indicated-speed-kt" ) );

       # extend spoilers at touch down (also avoids rebound of autoland)
       if( aglft < constantaero.AGLTOUCHFT and speedkt > me.SPOILERSKT ) {
 
           # avoids hard landing (quick fall of nose)
           if( getprop("/gear/gear[1]/wow") or getprop("/gear/gear[2]/wow") or
               getprop("/gear/gear[3]/wow") or getprop("/gear/gear[4]/wow") ) {
               me.spoilersexport( 1.0 );
           }
       }
   }
}

Flight.spoilersexport = func( step ) {
   var value = 0.0;

   value = me.flightcontrols.getChild("spoilers-lever").getValue();
   value = value + step * me.SPOILERARM;

   if( value < me.SPOILERRETRACT ) {
       value = me.SPOILERRETRACT;
   }
   elsif( value > me.SPOILEREXTEND ) {
       value = me.SPOILEREXTEND;
   }

   me.flightcontrols.getChild("spoilers-lever").setValue(value);

   controls.stepSpoilers( step );
}


# ====
# TCAS
# ====

Traffic = {};

Traffic.new = func {
   var obj = { parents : [Traffic],

           ai : nil,
           aircrafts : nil,
           altimeter : nil,
           instrument : nil,
           traffics : nil,

           TCASSEC : 3.0,

           nbtraffics : 0,

           MINKT : 30,

           NOTRAFFIC : 9999
         };

   obj.init();

   return obj;
};

Traffic.init = func {
   me.ai = props.globals.getNode("/ai/models");
   me.altimeter = props.globals.getNode("/instrumentation/altimeter");
   me.instrument = props.globals.getNode("/instrumentation/tcas");
   me.traffics = props.globals.getNode("/instrumentation/tcas/traffics").getChildren("traffic");

   me.clear();
}

Traffic.clear = func {
   for( var i=me.nbtraffics; i < size(me.traffics); i=i+1 ) {
        me.traffics[i].getNode("distance-nm").setValue(me.NOTRAFFIC);
   }
}

Traffic.schedule = func {
   var altitudeft = 0.0;
   var speedkt = 0.0;
   var rangenm = 0.0;
   var xshift = 0.0;
   var yshift = 0.0;
   var rotation = 0.0;
   var radar = nil;

   me.nbtraffics = 0;

   if( me.instrument.getChild("serviceable").getValue() ) {
       altitudeft = me.altimeter.getChild("indicated-altitude-ft").getValue();
       if( altitudeft == nil ) {
           altitudeft = 0.0;
       }

       # missing nodes, if not refreshed
       me.aircrafts = me.ai.getChildren("aircraft");

       for( var i=0; i < size(me.aircrafts); i=i+1 ) {
            # instrument limitation
            if( me.nbtraffics >= size(me.traffics) ) {
                break;
            }

            # destroyed aircraft
            if( me.aircrafts[i] == nil ) {
                continue;
            }

            radar = me.aircrafts[i].getNode("radar/in-range");
            if( radar == nil ) {
                continue;
            }

            # aircraft on ground
            speedkt = me.aircrafts[i].getNode("velocities/true-airspeed-kt").getValue();
            if( speedkt < me.MINKT ) {
                continue;
            }

            if( radar.getValue() ) {
                rangenm = me.aircrafts[i].getNode("radar/range-nm").getValue();

                # relative altitude
                levelft = me.aircrafts[i].getNode("position/altitude-ft").getValue();
                levelft = levelft - altitudeft;

                xshift = me.aircrafts[i].getNode("radar/x-shift").getValue();
                yshift = me.aircrafts[i].getNode("radar/y-shift").getValue();
                rotation = me.aircrafts[i].getNode("radar/rotation").getValue();

                me.traffics[me.nbtraffics].getNode("distance-nm").setValue(rangenm);
                me.traffics[me.nbtraffics].getNode("level-ft",1).setValue(levelft);
                me.traffics[me.nbtraffics].getNode("x-shift",1).setValue(xshift);
                me.traffics[me.nbtraffics].getNode("y-shift",1).setValue(yshift);
                me.traffics[me.nbtraffics].getNode("rotation",1).setValue(rotation);
                me.traffics[me.nbtraffics].getNode("index",1).setValue(i);
                me.nbtraffics = me.nbtraffics + 1;
            }
       }
   }

   # no traffic
   me.clear();
   me.instrument.getChild("nb-traffics").setValue(me.nbtraffics);
}


# =============
# SPEED UP TIME
# =============

DayTime = {};

DayTime.new = func {
   var obj = { parents : [DayTime],

           altitudenode : nil,
           thesim : nil,
           warpnode : nil,

           SPEEDUPSEC : 1.0,

           CLIMBFTPMIN : 2000,                                       # average climb rate
           MAXSTEPFT : 0.0,                                          # altitude change for step

           lastft : 0.0
         };

   obj.init();

   return obj;
}

DayTime.init = func {
    var climbftpsec = me.CLIMBFTPMIN / constant.MINUTETOSECOND;

    me.MAXSTEPFT = climbftpsec * me.SPEEDUPSEC;

    me.altitudenode = props.globals.getNode("/position/altitude-ft");
    me.thesim = props.globals.getNode("/sim");
    me.warpnode = props.globals.getNode("/sim/time/warp");
}

DayTime.schedule = func {
   var altitudeft = 0.0;
   var speedup = 1.0;
   var multiplier = 0.0;
   var offsetsec = 0.0;
   var warpi = 0.0;
   var stepft = 0.0;
   var maxft = 0.0;
   var minft = 0.0;

   altitudeft = me.altitudenode.getValue();

   speedup = me.thesim.getChild("speed-up").getValue();
   if( speedup > 1 ) {
       # accelerate day time
       multiplier = speedup - 1;
       offsetsec = me.SPEEDUPSEC * multiplier;
       warp = me.warpnode.getValue() + offsetsec; 
       me.warpnode.setValue(warp);

       # safety
       stepft = me.MAXSTEPFT * speedup;
       maxft = me.lastft + stepft;
       minft = me.lastft - stepft;

       # too fast
       if( altitudeft > maxft or altitudeft < minft ) {
           me.thesim.getChild("speed-up").setValue(1);
       }
   }

   me.lastft = altitudeft;
}
