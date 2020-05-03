# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



# =========
# SEAT RAIL
# =========

SeatRail = {};

SeatRail.new = func {
   var obj = { parents : [SeatRail],

           RAILSEC : 5.0,

           FLIGHT : 0.0,
           PARK : 1.0
         };

}

SeatRail.toggle = func( seat ) {
   me.roll("/systems/human/" ~ seat ~ "/stowe-norm");
}

# roll on rail
SeatRail.roll = func( path ) {
   var pos = getprop(path);

   if( pos == me.FLIGHT ) {
       interpolate( path, me.PARK, me.RAILSEC );
   }
   elsif( pos == me.PARK ) {
       interpolate( path, me.FLIGHT, me.RAILSEC );
   }
}
