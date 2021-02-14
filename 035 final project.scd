(
s.boot;

TempoClock.default.tempo = 2.25;

// Piano SynthDef, taken from https://github.com/viswans83/supercollider-stuff/blob/master/piano.scd
SynthDef(\piano,
	ugenGraphFunc:{ |freq = 261.63, vol = 0.005, gate = 1|
		var ampls = [3.7, 5.4, 1.2, 1.1, 0.95, 0.6, 0.5, 0.65, 0, 0.1, 0.2];
		var freqs = Array.fill(ampls.size, { |i| freq * (i + 1) });
		var waves = Array.fill(ampls.size, { |i| SinOsc.ar(freqs.at(i),mul: ampls.at(i))});
		var mixedwaves = Mix.ar(waves).range(vol * -1,vol);
		var env = Env.perc(0.09,4,curve: -10);
		var final = mixedwaves * EnvGen.ar(env, gate, doneAction: 2);
		Out.ar(0, [final,final]);
}).add;

// FM Rhodes SynthDef, taken from https://sccode.org/1-522
SynthDef(\lead, {
	//FM Rhodes Synthesizer
    |
    // standard meanings
    out = 0, freq = 440, gate = 1, pan = 0, amp = 0.1,
    // all of these range from 0 to 1
    vel = 0.8, modIndex = 0.2, mix = 0.2, lfoSpeed = 0.4, lfoDepth = 0.1
    |
    var env1, env2, env3, env4;
    var osc1, osc2, osc3, osc4, snd;

    lfoSpeed = lfoSpeed * 12;

    freq = freq * 2;

    env1 = EnvGen.ar(Env.adsr(0.001, 1.25, 0.0, 0.04, curve: \lin));
    env2 = EnvGen.ar(Env.adsr(0.001, 1.00, 0.0, 0.04, curve: \lin));
    env3 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));
    env4 = EnvGen.ar(Env.adsr(0.001, 1.50, 0.0, 0.04, curve: \lin));

    osc4 = SinOsc.ar(freq * 0.5) * 2pi * 2 * 0.535887 * modIndex * env4 * vel;
    osc3 = SinOsc.ar(freq, osc4) * env3 * vel;
    osc2 = SinOsc.ar(freq * 15) * 2pi * 0.108819 * env2 * vel;
    osc1 = SinOsc.ar(freq, osc2) * env1 * vel;
    snd = Mix((osc3 * (1 - mix)) + (osc1 * mix));
    snd = snd * (SinOsc.ar(lfoSpeed) * lfoDepth + 1);

    // using the doneAction: 2 on the other envs can create clicks (bc of the linear curve maybe?)
    snd = snd * EnvGen.ar(Env.asr(0, 1, 0.1), gate, doneAction: 2);
    snd = Pan2.ar(snd, pan, amp);

    Out.ar(out, snd);
//By Nathan Ho aka Snappizz
}).add;

