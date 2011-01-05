﻿package com.munkychop.actionscript.utils{	import com.adobe.images.JPGEncoder;	import com.munkychop.actionscript.events.SaveEvent;	import com.munkychop.actionscript.events.SaveEventDispatcher;		import flash.display.MovieClip;	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.events.Event;	import flash.events.ProgressEvent;	import flash.geom.Matrix;	import flash.net.FileReference;	import flash.utils.ByteArray;		public class JPGUtil	{		private var _bitmapData:BitmapData;		private var _byteArray:ByteArray;		private var _fileReference:FileReference;		private var _jpgEncoder:JPGEncoder;				public function JPGUtil ():void		{			_jpgEncoder = new JPGEncoder ();			_fileReference = new FileReference ();		}				public function createJPG (src:MovieClip, filename:String):void		{			_bitmapData = new BitmapData (src.width, src.height);			_bitmapData.draw (src, new Matrix());						_byteArray = _jpgEncoder.encode (_bitmapData);									_fileReference.addEventListener (Event.OPEN, fileReferenceOpen);			_fileReference.addEventListener (Event.CANCEL, fileReferenceCancel);			_fileReference.save (_byteArray, filename);		}				private function fileReferenceOpen (event:Event):void		{			_fileReference.removeEventListener (Event.OPEN, fileReferenceOpen);						_fileReference.addEventListener (ProgressEvent.PROGRESS, fileReferenceProgress);			_fileReference.addEventListener (Event.COMPLETE, fileReferenceComplete);						SaveEventDispatcher.dispatchEvent (new SaveEvent (SaveEvent.OPEN));		}				private function fileReferenceProgress (event:ProgressEvent):void		{			SaveEventDispatcher.dispatchEvent (new SaveEvent (SaveEvent.PROGRESS, {bytesLoaded: event.bytesLoaded, bytesTotal: event.bytesTotal}));		}				private function fileReferenceComplete (event:Event):void		{			_fileReference.removeEventListener (ProgressEvent.PROGRESS, fileReferenceProgress);			_fileReference.removeEventListener (Event.COMPLETE, fileReferenceComplete);						SaveEventDispatcher.dispatchEvent (new SaveEvent (SaveEvent.COMPLETE));		}				private function fileReferenceCancel (event:Event):void		{			if (_fileReference.hasEventListener (Event.OPEN))			{				_fileReference.removeEventListener (Event.OPEN, fileReferenceOpen);			}						if (_fileReference.hasEventListener (ProgressEvent.PROGRESS))			{				_fileReference.removeEventListener (ProgressEvent.PROGRESS, fileReferenceProgress);			}						if (_fileReference.hasEventListener (Event.COMPLETE))			{				_fileReference.removeEventListener (Event.COMPLETE, fileReferenceComplete);			}						SaveEventDispatcher.dispatchEvent (new SaveEvent (SaveEvent.CANCEL));		}	}}