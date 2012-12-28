package de.popforge.audio.processor.bitboy.formats
{
	import de.popforge.audio.processor.bitboy.BitBoy;
	import flash.utils.ByteArray;
	
	/**
	 * The FormatBase class is an abstract descriptor for formats that are read by a tracker.
	 * Usually those formats are MOD, XM, IT or S3M.
	 * 
	 * @author Joa Ebert
	 */	
	public class FormatBase
	{
		/**
		 * An Array of patterns.
		 * 
		 * A pattern is defined as an Array of rows. Each row is an Array of
		 * <code>numChannels</code> channels while each channel holds one
		 * trigger object.
		 */		
		protected var patterns: Array;
		
		/**
		 * An Array of pattern identifiers.
		 * 
		 * Each identifier is a uint. The <code>sequence</code> variable
		 * holds the order in which the patterns are played.
		 */
		protected var sequence: Array;
		
		/**
		 * The length of the <code>sequence</code> property.
		 * 
		 * Since <code>length</code> property stores the length of the <code>sequence</code>
		 * property it is important to keep in mind that the length given in number of patterns instead
		 * of seconds or milliseconds for instance.
		 */
		public var length: uint;
		
		/**
		 * The title of the current module.
		 */
		public var title: String;
		
		/**
		 * The number of channels.
		 */
		public var numChannels: uint;
		
		/**
		 * The length of the <code>patterns</code> property.
		 */
		public var numPatterns: uint;
		
		/**
		 * The credits of a song.
		 * 
		 * In MOD files the samples are used for the credits while in most
		 * of the XM files the instruments hold this information.
		 */
		public var credits: Array;
		
		/**
		* Default restart position in sequence once song is completed.
		*/		
		public var restartPosition: uint;
		
		/**
		 * Default bpm.
		 */		
		public var defaultBpm: uint;
		
		/**
		* Default speed.
		*/		
		public var defaultSpeed: uint;
		
		/**
		 * Creates a new FormatBase object.
		 * 
		 * Each property of the FormatBase will be set to its default value.
		 */	
		public function FormatBase( stream: ByteArray )
		{
			patterns = [];
			sequence = [];

			length = 0;		
			title = '';		

			numChannels = 0;
			numPatterns = 0;
			
			credits = [];
		}
		
		protected function parse( stream: ByteArray ): void 
		{
			
		}
		
		/**
		 * Finds the trigger object at given indices.
		 * 
		 * @param patternIndex The index of the pattern.
		 * @param rowIndex The index of the row.
		 * @param channelIndex The index of the channel.
		 * 
		 * @return The trigger at the given position.
		 */		
		public function getTriggerAt( patternIndex: uint, rowIndex: uint, channelIndex: uint ): TriggerBase
		{
			return TriggerBase( patterns[ patternIndex ][ rowIndex ][ channelIndex ] );
		}
		
		/**
		 * Finds the pattern index at given position in the sequence.
		 * 
		 * @param sequenceIndex The index in the sequence table.
		 * @return The pattern index at given position in the sequence.
		 */		
		public function getSequenceAt( sequenceIndex: uint ): uint
		{
			return uint( sequence[ sequenceIndex ] );
		}
		
		/**
		 * Returns the number of rows in the pattern at given index.
		 * 
		 * @param patternIndex The index of the pattern.
		 * @return Number of rows.
		 */		
		public function getPatternLength( patternIndex: uint ): uint
		{
			return ( patterns[ patternIndex ] as Array ).length;
		}
		
		/**
		 * Creates and reurns an array of channels.
		 * 
		 * @return An array of channels.
		 */		
		public function getChannels( bitboy: BitBoy ): Array
		{
			return null;
		}
		
		/**
		 * Creates and returns the string representation of the object.
		 * @return The string represenation of the object.
		 */		
		public function toString(): String
		{
			return '[FormatBase]';
		}
	}
}