// Snare SynthDef, taken from https://sccode.org/1-54H
SynthDef(\snare, {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

// Bass SynthDef, taken from https://gist.github.com/zepadovani/9f6f714a5dec827be2e0ad11a9e4a552
SynthDef(\bass, {arg outbus=0, freq=440, filter=3, amp=1.5,coef=0.5,dur=1,legato=2,mix=0,pan=0;
	var pluck,moog,noteOff,out;
	pluck =	Pluck.ar(PinkNoise.ar,1,0.2,freq.reciprocal,dur*legato,coef);
	moog = MoogFF.ar(pluck, (freq*filter),2);
	out = SelectX.ar(mix,[LPF.ar(pluck,2500),moog]);
	noteOff = DetectSilence.ar(out,doneAction:2);
	Out.ar(outbus, Pan2.ar(out,pan));
}).add;

// Crash Synthdef taken from https://truthindustri.es/supercollider/2019/01/04/supercollider-house-drums.html
SynthDef(\cym, { arg amp = 1;
  var whiteNoise = PinkNoise.ar(
    mul: Env.perc(releaseTime: 4, curve: -7).kr(doneAction: 2));
  Out.ar(0, Pan2.ar(HPF.ar(whiteNoise, freq: 7040)) * 4 * amp);
}).add;

// chord definitions
~c7 = [-12, -5, -2, 0, 4, 7]-2;
~f7 = [-7, -3, 0, 3]-2;
~dm7 = [-3, 0, 2, 5]-2;
~g7 = [-5, -1, 2, 5]-2;

// normal chord progression
~progression1 = Pseq([
	Rest(), ~c7, Rest(), ~c7, Rest(), Rest(),
	Rest(), ~c7, Rest(), ~c7, Rest(), Rest(),
	Rest(), ~f7, Rest(), ~f7, Rest(), Rest(),
	Rest(), ~c7, Rest(), ~c7, Rest(), Rest(),
	Rest(), ~dm7, Rest(), ~dm7, Rest(),
	Rest(), ~g7, Rest(), ~g7, Rest(),
	Rest(), ~c7, Rest(), ~c7, Rest(),
	Rest(), ~g7, Rest(), ~g7, Rest()
], 5);

~dur_progression1 = Pseq([
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5,
	0.6, 0.4, 1.05, 0.45, 1.5,
	0.6, 0.4, 1.05, 0.45, 1.5,
	0.6, 0.4, 1.05, 0.45, 1.5
], 5);

// last chorus
~progression2 = Pseq([
	Rest(), ~c7, Rest(), ~c7, Rest(), Rest(),
	Rest(), ~c7, Rest(), ~c7, Rest(), Rest(),
	Rest(), ~f7, Rest(), ~f7, Rest(), Rest(),
	Rest(), ~c7, Rest(), ~c7, Rest(), Rest(),
	Rest(), ~dm7, Rest(), ~dm7, Rest(),
	Rest(), ~g7, Rest(), ~g7, Rest(),
	Rest(), ~c7, Rest(), ~c7, Rest(),
	Rest(), [-12, -8, -6, -5, -2, 0]
], 1);

~dur_progression2 = Pseq([
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5, 4,
	0.6, 0.4, 1.05, 0.45, 1.5,
	0.6, 0.4, 1.05, 0.45, 1.5,
	0.6, 0.4, 1.05, 0.45, 1.5,
	3, 5
], 1);

// normal bassline
~bassline1 = Pseq([
	0, 4, 7, 9, 10, 9, 7, 4,
	0, 4, 7, 9, 10, 9, 7, 4,
	5, 9, 12, 14, 15, 14, 12, 9,
	0, 4, 7, 5, 4, 2, 1, -3,
	2, 5, 9, 8, 7, 5, 4, 2,
	0, 4, 5, 6, 7, -5, -3, -1
]-26, 5);

~dur_bassline1 = Pseq([Pseq([1],240)]);

// last chorus
~bassline2 = Pseq([
	0, 4, 7, 9, 10, 9, 7, 4,
	0, 4, 7, 9, 10, 9, 7, 4,
	5, 9, 12, 14, 15, 14, 12, 9,
	0, 4, 7, 5, 4, 2, 1, -3,
	2, 5, 9, 8, 7, 9, 10, 11,
	12, 4, 5, 6, 7, 9, 11, 12, 0
]-26, 1);

~dur_bassline2 = Pseq([Pseq([1],40),
	0.65,1.35,1,1,0.65,0.35,0.65,1.35,4],1
);

//melody before solo
~melody1 = Pseq([
	4,0,-3,0,Rest(),3,0,-3,0,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),
	3,0,-3,0,Rest(),3,0,-3,0,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),
	2,-3,2,1,-3,-7,-10,0,-3,-2,-1,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),

	[4,7],0,-3,0,Rest(),[3,6],0,-3,0,Rest(),
	[4,7],0,-3,0,2,0,-3,0,2,0,0,Rest(),
	[3,6],0,-3,0,Rest(),[3,6],0,-3,0,Rest(),
	[4,7],0,-3,0,2,0,-3,0,2,0,0,Rest(),
	2,-3,2,1,-3,-7,-10,0,-3,-2,-1,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),9
]-2, 1);

~dur_melody1 = Pseq([
	0.65,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,1,1,

	1,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,1.35
], 1);

