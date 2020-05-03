# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron



# ===============================
# GROUND PROXIMITY WARNING SYSTEM
# ===============================

Gpws = {};

Gpws.new = func {
   var obj = { parents : [Gpws],

           FLIGHTFT : 2500,
           GEARFT : 500,
           GROUNDFT : 200,

           FLIGHTFPS : -50,
           GROUNDFPS : -15,
           TAXIFPS : -5,                                   # taxi is not null

           GEARDOWN : 1.0,

           gear : nil,
           ivsi : nil,
           radioaltimeter : nil
         };

   obj.init();

   return obj;
};

Gpws.init = func {
   me.gear = props.globals.getNode("/gear/gear[0]");
   me.ivsi = props.globals.getNode("/instrumentation/inst-vertical-speed-indicator");
   me.radioaltimeter = props.globals.getNode("/position");
}

Gpws.red_pull_up = func {
   var result = constant.FALSE;
   var aglft = me.radioaltimeter.getChild("altitude-agl-ft").getValue();
   var verticalfps = me.ivsi.getChild("indicated-speed-fps").getValue();
   var gearpos = me.gear.getChild("position-norm").getValue();

   if( aglft == nil or verticalfps == nil or gearpos == nil ) {
      result = constant.FALSE;
   }

   # 3000 ft/min
   elsif( aglft < me.FLIGHTFT and verticalfps < me.FLIGHTFPS ) {
       result = constant.TRUE;
   }

   # 900 ft/min
   elsif( aglft < me.GROUNDFT and verticalfps < me.GROUNDFPS ) {
       result = constant.TRUE;
   }

   # gear not down
   elsif( aglft < me.GEARFT and verticalfps < me.TAXIFPS and gearpos < me.GEARDOWN ) {
       result = constant.TRUE;
   }

   return result;
}


# ==============
# WARNING SYSTEM
# ==============

Warning = {};

Warning.new = func {
   var obj = { parents : [Warning],

           doorsystem : nil,

           gpwssystem : Gpws.new(),

           ambers : nil,
           reds : nil,
           textures : nil,

           PATH : "Textures/"
         };

   obj.init();

   return obj;
};

Warning.init = func {
   var children = nil;
   var name = "";
   var texture = "";

   me.ambers = props.globals.getNode("/systems/warning/amber");
   me.reds = props.globals.getNode("/systems/warning/red");
   me.textures = props.globals.getNode("/systems/warning/texture");

   # all textures at off
   children = me.textures.getNode("amber").getChildren();
   foreach( var c; children ) {
       name = c.getName();
       texture = me.offtexture( name );
       c.setValue( texture );
   }

   children = me.textures.getNode("red").getChildren();
   foreach( var c; children ) {
       name = c.getName();
       texture = me.offtexture( name );
       c.setValue( texture );
   }
}

Warning.set_relation = func( door ) {
   me.doorsystem = door;
}

Warning.schedule = func {
   me.sendamber( "cargo-doors", me.doorsystem.amber_cargo_doors() );

   me.sendred( "pull-up", me.gpwssystem.red_pull_up() );
}

Warning.offtexture = func( name ) {
   var result = me.PATH ~ "747-off-" ~ name ~ ".rgb";

   return result;
}

Warning.sendamber = func( name, value ) {
   var texture = "";

   if( me.ambers.getChild(name).getValue() != value ) {
       me.ambers.getChild(name).setValue( value );

       if( value ) {
           texture = me.PATH ~ "747-amber-" ~ name ~ ".rgb";
       }
       else {
           texture = me.offtexture( name );
       }

       me.textures.getNode("amber").getChild(name).setValue( texture );
   }
}

Warning.sendred = func( name, value ) {
   var texture = "";

   if( me.reds.getChild(name).getValue() != value ) {
       me.reds.getChild(name).setValue( value );

       if( value ) {
           texture = me.PATH ~ "747-red-" ~ name ~ ".rgb";
       }
       else {
           texture = me.offtexture( name );
       }

       me.textures.getNode("red").getChild(name).setValue( texture );
   }
}
