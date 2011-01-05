package com.munkychop.air.utils
{
	import com.munkychop.air.events.NativeScriptEvent;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	public class NativeScript extends EventDispatcher
	{
		//-------------------------------------------------------------------------------
		//--private properties
		//-------------------------------------------------------------------------------
		private var _executableShell:File;
		
		private var _nativeProcess:NativeProcess;
		private var _nativeProcessStartupInfo:NativeProcessStartupInfo;
		private var _nativeProcessArgsVector:Vector.<String>;
		private var _nativeProcessEventHandlerObject:Object;
		private var _nativeProcessRunning:Boolean;
		
		//-------------------------------------------------------------------------------
		//--constructor
		//-------------------------------------------------------------------------------
		public function NativeScript ()
		{
			// TODO : check the OS and assign the appropriate command line interpreter (on Win this would be cmd.exe)
			_executableShell = new File ();
		}
		
		//-------------------------------------------------------------------------------
		//--public methods
		//-------------------------------------------------------------------------------
		public function run (executableShellPath:String, params:Array=null, workingDirectory:File=null):void
		{
			if (!_nativeProcessRunning)
			{
				_executableShell.nativePath = executableShellPath;
				_nativeProcessRunning = true;
				
				_nativeProcessArgsVector = new Vector.<String>;
				
				if (params != null)
				{
					for (var i:int = 0; i < params.length; i++)
					{
						_nativeProcessArgsVector.push (params[i] as String);
						
						trace ("command: " + _executableShell.name + "  param: " + params[i]);
					}
				}
				
				_nativeProcessStartupInfo = new NativeProcessStartupInfo ();
				_nativeProcessStartupInfo.executable = _executableShell;
				_nativeProcessStartupInfo.arguments = _nativeProcessArgsVector;
				
				if (workingDirectory != null)
				{
					_nativeProcessStartupInfo.workingDirectory = workingDirectory;
				}
				
				_nativeProcess = new NativeProcess ();
				
				_nativeProcess.addEventListener (ProgressEvent.STANDARD_OUTPUT_DATA, standardOutputDataHandler, false, 0, true);
				//_nativeProcess.addEventListener (ProgressEvent.STANDARD_INPUT_PROGRESS, standardInputProgressHandler);
				_nativeProcess.addEventListener (NativeProcessExitEvent.EXIT, exitHandler, false, 0, true);
				_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, standardErrorDataHandler, false, 0, true);
				_nativeProcess.addEventListener (IOErrorEvent.STANDARD_ERROR_IO_ERROR, standardErrorIOErrorHandler, false, 0, true);
				
				_nativeProcess.start (_nativeProcessStartupInfo);
				
				dispatchEvent (new NativeScriptEvent (NativeScriptEvent.NATIVE_SCRIPT_COMMAND_STARTED));
			}
		}
		
		//-------------------------------------------------------------------------------
		//--private methods
		//-------------------------------------------------------------------------------
		private function standardOutputDataHandler (event:ProgressEvent):void
		{
			var output:String = event.currentTarget.standardOutput.readUTFBytes (event.currentTarget.standardOutput.bytesAvailable);
			dispatchEvent (new NativeScriptEvent (NativeScriptEvent.NATIVE_SCRIPT_COMMAND_OUTPUT, {output: output}));
		}
		
		private function exitHandler (event:NativeProcessExitEvent):void
		{
			_nativeProcess.removeEventListener (ProgressEvent.STANDARD_OUTPUT_DATA, standardOutputDataHandler);
			//_nativeProcess.removeEventListener (ProgressEvent.STANDARD_INPUT_PROGRESS, standardInputProgressHandler);
			_nativeProcess.removeEventListener (NativeProcessExitEvent.EXIT, exitHandler);
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, standardErrorDataHandler);
			_nativeProcess.removeEventListener (IOErrorEvent.STANDARD_ERROR_IO_ERROR, standardErrorIOErrorHandler);
			
			_nativeProcessRunning = false;
			
			dispatchEvent (new NativeScriptEvent (NativeScriptEvent.NATIVE_SCRIPT_COMMAND_COMPLETE));
		}
		
		private function standardErrorDataHandler (event:ProgressEvent):void
		{
			var errorString:String = _nativeProcess.standardError.readUTFBytes (_nativeProcess.standardError.bytesAvailable);
			
			trace (errorString);
		}
		
		private function standardErrorIOErrorHandler (event:IOErrorEvent):void
		{
			trace ("IOError: " + event);  
		}
	}
}