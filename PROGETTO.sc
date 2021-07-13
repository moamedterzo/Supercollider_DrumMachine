//This is a class used for managing "the Sequencer" main parameters
GeneralManager {

	//Number of available tracks
	const numberTracks = 8;

	//Beats per second
	classvar time = 1;

	//Number of total beats to play in a loop
	classvar numberBeats = 8;

	//Number of notes for each beat
	const numberSubBeats = 4; //sixteenth note

	*time{
		^time
	}

	*time_{ | newValue |
        time = newValue;
    }

	*numberSubBeats{
		^numberSubBeats
	}

	*numberBeats{
		^numberBeats
	}
	*numberBeats_{ |v|
		numberBeats = v;
	}

	*numberTracks{
		^numberTracks
	}

	*get_wait_time{
		//returns the time to wait for the next sound
		^(1 / GeneralManager.time / GeneralManager.numberSubBeats)
	}
}

//Class used to represent a single track
MyTrack {

	//Index of the track
	var numberTrack;

	//Buffer of the sound to be played
	var fileSample;


	//Array used to store the beats activation
	var seqArray;

	//Sequence used to get the next beat activation
	var seqPlay;

	//Bus used for the delay
	var busDelay;

	//Parameters for the sound, in order: amplitude, mute/not mute, pitch, delay, reverb
	var amp = 0.5;
	var mute = 0;
	var freqMul = 1;
	var delayAmp = 0;
	var roomReverb = 0.1;

	//Task used to schedule new sound beats
	var task;

	play_sound{
		//Create new synth and play it!
		Synth.new("basicTrack", [\bufnum, fileSample, \outDelay, busDelay, \amp, amp, \freqMul, freqMul, \roomReverb, roomReverb, \delayAmp, delayAmp]);
	}

	init{| server, pathFile, nTrack, bsDelay |

		numberTrack = nTrack;
		busDelay = bsDelay;

		//read file sample from file and store to a buffer
		fileSample = Buffer.read(server, pathFile);

		//create sequence for the beats activation
		seqArray = Array.fill(GeneralManager.numberBeats * GeneralManager.numberSubBeats, 0);


		//task used for sounds scheduling
		task = Task({
			inf.do({

				//get wait time
				var waitTime = GeneralManager.get_wait_time;

				//if the beat is active and the track is not muted...
				if(seqPlay.next == 1 && mute == 0, {

					//... schedule event
					SystemClock.sched(waitTime,{
						this.play_sound;
					});
				});

				//wait for the next iteration
				waitTime.wait;
			});
		});
	}

	//This method must be called when the number of beats in a loop is changed
	set_number_beats{

		//seqArray will contain the exact number of beats

		//remove extra-beats
		seqArray.takeThese({ arg item, index; index >= (GeneralManager.numberBeats * GeneralManager.numberSubBeats); });

		//add missing beats
		seqArray.addAll(Array.fill(GeneralManager.numberBeats * GeneralManager.numberSubBeats - seqArray.size, 0));
	}

	start {
		//create new sequence (restart to first element)
		seqPlay = Pseq(seqArray, inf).asStream;

		//start the task
		task.play;
	}

	pause{
		//pause the task
		task.pause;
	}

	resume{
		//resume the task
		task.resume;
	}

	stop{
		//stop the task
		task.stop;
	}


	//various getters and setters
	set_amp{| new_amp|
		amp = new_amp;
	}
	get_amp{
		^amp
	}

	set_mute{| new_mute|
		mute = new_mute;
	}
	get_mute{
		^mute
	}

	set_freqMul{| new_freqMul|
		freqMul = new_freqMul;
	}
	get_freqMul{
		^freqMul
	}

	set_roomReverb{| new_roomReverb|
		roomReverb = new_roomReverb;
	}
	get_roomReverb{
		^roomReverb
	}

	set_delay{| new_delay|
		delayAmp = new_delay;
	}
	get_delay{
		^delayAmp
	}

	set_seq_element{ | index, value|
		seqArray[index] = value;
	}
	get_seq_element{ | index|
		^seqArray[index];
	}
	//end of getters and setters
}

