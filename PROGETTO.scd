//Author: Amedeo Racanati
//Email: amedeo.racanati@edu.unito.it


//Welcome to "The Sequencer"
//This program emulates a simple sequencer with 8 drum sample tracks
//Each track has customizable parameters: amplitude, pitch, delay, reverb and of course when to play a single beat

//The code first defines 2 Synths
//Then it creates the bus needed for the delay
//It uses the classes GeneralManager and MyTrack (loaded from the classi library) in order to manage the different track parameters
//After initialization, it creates the GUI in order to manage the tracks parameters


// ---- SYNTHS DEFINITION ----

//DEF DELAY
//Read input from a bus and output the delay to another bus
SynthDef("aDelay", { | delay = 0.1, inBus, out = 1 |
    Out.ar(
        out,
		DelayL.ar(
			In.ar(inBus) * 0.3,
			delay * GeneralManager.time * 4,
			delay * GeneralManager.time
        )
    )
}).add;


//DEF BASIC TRACK
//You can define the output and the delay bus as well as the sound to be played
//You can set the amplitude, the pitch, the delay and the reverb
SynthDef("basicTrack", {| out = 0, outDelay, bufnum = 0, amp = 1, freqMul = 1, delayAmp = 1, roomReverb = 0.1 |

	var signal, signalDelay;

	//the signal has a little random amplitude in order to make it more "human"
	signal = amp *  LFNoise0.kr(4, 0.2, 0.8) * //amplitude
		    PlayBuf.ar(1, bufnum,
		       rate: BufRateScale.kr(bufnum) * freqMul, //pitch
			   doneAction: Done.freeSelf);


	//output bus (add reverb)
	Out.ar(out, FreeVerb.ar(signal, room: roomReverb));

	//signal to send to the delay bus
	signalDelay = signal * delayAmp;
	Out.ar(outDelay, signalDelay);
}).add;


//Create the bus reserved for the delay
~busDelay = Bus.audio(s, 1);

//Create the Synth for the delay
Synth.new("aDelay", [\inBus, ~busDelay]);



// ---- TRACKS INITIALIZATION ----

//beats per second
GeneralManager.time = 2;

//number of beats per loop
GeneralManager.numberBeats = 8;

//folder path for the file samples
p = "D:\\Download\\99S013_99_Drum_Samples\\OK\\";

//creating each track...
~tracks = Array.fill(GeneralManager.numberTracks, { arg i;

	var pathFile = p.catArgs(i + 1, ".wav").postln;

	//basic initialization
	var newTrack = MyTrack.new;
	newTrack.init(s, pathFile, i, ~busDelay);


	//custom initialization (the Sequencer is ready to be played)
	if(i == 0, {
		newTrack.set_seq_element(1, 1);
		newTrack.set_seq_element(3, 1);
		newTrack.set_seq_element(6, 1);
		newTrack.set_seq_element(10, 1);
		newTrack.set_seq_element(13, 1);
		newTrack.set_seq_element(16, 1);
		newTrack.set_seq_element(19, 1);
		newTrack.set_seq_element(22, 1);
		newTrack.set_seq_element(26, 1);
	});
	if(i == 1, {
		newTrack.set_seq_element(0, 1);
		newTrack.set_seq_element(29, 1);
	});
	if(i == 2, {
		newTrack.set_seq_element(0, 1);
		newTrack.set_seq_element(8, 1);
		newTrack.set_seq_element(16, 1);
		newTrack.set_seq_element(24, 1);
		newTrack.set_seq_element(29, 1);
	});
	if(i == 3, {
		newTrack.set_seq_element(4, 1);
		newTrack.set_seq_element(12, 1);
		newTrack.set_seq_element(20, 1);
		newTrack.set_seq_element(28, 1);
		newTrack.set_amp(0.7);
		newTrack.set_roomReverb(1.0);
	});
	if(i == 4, {
		newTrack.set_seq_element(26, 1);
	});
	if(i == 5, {
		newTrack.set_seq_element(14, 1);
		newTrack.set_seq_element(15, 1);
		newTrack.set_freqMul(1.1);
	});
	if(i == 6, {
		newTrack.set_seq_element(16, 1);
		newTrack.set_seq_element(20, 1);
		newTrack.set_seq_element(24, 1);
		newTrack.set_seq_element(28, 1);
		newTrack.set_amp(1);
		newTrack.set_roomReverb(0.8);
	});
	if(i == 7, {
		newTrack.set_seq_element(24, 1);
		newTrack.set_seq_element(25, 1);
		newTrack.set_freqMul(0.6);
		newTrack.set_delay(1);
	});

	//return the track object for the array
	newTrack;
});



// ------ GUI MANAGEMENT ------

//tile size for each gui element
z  = 30;

//True if the tracks are playing
~isPlaying = false;

//Selected track index (the first track is selected as default)
~selTrackIndex = 0;

//Selected track button (the first button is selected as default)
~selTrackButton = nil;


