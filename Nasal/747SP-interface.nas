# EXPORT : functions ending by export are called from xml
# CRON : functions ending by cron are called from timer
# SCHEDULE : functions ending by schedule are called from cron


# =====
# DOORS
# =====

Doors = {};

Doors.new = func {
   var obj = { parents : [Doors],

           cargodoors : nil,

           seat : SeatRail.new(),

           flightdeck : aircraft.door.new("controls/doors/crew/flightdeck", 8.0),
           exit : aircraft.door.new("controls/doors/crew/exit", 8.0),
           cargobulk : aircraft.door.new("controls/doors/cargo/bulk", 12.0),
           cargoaft : aircraft.door.new("controls/doors/cargo/aft", 12.0),
           cargoforward : aircraft.door.new("controls/doors/cargo/forward", 12.0)
         };

   obj.init();

   return obj;
};

Doors.init = func {
   me.cargodoors = props.globals.getNode("/controls/doors/cargo");
}

Doors.amber_cargo_doors = func {
   var result = constant.FALSE;

   if( me.cargodoors.getNode("forward").getChild("position-norm").getValue() > 0.0 or
       me.cargodoors.getNode("aft").getChild("position-norm").getValue() > 0.0 or
       me.cargodoors.getNode("bulk").getChild("position-norm").getValue() > 0.0 ) {
       result = constant.TRUE;
   }

   return result;
}

Doors.seatexport = func( seat ) {
   me.seat.toggle( seat );
}

Doors.flightdeckexport = func {
   me.flightdeck.toggle();
}

Doors.exitexport = func {
   me.exit.toggle();
}

Doors.cargobulkexport = func {
   me.cargobulk.toggle();
}

Doors.cargoaftexport = func {
   me.cargoaft.toggle();
}

Doors.cargoforwardexport = func {
   me.cargoforward.toggle();
}


# ====
# MENU
# ====

Menu = {};

Menu.new = func {
   var obj = { parents : [Menu],

           crew : nil,
           fuel : nil,
           radios : nil,
           menu : nil
         };

   obj.init();

   return obj;
};

Menu.init = func {
   # B747-200, because property system refuses 747-200
   me.menu = gui.Dialog.new("/sim/gui/dialogs/B747-200/menu/dialog",
                            "Aircraft/747-200/Dialogs/747-200-menu.xml");
   me.crew = gui.Dialog.new("/sim/gui/dialogs/B747-200/crew/dialog",
                            "Aircraft/747-200/Dialogs/747-200-crew.xml");
   me.fuel = gui.Dialog.new("/sim/gui/dialogs/B747-200/fuel/dialog",
                            "Aircraft/747-200/Dialogs/747-200-fuel.xml");
   me.radios = gui.Dialog.new("/sim/gui/dialogs/B747-200/radios/dialog",
                            "Aircraft/747-200/Dialogs/747-200-radios.xml");
}
