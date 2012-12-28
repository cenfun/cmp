package de.popforge.audio.processor.bitboy {
	
	import de.popforge.audio.output.Audio;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.audio.processor.bitboy.channels.ChannelBase;
	import de.popforge.audio.processor.bitboy.formats.FormatBase;
	import de.popforge.audio.processor.bitboy.formats.TriggerBase;
	import de.popforge.parameter.MappingBoolean;
	import de.popforge.parameter.MappingIntLinear;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;

	import flash.utils.getTimer;

	public class BitBoy implements IAudioProcessor {
		static private const RATIO: Number = 2.5;
		
		public const parameterGain: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .75 );
		public const parameterMute: Parameter = new Parameter( new MappingBoolean(), false );
		public const parameterPause: Parameter = new Parameter( new MappingBoolean(), false );
		public const parameterChannel: Parameter = new Parameter( new MappingIntLinear( 0, 0xf ), 0xf );
		//public const parameterLoopMode: Parameter = new Parameter( new MappingBoolean(), false );
				
		public var format: FormatBase;
		public var channels: Array;
		public var length: int;
		public var rate: Number;
		public var bpm: Number;
		public var speed: int;

		public var tick: int;
		public var rowIndex: int;
		public var patIndex: int;
		
		public var incrementPatIndex: Boolean;

		public var samplesPerTick: int;		
		public var rest: int = 0;
		
		public var complete: Boolean;
		public var lastRow: Boolean;
		public var idle: Boolean;
		public var loop: Boolean;
		
		/**
		 * Create a Bitboy instance
		 */
		public function BitBoy() {
		}
		
		/**
		 * Returns true is lastRow
		 */
		public function isIdle(): Boolean {
			return idle;
		}
		
		/**
		 * set the mod format
		 */
		public function setFormat( format: FormatBase ): void {
			this.format = format;
			
			init();
			
			length = computeLengthInSeconds();
			
			reset();
		}
		
		/**
		 * returns song length in seconds. returns -1 if the loop is looped
		 */
		public function getLengthSeconds(): int {
			return length;
		}
		
		/**
		 * process audio stream
		 * 
		 * param samples The samples Array to be filled
		 */
		public function processAudio( samples: Array ): void {
			if( complete ) {
				idle = true;
				return;
			}
			
			var channel: ChannelBase;
			
			var pointer: int = 0;
			var available: int = samples.length;
			
			if( 0 < rest ) {
				for each( channel in channels ) {
					channel.processAudioAdd( samples, rest, pointer );
				}
				pointer += rest;
				available -= rest;
			}
			
			nextTick();
			
			while( available >= samplesPerTick ) {
				for each( channel in channels ) {
					channel.processAudioAdd( samples, samplesPerTick, pointer );
				}
				pointer += samplesPerTick;
				available -= samplesPerTick;
				
				if( 0 < available ) {
					nextTick();
				}
			}
			
			if( 0 < available ) {
				for each( channel in channels ) {
					channel.processAudioAdd( samples, available, pointer );
				}
			}

			rest = samplesPerTick - available;
		}
		
		public function reset(): void {
			rate = Audio.RATE44100;
			speed = format.defaultSpeed;
			tick = 0;

			setBPM( format.defaultBpm );

			rowIndex = 0;
			patIndex = 0;
			
			complete = false;
			lastRow = false;
			idle = false;
			loop = false;
			incrementPatIndex = false;
			
			for each( var channel: ChannelBase in channels ) {
				channel.reset();
			}
		}
		
		public function setBPM( bpm: int ): void {
			samplesPerTick = rate * RATIO / bpm;
			
			this.bpm = bpm;
		}
		
		public function setSpeed( speed: int ): void {
			this.speed = speed;
		}
		
		public function setRowIndex( rowIndex: int ): void {
			this.rowIndex = rowIndex;
		}
		
		public function getRowIndex(): int {
			return rowIndex;
		}
		
		public function getRate(): Number {
			return rate;
		}
		
		public function getPosition():Number {
			var pos:Number = 0;
			var rows:Number = getPatternLength();
			if (rows && format.length) {
				pos = (patIndex + rowIndex / rows) / format.length * length;
			}
			return pos;
		}
		
		public function setPosition(val:Number):void {
			
			var p:Number = val * format.length;
			
			var pi:int = Math.floor(p);
			
			this.patIndex = pi;
			
			var rows:Number = getPatternLength();
			var ri:int = Math.floor((p - pi) * rows);
			
			setRowIndex( ri );
			
		}
		
		
		public function patternJump( patIndex: int ): void {
			if( patIndex <= this.patIndex ) {
				loop = true;
			}
			this.patIndex = patIndex;
			
			setRowIndex( 0 );
		}
		
		public function patternBreak( rowIndex: int ): void {
			setRowIndex( rowIndex );
			
			incrementPatIndex = true;
		}

		private function init(): void {
			channels = format.getChannels( this );
		}
		
		private function nextTick(): void {
			if( --tick <= 0 ) {
				if( lastRow ) {
					complete = true;
				} else {
					rowComplete();
					tick = speed;
				}
			} else {
				for each( var channel: ChannelBase in channels ) {
					channel.onTick( tick );
				}
			}
		}
		
		private function rowComplete(): void {
			var channel: ChannelBase;
			//-- sync all parameter changes for smooth cuttings
			//
			
			if( !parameterPause.getValue() ) {
				var mutes: int;
				
				if( parameterMute.getValue() ) {
					mutes = 0;
				} else {
					mutes = parameterChannel.getValue();
				}
				for ( var i: int = 0; i < format.numChannels; ++i ) {
					channel = channels[i];
					
					channel.setMute( ( mutes & ( 1 << i ) ) == 0 );
				}
				
				nextRow();
			} else {
				for each ( channel in channels ) {
					channel.setMute( true );
				}
			}		
		}
		
		private function nextRow(): void {
			var channel: ChannelBase;
			var channelIndex: int;
			
			var currentPatIndex: int = patIndex;
			var currentRowIndex: int = rowIndex++;
			
			incrementPatIndex = false;
			
			for ( channelIndex = 0; channelIndex < format.numChannels; ++channelIndex ) {
				channel = channels[ channelIndex ];
				channel.onTrigger( TriggerBase( format.getTriggerAt( format.getSequenceAt( currentPatIndex ), currentRowIndex, channelIndex ) ) );
			}
			
			if( incrementPatIndex ) {
				nextPattern();
			} else if ( rowIndex == getPatternLength()) {
				rowIndex = 0;
				nextPattern();
			}
		}
		
		private function nextPattern(): void {
			if( ++patIndex == format.length ) {
				//if( parameterLoopMode.getValue() ) {
					//patIndex = format.restartPosition;
				//} else {
					lastRow = true;
				//}
			}
		}
		
		public function getPatternLength():Number {
			return format.getPatternLength( format.getSequenceAt( patIndex ) );
		}
		
		private function computeLengthInSeconds(): int {
			reset();
			
			var channel: ChannelBase;
			var channelIndex: int;
			
			var currentPatIndex: int;
			var currentRowIndex: int;
			
			var samplesTotal: Number = 0;
			
			var ms: uint = getTimer();
			// just be save
			while( getTimer() - ms < 1000 ) {
				if( lastRow ) {
					break;
				}
				currentPatIndex = patIndex;
				currentRowIndex = rowIndex++;
				incrementPatIndex = false;
				
				for ( channelIndex = 0; channelIndex < format.numChannels; ++channelIndex )	{
					channel = channels[ channelIndex ];
					channel.onTrigger( TriggerBase( format.getTriggerAt( format.getSequenceAt( currentPatIndex ), currentRowIndex, channelIndex ) ) );
				}
				
				if ( loop ) {
					return -1;
				}
				
				if ( incrementPatIndex ) {
					nextPattern();
				}
				
				if ( rowIndex == getPatternLength() ) {
					rowIndex = 0;
					nextPattern();
				}
				
				samplesTotal += samplesPerTick * speed;
			}
			
			return samplesTotal / rate;
		}
	}
}