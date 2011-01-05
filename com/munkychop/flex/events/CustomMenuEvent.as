package com.munkychop.flex.events
{
	import flash.events.Event;
	
	public class CustomMenuEvent extends Event
	{
		public static const ITEM_CLICK:String = "itemtemClick";
		public static const REMOVE_ITEM_CLICK:String = "removeItemClick";
		
		public var data:Object;
		
		public function CustomMenuEvent(type:String, data:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
		
		override public function clone ():Event
		{
			return new CustomMenuEvent (type, data, bubbles, cancelable);
		}
	}
}