// melody after solo (with ending)
~melody2 = Pseq([
	4,0,-3,0,Rest(),3,0,-3,0,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),
	3,0,-3,0,Rest(),3,0,-3,0,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),
	2,-3,2,1,-3,-7,-10,0,-3,-2,-1,Rest(),
	4,0,-3,0,2,0,-3,0,2,0,0,Rest(),

	[4,7],0,-3,0,Rest(),[3,6],0,-3,0,Rest(),
	[4,7],0,-3,0,2,0,-3,0,2,0,0,Rest(),
	[3,6],0,-3,0,Rest(),[3,6],0,-3,0,Rest(),
	[4,7],0,-3,0,2,0,-3,0,2,0,0,Rest(),
	[2,14],[-3,9],[2,14],[1,13],[-3,9],[-7,5],[-10,2],[0,12],[-3,9],[-2,10],[-1,11],Rest(),
	[4,16],[0,12],[-3,9],[0,12],[2,14],[0,12],[-3,9],[3,15],[0,12],[2,14],[0,12],Rest(),[-12, -5, -2, 0, 4, 6, 7, 14]
]-2, 1);

~dur_melody2 = Pseq([
	0.65,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,1,1,

	1,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,1,0.65,1,1,0.35,1,0.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1.65,
	1,1,0.35,0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1,5.35
], 1);

~lick1 = Pseq([
	0,2,0,Rest(),0,Rest(),
	5,7,9,7,Rest()
]-2, 1);
~dur_lick1 = Pseq([
	0.65,0.35,0.65,0.35,1,1,
	0.65,0.35,0.65,0.35,2
], 1);

~lick2 = Pseq([
	9,7,4,2,
	4,0,-3,-4,-5,2
]-2, 1);
~dur_lick2 = Pseq([
	0.65,1.35,0.65,1.35,
	0.65,0.35,0.65,0.35,0.65,1.35
], 1);

~lick3 = Pseq([
	Rest(),3,4,0,3,4,0,
]-2, 1);
~dur_lick3 = Pseq([
	2,0.1,0.9,1,0.1,0.9,3
], 1);

~lick4 = Pseq([  //iiVI
	2,5,9,4,7,11,5,9,12,7,11,14,
	16,17,16,14,12,11,9,8,7,4,2,Rest()
]-2, 1);
~dur_lick4 = Pseq([
	0.33,0.33,0.34,0.33,0.33,0.34,0.33,0.33,0.34,0.33,0.33,0.34,
	0.65,0.175,0.175,0.65,0.35,0.65,0.35,0.65,1.35,0.65,1.35,5
], 1);

~lick5 = Pseq([
	7,6,5,7,4,4,Rest()
]-2, 1);
~dur_lick5 = Pseq([
	1.65,0.35,1.65,0.35,1,2,1
], 1);

~lick6 = Pseq([  //iiVI
	5,2,4,2,7,6,5,0,
	-3,-7,4,0,3,-1,-3,-5,
	-8,-5,-1,2,-1,0,4,Rest()
]+10, 1);
~dur_lick6 = Pseq([
	0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,
	0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,
	0.65,0.175,0.175,0.65,0.35,0.65,0.35,5
], 1);

~lick7 = Pseq([  //iiVI
	Rest(),-3,Rest(),0,Rest(),-3,Rest(),-7,
	4,5,4,2,0,-4,-5,-7,-8,Rest()
]+10, 1);
~dur_lick7 = Pseq([
	0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,
	0.65,0.35,0.65,0.35,0.65,0.35,0.65,0.35,1,7
], 1);

~licks = [~lick1,~lick2,~lick3,~lick5];
~dur_licks = [~dur_lick1,~dur_lick2,~dur_lick3,~dur_lick5];
~iiVIs = [~lick4,~lick6,~lick7];
~dur_iiVIs = [~dur_lick4,~dur_lick6,~dur_lick7];

~num1 = ~licks.size.rand.postln;
~num2 = ~licks.size.rand.postln;
~num3 = ~iiVIs.size.rand.postln;
~num4 = ~licks.size.rand.postln;
~num5 = ~licks.size.rand.postln;
~num6 = ~iiVIs.size.rand.postln;

// random note function
f = { arg chord, durs;
	if (chord == 1, {
		~notes = Array.fill(durs.size, { [-2,0,2,3,5,7,8,Rest()].wchoose([0.2,0.05,0.15,0.05,0.2,0.05,0.05,0.25]) });
	},
	{
		~notes = Array.fill(durs.size, { [3,5,7,8,10,12,13,Rest()].wchoose([0.15,0.05,0.2,0.05,0.2,0.05,0.05,0.25]) });
	});
	~notes;
};