//Create main window
w = Window.new("The Sequencer | Amedeo Racanati", Rect(z * 5 ,z * 2, z * 25, z * 21));


//GENERAL GUI ELEMENTS

//this buttons starts the sound generation
~buttonStart = Button(w, Rect(z, z, z * 3, z * 3)).string_("Start").action_({

	//start tracks only if not already started
	if(~isPlaying == false, {
		~tracks.do({ arg item;
			item.start;
		});

		~buttonPause.value = 0; //reset pause button
		~isPlaying = true;
	})
});

//stop tracks button
~buttonStop = Button(w, Rect(z * 4, z, z * 3, z * 3)).string_("Stop").action_({
	~tracks.do({ arg item;
		item.stop;
	});

	~buttonPause.value = 0; //reset pause button
	~isPlaying = false;
});

//pause/resume button
~buttonPause = Button(w, Rect(z * 8, z, z * 3, z * 3)).action_({ |view|

	if(~isPlaying == false,{
		//do nothing if the tracks are not playing
		~buttonPause.value = 0;
	}, {
		//toggle pause/resume
		if(view.value == 0) {
			~tracks.do({ arg item;
				item.resume;
			});
		} {
			~tracks.do({ arg item;
				item.pause;
			});
	   }
	})
}).states_([["Pause", Color.black, Color.white], ["Paused", Color.white, Color.grey]]);


//slider for time speed
~timeString = {"| Time: ".catArgs((GeneralManager.time * 60).trunc(1), " bpm |") };
~timeLbl = StaticText(w, Rect(15 * z, z, 200, z)).string_(~timeString.value);
~timeSlider = Slider(w, Rect(13 * z, z * 3, z * 10, z)).value_((GeneralManager.time - 0.5) / 3).action_({ arg theSlid;

	//The value goes from 0.5 to 3.5 [30 to 210 bpm]
	var paramValue = theSlid.value * 3 + 0.5;
	GeneralManager.time = paramValue;

	~timeLbl.string_(~timeString.value);
});


//Track selection buttons
StaticText(w, Rect(z * 11, z * 5, z * 5, z)).string_("|  TRACKS  |");
~tracks.do({ arg item, index;

	//create the button track
	var buttonTrack = Button(w, Rect((index * 3 + 1) * z, z * 7, z * 2, z * 2)).action_({ |view|

		if(view == ~selTrackButton) {
			//play sound if the button is already selected
			~tracks[index].play_sound;

			//keep the button selected
			view.value = 1;
		} {
			//Change track button selection
			~selTrackButton.value = 0;

			~selTrackButton = view;
			~selTrackIndex = index;

			//Update the track GUI elements
			~setTrackGUIElements.value;
		}
	})
	.states_([[index + 1,Color.grey,Color.white], [index + 1,Color.white,Color.grey]]);

	//Check if the current track is selected
	if (index == ~selTrackIndex) {
		~selTrackButton = buttonTrack;

		//Set the button as selected
		buttonTrack.value = 1;
	};
});



//BEATS GUI ELEMENTS

//Buttons for deciding when to play each beat of each track
~createButtonBeats = {
	~trackBeats = Array.fill(GeneralManager.numberBeats * GeneralManager.numberSubBeats, { arg index;

		//get position of the button
		var x_b,y_b;
		x_b = (1 + (index % 8) + (index % 8 / 4).asInteger) * z;
		y_b = ((index / 8).asInteger * 2 + 13) * z;

		//create the button...
		Button(w, Rect(x_b, y_b, z, z)).action_({ |view|

			//change the activation of the beat for the current track
			~tracks[~selTrackIndex].set_seq_element(index, view.value);
		})
		.states_([[index + 1, Color.grey, Color.white],[index + 1, Color.white, Color.grey]]);
	});
};

//create the buttons
~createButtonBeats.value;

//Button for managing number of beats to play in a loop
StaticText(w, Rect(z * 3, z * 11, z * 4, z)).string_("| Beats |");
Button(w, Rect(z , z * 11, z, z)).action_({ |view|

	//Change number of beats
	GeneralManager.numberBeats = (view.value + 1) * 4;

	//Update each track in order to change the number of beats
	~tracks.do({ arg item;
		item.set_number_beats.value;
	});

	//Delete and create the beat buttons
	~trackBeats.do{|item| item.close;};
	~createButtonBeats.value;

	//Set the buttons activation
	~beatsSetGUI.value;

})
.states_([["4"], ["8"]]) //4 or 8 beats in a loop
.value_((GeneralManager.numberBeats / 4) - 1);


//Function used to set the track beats activations
~beatsSetGUI = {
	(GeneralManager.numberBeats * GeneralManager.numberSubBeats).do({ arg i;
		~trackBeats[i].value = ~tracks[~selTrackIndex].get_seq_element(i).value;
	});
};


//Graphical offset of the GUI elements
~offsetBeat = 1 * z;


