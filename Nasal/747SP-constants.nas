# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



# =============
# 747 CONSTANTS
# =============

ConstantAero = {};

ConstantAero.new = func {
   var obj = { parents : [ConstantAero],

# AGL altitude when on ground : radio altimeter is above gear
# (Z height of center of gravity minus Z height of main landing gear)
           AGLFT : 13,

# AGL altitude, where the gears touch the ground
           AGLTOUCHFT : 17
         };

   return obj;
}


# =========
# CONSTANTS
# =========

Constant = {};

Constant.new = func {
   var obj = { parents : [Constant],

# angles
           DEG360 : 360,
           DEG180 : 180,
           DEG90 : 90,

# no boolean
           TRUE : 1.0,
           FALSE : 0.0,

# ---------------
# unit conversion
# ---------------
# angle
           DEGTORAD : 0.0174532925199,

# time
           HOURTOSECOND : 3600.0,
           MINUTETOSECOND : 60.0,

# weight
           GALUSTOLB : 6.6,                        # 1 US gallon = 6.6 pound
           LBTOGALUS : 0.0
         };

   obj.init();

   return obj;
};

Constant.init = func {
   me.LBTOGALUS = 1 / me.GALUSTOLB;
}

# north crossing
Constant.crossnorth = func( offsetdeg ) {
   if( offsetdeg > me.DEG180 ) {
       offsetdeg = offsetdeg - me.DEG360;
   }
   elsif( offsetdeg < - me.DEG180 ) {
       offsetdeg = offsetdeg + me.DEG360;
   }

   return offsetdeg;
}

Constant.nonil = func ( value ) {
   if( value == nil ) {
       value = 0.0;
   }

   return value;
}
