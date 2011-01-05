package com.munkychop.air.events
{
	import flash.events.Event;
	
	public class SWFCompilerEvent extends Event
	{
		//-------------------------------------------------------------------------------
		//--public event constants
		//-------------------------------------------------------------------------------		
		public static const COMPILE_COMMAND_STARTED:String = "compileCommandStarted";
		public static const COMPILE_COMMAND_PROGRESS:String = "compileCommandProgress";
		public static const COMPILE_COMMAND_COMPLETE:String = "compileCommandComplete";
		
		//-------------------------------------------------------------------------------
		//--public properties
		//-------------------------------------------------------------------------------
		public var data:Object;
		
		//-------------------------------------------------------------------------------
		//--public methods
		//-------------------------------------------------------------------------------
		public function SWFCompilerEvent (type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super (type, bubbles, cancelable);
			
			this.data = data;
		}
		
		override public function clone ():Event
		{
			return new SWFCompilerEvent (type, data, bubbles, cancelable);
		}
	}
}