//Button for setting all beats "on" for the current track
Button(w, Rect(z * 13, z * 11 + ~offsetBeat, z * 2, z)).string_("All").action_({ |view|
	(GeneralManager.numberBeats * GeneralManager.numberSubBeats).do({ arg i;
		~tracks[~selTrackIndex].set_seq_element(i, 1);
	});
	~beatsSetGUI.value;
});

//Button for setting all beats "off" for the current track
Button(w, Rect(z * 16, z * 11 + ~offsetBeat, z * 2, z)).string_("None").action_({ |view|
	(GeneralManager.numberBeats * GeneralManager.numberSubBeats).do({ arg i;
		~tracks[~selTrackIndex].set_seq_element(i, 0);
	});
	~beatsSetGUI.value;
});


//GUI ELEMENTS FOR TRACK PARAMETERS

//Function used to set all the track parameters GUI
~setTrackGUIElements = {

	~beatsSetGUI.value;
	~ampSetGUI.value(~tracks[~selTrackIndex].get_amp);
	~freqSetGUI.value(~tracks[~selTrackIndex].get_freqMul);
	~muteSetGUI.value(~tracks[~selTrackIndex].get_mute);
	~delaySetGUI.value(~tracks[~selTrackIndex].get_delay);
	~revSetGUI.value(~tracks[~selTrackIndex].get_roomReverb);
};

//Amplitude elements
~ampString = {"Amp: ".catArgs(~ampSlider.value.trunc(0.1)) };
~ampSetGUI = { |amp |

	~ampSlider.value = amp;
	~ampLbl.string_(~ampString.value);
};

~ampLbl = StaticText(w, Rect(z * 13, z * 13 + ~offsetBeat, z * 4, z));
~ampSlider = Slider(w, Rect(z * 13, z * 14 + ~offsetBeat, z * 4, z)).action_({ arg theSlid;

	//The value of the amplitude goes from 0.0 to 1.0
	var paramValue = theSlid.value;
	~tracks[~selTrackIndex].set_amp(paramValue);

	~ampLbl.string_(~ampString.value);
});


//Pitch elements
~freqString = {"Pitch: ".catArgs((~freqSlider.value * 1.5 + 0.5).trunc(0.01), "x") };
~freqSetGUI = { |freq |

	~freqSlider.value = (freq - 0.5) / 1.5;
	~freqLbl.string_(~freqString.value);
};

~freqLbl = StaticText(w, Rect(z * 19, z * 13 + ~offsetBeat, z * 4, z));
~freqSlider = Slider(w, Rect(z * 19, z * 14 + ~offsetBeat, z * 4, z)).action_({ arg theSlid;

	//The pitch goes from 0.5 to 2.0
	var paramValue = theSlid.value * 1.5 + 0.5;
	~tracks[~selTrackIndex].set_freqMul(paramValue);

	~freqLbl.string_(~freqString.value);
});


//Reverb elements
~revString = {"Rev room: ".catArgs(~revSlider.value.trunc(0.1)) };
~revSetGUI = { |rev |

	~revSlider.value = rev;
	~revLbl.string_(~revString.value);
};

~revLbl = StaticText(w, Rect(z * 13, z * 16 + ~offsetBeat, z * 4, z));
~revSlider = Slider(w, Rect(z * 13, z * 17 + ~offsetBeat, z * 4, z)).action_({ arg theSlid;

	//The reverb room goes from 0.0 to 1.0
	var paramValue = theSlid.value;
	~tracks[~selTrackIndex].set_roomReverb(paramValue);

	~revLbl.string_(~revString.value);
});


//Delay elements
~delayString = {"Delay amp: ".catArgs(~delaySlider.value.trunc(0.1)) };
~delaySetGUI = { |delay |

	~delaySlider.value = delay;
	~delayLbl.string_(~delayString.value);
};

~delayLbl = StaticText(w, Rect(z * 19, z * 16 + ~offsetBeat, z * 4, z));
~delaySlider = Slider(w, Rect(z * 19, z * 17 + ~offsetBeat, z * 4, z)).action_({ arg theSlid;

	//The delay amplitude goes from 0.0 to 1.0
	var paramValue = theSlid.value;
	~tracks[~selTrackIndex].set_delay(paramValue);

	~delayLbl.string_(~delayString.value);
});


//Mute elements
~muteSetGUI = { | mute |
	~muteButton.value = mute;
};

~muteButton = Button(w, Rect(z * 21, z * 11 + ~offsetBeat, z * 2, z * 2)).action_({ |view|
	//mute on/off
	~tracks[~selTrackIndex].set_mute(view.value);
})
.states_([["Mute", Color.grey, Color.white],["Muted", Color.white, Color.grey]]);


//set GUI for the current track
~setTrackGUIElements.value;


//On window close, stop each track
w.onClose = {
	~tracks.do({ arg item;
		item.stop;
	});
};

//Showing the window!
w.front;




