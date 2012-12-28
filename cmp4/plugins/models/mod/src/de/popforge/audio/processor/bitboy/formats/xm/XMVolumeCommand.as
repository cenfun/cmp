package de.popforge.audio.processor.bitboy.formats.xm
{
	public final class XMVolumeCommand
	{
		public static const NO_COMMAND: uint = 0x00;
		public static const VOLUME: uint = 0x01;
		
		public static const VOLUME_SLIDE_DOWN: uint = 0x60;
		public static const VOLUME_SLIDE_UP: uint = 0x70;
		public static const VOLUME_FINE_DOWN: uint = 0x80;
		public static const VOLUME_FINE_UP: uint = 0x90;
		public static const VIBRATO_SPEED: uint = 0xa0;
		public static const VIBRATO: uint = 0xb0;
		public static const PANNING: uint = 0xc0;
		public static const PANNING_SLIDE_LEFT: uint = 0xd0;
		public static const PANNING_SLIDE_RIGHT: uint = 0xe0;
		public static const TONE_PORTAMENTO: uint = 0xf0;
	}
}