togglereverser = func {
	FDMEngine1 = "/fdm/jsbsim/propulsion/engine";
	FDMEngine2 = "/fdm/jsbsim/propulsion/engine[1]";
	FDMEngine3 = "/fdm/jsbsim/propulsion/engine[2]";
	FDMEngine4 = "/fdm/jsbsim/propulsion/engine[3]";

	ControleEngine1 = "/controls/engines/engine"; 
	ControleEngine2 = "/controls/engines/engine[1]"; 
	ControleEngine3 = "/controls/engines/engine[2]"; 
	ControleEngine4 = "/controls/engines/engine[3]"; 

	EntradaSIM = "/sim/input/selected";
	
	ReversorEngine1 = "/engines/engine/reverser-pos-norm"; 
	ReversorEngine2 = "/engines/engine[1]/reverser-pos-norm"; 
	ReversorEngine3 = "/engines/engine[2]/reverser-pos-norm"; 
	ReversorEngine4 = "/engines/engine[3]/reverser-pos-norm"; 

	val = getprop(ReversorEngine1);
	
	if (val == 0 or val == nil) {
		interpolate(ReversorEngine1, 1.0, 1.4); 
		interpolate(ReversorEngine2, 1.0, 1.4);  
		interpolate(ReversorEngine3, 1.0, 1.4); 
		interpolate(ReversorEngine4, 1.0, 1.4);
		
		setprop(FDMEngine1,"reverser-angle-rad","180");
		setprop(FDMEngine2,"reverser-angle-rad","180");
		setprop(FDMEngine3,"reverser-angle-rad","180");
		setprop(FDMEngine4,"reverser-angle-rad","180");
		
		setprop(ControleEngine1,"reverser", "true");
		setprop(ControleEngine2,"reverser", "true");
		setprop(ControleEngine3,"reverser", "true");
		setprop(ControleEngine4,"reverser", "true");
		
		setprop(EntradaSIM,"engine", "true");
		setprop(EntradaSIM,"engine[1]", "true");
		setprop(EntradaSIM,"engine[2]", "true");
		setprop(EntradaSIM,"engine[3]", "true");
	} else {
		if (val == 1.0){		
			interpolate(ReversorEngine1, 0.0, 1.4);
			interpolate(ReversorEngine2, 0.0, 1.4);   
			interpolate(ReversorEngine3, 0.0, 1.4);
			interpolate(ReversorEngine4, 0.0, 1.4);
			
			setprop(FDMEngine1,"reverser-angle-rad",0);
			setprop(FDMEngine2,"reverser-angle-rad",0);
			setprop(FDMEngine3,"reverser-angle-rad",0);
			setprop(FDMEngine4,"reverser-angle-rad",0);
			
			setprop(ControleEngine1,"reverser",0);
			setprop(ControleEngine2,"reverser",0);
			setprop(ControleEngine3,"reverser",0);
			setprop(ControleEngine4,"reverser",0);
			
			setprop(EntradaSIM,"engine", "true");
			setprop(EntradaSIM,"engine[1]", "true");
			setprop(EntradaSIM,"engine[2]", "true");
			setprop(EntradaSIM,"engine[3]", "true");

		  }
	 }
}

