package com.munkychop.air.events
{
	import flash.events.Event;
	
	public class NativeEvents extends Event
	{
		public function NativeEvents(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}