// random durs for function above
~dur_randomnotes1 = Array.fill(8, { [[0.33,0.33,0.34],[0.65,0.35],[1]].wchoose([0.05, 0.45, 0.5]) }).flat;
~randomnotes1 = f.value(1,~dur_randomnotes1);
~dur_randomnotes2 = Array.fill(8, { [[0.33,0.33,0.34],[0.65,0.35],[1]].wchoose([0.05, 0.45, 0.5]) }).flat;
~randomnotes2 = f.value(4,~dur_randomnotes2);
~dur_randomnotes3 = Array.fill(8, { [[0.33,0.33,0.34],[0.65,0.35],[1]].wchoose([0.05, 0.45, 0.5]) }).flat;
~randomnotes3 = f.value(1,~dur_randomnotes3);
~dur_randomnotes4 = Array.fill(8, { [[0.33,0.33,0.34],[0.65,0.35],[1]].wchoose([0.05, 0.45, 0.5]) }).flat;
~randomnotes4 = f.value(4,~dur_randomnotes4);

// compiling random solo
~solo = [
	~licks[~num1],Pseq(~randomnotes1, 1),~licks[~num2]+5,Pseq(~randomnotes2, 1),~iiVIs[~num3],
	~licks[~num4],Pseq(~randomnotes3, 1),~licks[~num5]+5,Pseq(~randomnotes4, 1),~iiVIs[~num6]
];
~dur_solo = [
	~dur_licks[~num1],Pseq(~dur_randomnotes1, 1),~dur_licks[~num2],Pseq(~dur_randomnotes2, 1),~dur_iiVIs[~num3],
	~dur_licks[~num4],Pseq(~dur_randomnotes3, 1),~dur_licks[~num5],Pseq(~dur_randomnotes4, 1),~dur_iiVIs[~num6]
];
)

//--------------------------------------------------------------------------------------------------------

(
p = Pbind(
	\instrument, \piano,
	\dur, Pseq([~dur_progression1,~dur_progression2],1),
	\note, Pseq([~progression1,~progression2],1)

);

b = Pbind(
	\instrument, \bass,
	\dur, Pseq([~dur_bassline1,~dur_bassline2],1),
	\note, Pseq([~bassline1,~bassline2],1),
	\sustain, 1.5,
	\amp, 2
);

c = Pbind(
	\instrument, \cym,
	\dur, Pseq([1, 0.65, 0.35], 144), // one chorus is 24
);

d = Pbind(
	\instrument, \snare,
	\dur, Pseq([Rest(7.65), 0.35, Rest(6.65), 0.35, Rest(0.65), 0.35], 18), // one chorus is 3
);

m = Pbind(
	\instrument, \lead,
	\dur, Pseq([~dur_melody1,Pseq(~dur_solo, 1),~dur_melody2],1),
	\note, Pseq([~melody1,Pseq(~solo, 1),~melody2],1),
	\amp, 0.55
);

Ppar([p,b,c,d,m]).play;
)

//--------------------------------------------------------------------------------------------------------

// lick tester
(
Pbind(
	\instrument, \lead,
	\dur, ~dur_lick6,
	\note, ~lick6
).play;
)

//solo only (manually stop piano and bass after 2 choruses)
(
p = Pbind(
	\instrument, \piano,
	\dur, Pseq([~dur_progression1],1),
	\note, Pseq([~progression1],1)
);

b = Pbind(
	\instrument, \bass,
	\dur, Pseq([~dur_bassline1],1),
	\note, Pseq([~bassline1],1),
	\sustain, 1.5,
	\amp, 2
);

c = Pbind(
	\instrument, \cym,
	\dur, Pseq([1, 0.65, 0.35], 48), // one chorus is 24
);

d = Pbind(
	\instrument, \snare,
	\dur, Pseq([Rest(7.65), 0.35, Rest(6.65), 0.35, Rest(0.65), 0.35], 6) // one chorus is 3
);

m = Pbind(
	\instrument, \lead,
	\dur, Pseq([Pseq(~dur_solo, 1)],1),
	\note, Pseq([Pseq(~solo, 1)],1),
	\amp, 0.55
);

Ppar([p,b,c,d,m]).play;
)

s.makeGui;