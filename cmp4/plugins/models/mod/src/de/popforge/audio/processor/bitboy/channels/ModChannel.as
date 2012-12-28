package de.popforge.audio.processor.bitboy.channels
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.bitboy.BitBoy;
	import de.popforge.audio.processor.bitboy.formats.TriggerBase;
	import de.popforge.audio.processor.bitboy.formats.mod.ModSample;
	import de.popforge.audio.processor.bitboy.formats.mod.ModTrigger;
	import de.popforge.math.rint;
	
	public class ModChannel extends ChannelBase
	{
		static private const ARPEGGIO: int = 0x0;
		static private const PORTAMENTO_UP: int = 0x1;
		static private const PORTAMENTO_DN: int = 0x2;
		static private const TONE_PORTAMENTO: int = 0x3;
		static private const VIBRATO: int = 0x4;
		static private const TONE_PORTAMENTO_VOLUME_SLIDE: int = 0x5;
		static private const VIBRATO_VOLUME_SLIDE: int = 0x6;
		static private const TREMOLO: int = 0x7;
		static private const SET_PANNING: int = 0x8;
		static private const SAMPLE_OFFSET: int = 0x9;
		static private const VOLUME_SLIDE: int = 0xa;
		static private const POSITION_JUMP: int = 0xb;
		static private const SET_VOLUME: int = 0xc;
		static private const PATTERN_BREAK: int = 0xd;
		static private const EXTENDED_EFFECTS: int = 0xe;
		static private const SET_SPEED: int = 0xf;
		
		static private const TONE_TABLE: Array =
		[
			856,808,762,720,678,640,604,570,538,508,480,453,
			428,404,381,360,339,320,302,285,269,254,240,226,
			214,202,190,180,170,160,151,143,135,127,120,113
		];
		
		static private const SINE_TABLE: Array =
		[
			0,24,49,74,97,120,141,161,
	 		180,197,212,224,235,244,250,253,
	 		255,253,250,244,235,224,212,197,
	 		180,161,141,120,97,74,49,24,
			0,-24,-49,-74,-97,-120,-141,-161,
	 		-180,-197,-212,-224,-235,-244,-250,-253,
	 		-255,-253,-250,-244,-235,-224,-212,-197,
	 		-180,-161,-141,-120,-97,-74,-49,-24
		];
		
		private var wave: Array;
		private var wavePhase: Number;
		private var repeatStart: int;
		private var repeatLength: int;
		private var firstRun: Boolean;
		private var volume: int;
		
		private var volumeSlide: int;
		private var portamentoSpeed: int;
		private var tonePortamentoSpeed: int = 0;
		private var tonePortamentoPeriod: int;
		private var vibratoSpeed: int;
		private var vibratoDepth: int;
		private var vibratoPosition: int;
		private var vibratoOffset: int;
		private var appegio: Appegio;
		
		//-- EXT EFFECT
		private var patternfirstRun: Boolean;
		private var patternfirstRunCount: int;
		private var patternfirstRunPosition: int;
		
		public function ModChannel( bitboy: BitBoy, id: int, pan: Number )
		{
			super( bitboy, id, pan );
		}
		
		public override function setMute( value: Boolean ): void
		{
			mute = value;
		}
		
		public override function reset(): void
		{
			wave = null;
			wavePhase = 0.0;
			repeatStart = 0;
			repeatLength = 0;
			firstRun = false;
			volume = 0;
			trigger = null;
			
			patternfirstRun = false;
			patternfirstRunCount = 0;
			patternfirstRunPosition = 0;
			
			volumeSlide = 0;
			portamentoSpeed = 0;
			tonePortamentoSpeed = 0;
			tonePortamentoPeriod = 0;
			vibratoSpeed = 0.0;
			vibratoDepth = 0.0;
			vibratoPosition = 0.0;
			vibratoOffset = 0.0;
			
			effect = 0;
			effectParam = 0;
		}
		
		public override function onTrigger( trigger: TriggerBase ): void
		{
			this.trigger = trigger;
			
			updateWave();
			
			if( trigger.effect == TONE_PORTAMENTO  )
			{
				initTonePortamento();
			}
			else if( trigger.period > 0 )
			{
				period = trigger.period;
				tone = TONE_TABLE.indexOf( period );
				tonePortamentoPeriod = period; // fix for 'delicate.mod'
				appegio = null;
			}
			
			initEffect();
		}
		
		public override function onTick( tick: int ): void
		{
			switch( effect )
			{
				case ARPEGGIO:
				
					updateApeggio( tick % 3 );
					break;
				
				case PORTAMENTO_UP:
				case PORTAMENTO_DN:
				
					updatePortamento();
					break;
				
				case TONE_PORTAMENTO:
				
					updateTonePortamento();
					break;
					
				case TONE_PORTAMENTO_VOLUME_SLIDE:
					
					updateTonePortamento();
					updateVolumeSlide();
					break;
				
				case VOLUME_SLIDE:
				
					updateVolumeSlide();
					break;
				
				case VIBRATO:
					
					updateVibrato();
					break;
				
				case VIBRATO_VOLUME_SLIDE:

					updateVibrato();
					updateVolumeSlide();
					break;
				
				case EXTENDED_EFFECTS:

					var extEffect: int = effectParam >> 4;
					var extParam: int = effectParam & 0xf;
				
					switch ( extEffect )
					{
						case 0x9: //-- retrigger note
							if ( tick % extParam == 0 )
								wavePhase = 0.0;
							break;
						
						case 0xc: //-- cut note
							wave = null;
							break;
					}

					break;
			}
		}
		
		public override function processAudioAdd( samples: Array, numSamples: int, pointerIndex: int ): void
		{
			if( wave == null || mute )
				return;
			
			var sample: Sample;
			
			var len: int = wave.length;
			
			var volT: Number = ( volume / 64 ) * bitboy.parameterGain.getValue();
			var volL: Number = volT * ( 1 - pan ) / 2;
			var volR: Number = volT * ( pan + 1 ) / 2;
			
			var waveSpeed: Number = ( ( 7159090.5 / 2 ) / bitboy.getRate() ) / ( period + vibratoOffset ); // NTSC machine clock (Magic Number)
			
			var phaseInt: int;
			var alpha: Number;
			var amp: Number;
			
			for( var i: int = 0 ; i < numSamples ; ++i )
			{
				if( firstRun )
				{
					if( wavePhase >= len ) // first run complete
					{
						if( repeatLength == 0 ) // stop channel
						{
							wave = null;
							return;
						}
						else
						{
							//-- truncate
							wave = wave.slice( repeatStart, repeatStart + repeatLength );
							len = wave.length;
							wavePhase %= len;
							firstRun = false;
						}
					}
				}
				else
					wavePhase %= len;
				
				//-- LINEAR INTERPOLATION
				//
				phaseInt = wavePhase;
				alpha = wavePhase - phaseInt;

				amp = wave[ phaseInt ] * ( 1 - alpha );
				if( ++phaseInt == len ) phaseInt = 0;
				amp += wave[ phaseInt ] * alpha;
				
				sample = samples[int( i + pointerIndex )];
				sample.left += amp * volL;
				sample.right += amp * volR;
				
				wavePhase += waveSpeed;
			}
		}

		private function initEffect(): void
		{
			if( trigger == null )
				return;

			effect = trigger.effect;
			effectParam = trigger.effectParam;

			if( effect != VIBRATO && effect != VIBRATO_VOLUME_SLIDE )
			{
				vibratoOffset = 0;
			}

			switch( effect )
			{
				case ARPEGGIO:
				
					if( effectParam > 0 )
					{
						initApeggio();
					}
					else
					{
						//-- no effect here, reset some values
						volumeSlide = 0;
					}
					break;
				
				case PORTAMENTO_UP:
				
					initPortamento( -effectParam );
					break;
				
				case PORTAMENTO_DN:
				
					initPortamento( effectParam );
					break;
					
				case TONE_PORTAMENTO:
					break;
				
				case VIBRATO:
					if ( ModTrigger( trigger ).modSample != null )
						volume = ModTrigger( trigger ).modSample.volume;
					initVibrato();
					break;

				case VIBRATO_VOLUME_SLIDE:

					/*This is a combination of Vibrato (4xy), and volume slide (Axy).
					The parameter does not affect the vibrato, only the volume.
					If no parameter use the vibrato parameters used for that channel.*/
					initVolumeSlide();
					break;
			
				case EXTENDED_EFFECTS:
				
					var extEffect: int = effectParam >> 4;
					var extParam: int = effectParam & 0xf;
				
					switch ( extEffect )
					{
						case 0x6: //-- pattern firstRun
							
								if( extParam == 0 )
								{
									patternfirstRunPosition = bitboy.getRowIndex() - 1;
								}
								else
								{
									if( !patternfirstRun )
									{
										patternfirstRunCount = extParam;
										patternfirstRun = true;
									}
									
									if( --patternfirstRunCount >= 0 )
									{
										bitboy.setRowIndex( patternfirstRunPosition );
									}
									else
									{
										patternfirstRun = false;
									}
								}
								
								break;
						
						case 0x9: //-- retrigger note

							wavePhase = .0;
							break;
						
						case 0xc: //-- cut note

							if( extParam == 0 )
								wave = null;
							break;
						
						default:
				
							trace( 'extended effect: ' + extEffect + ' is not defined.' );
							break;
					}

					break;
				
				case TONE_PORTAMENTO_VOLUME_SLIDE:
				case VOLUME_SLIDE:
				
					initVolumeSlide();
					break;
				
				case SET_VOLUME:
				
					volumeSlide = 0;
					volume = effectParam;
					break;

				case POSITION_JUMP:
				
					bitboy.patternJump( effectParam );
					break;

				case PATTERN_BREAK:

					bitboy.patternBreak( parseInt( effectParam.toString( 16 ) ) );
					break;

				case SET_SPEED:
				
					if( effectParam > 32 )
						bitboy.setBPM( effectParam );
					else
						bitboy.setSpeed( effectParam );
					break;
				
				default:
				
					trace( 'effect: ' + effect + ' is not defined.' );
					break;
			}
		}
		
		private function updateWave(): void
		{
			if( trigger == null )
				return;

			var modSample: ModSample = ModTrigger( trigger ).modSample;
			
			if( modSample == null || trigger.period <= 0 )
				return;

			wave = modSample.wave;
			wavePhase = 0.0;
			repeatStart = modSample.repeatStart;
			repeatLength = modSample.repeatLength;
			volume = modSample.volume;
			firstRun = true;
		}
		
		private function initApeggio(): void
		{
			appegio = new Appegio
			(
				period,
				TONE_TABLE[ tone + ( effectParam >> 4 ) ],
				TONE_TABLE[ tone + ( effectParam & 0xf ) ]
			);
		}
		
		private function updateApeggio( index: int ): void
		{
			if( effectParam > 0 )
			{
				if( index == 1 )
					period = appegio.p2;
				else if( index == 2 )
					period = appegio.p1;
			}
		}
		
		private function initVolumeSlide(): void
		{
			if( ModTrigger( trigger ).modSample )
				volume = ModTrigger( trigger ).modSample.volume;
			volumeSlide =  effectParam >> 4;
			volumeSlide -= effectParam & 0xf;
		}
		
		private function updateVolumeSlide(): void
		{
			var newVolume: int = volume + volumeSlide;

			if( newVolume < 0 ) newVolume = 0;
			else if( newVolume > 64 ) newVolume = 64;
			
			volume = newVolume;
		}
		
		private function initTonePortamento(): void
		{
			if( trigger.effectParam > 0 )
			{
				tonePortamentoSpeed = trigger.effectParam;
				if( trigger.period > 0 )
				{
					tonePortamentoPeriod = trigger.period;
				}
			}
		}
		
		private function updateTonePortamento(): void
		{
			if( period > tonePortamentoPeriod )
			{
				period -= tonePortamentoSpeed;
				if( period < tonePortamentoPeriod )
					period = tonePortamentoPeriod;
			}
			else if( period < tonePortamentoPeriod )
			{
				period += tonePortamentoSpeed;
				if( period > tonePortamentoPeriod )
					period = tonePortamentoPeriod;
			}
		}
		
		private function initPortamento( portamentoSpeed: int ): void
		{
			this.portamentoSpeed = portamentoSpeed;
		}
		
		private function updatePortamento(): void
		{
			period += portamentoSpeed;
		}
		
		private function initVibrato(): void
		{
			if( effectParam > 0 )
			{
				vibratoSpeed = effectParam >> 4;
				vibratoDepth = effectParam & 0xf;
				vibratoPosition = 0;
			}
		}
		
		private function updateVibrato(): void
		{
			vibratoPosition += vibratoSpeed;
			
			vibratoOffset = rint( SINE_TABLE[ vibratoPosition % SINE_TABLE.length ] * vibratoDepth / 128 );
		}
	}
}

class Appegio
{
	public var p0: int;
	public var p1: int;
	public var p2: int;
	
	public function Appegio( p0: int, p1: int, p2: int )
	{
		this.p0 = p0;
		this.p1 = p1;
		this.p2 = p2;
	}
}