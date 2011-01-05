package com.munkychop.air.events
{
	import flash.events.Event;
	
	public class NativeScriptEvent extends Event
	{
		//-------------------------------------------------------------------------------
		//--public event constants
		//-------------------------------------------------------------------------------		
		public static const NATIVE_SCRIPT_COMMAND_STARTED:String = "nativeScriptCommandStarted";
		public static const NATIVE_SCRIPT_COMMAND_OUTPUT:String = "nativeScriptCommandOutput";
		public static const NATIVE_SCRIPT_COMMAND_COMPLETE:String = "nativeScriptCommandComplete";
		
		//-------------------------------------------------------------------------------
		//--public properties
		//-------------------------------------------------------------------------------
		public var data:Object;
		
		//-------------------------------------------------------------------------------
		//--constructor
		//-------------------------------------------------------------------------------
		public function NativeScriptEvent (type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super (type, bubbles, cancelable);
			
			this.data = data;
		}
		
		override public function clone ():Event
		{
			return new NativeScriptEvent (type, data, bubbles, cancelable);
		}
	}
}