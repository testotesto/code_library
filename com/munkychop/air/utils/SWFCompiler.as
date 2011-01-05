package com.munkychop.air.utils
{
	import com.munkychop.air.events.SWFCompilerEvent;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	public class SWFCompiler extends EventDispatcher
	{
		//-------------------------------------------------------------------------------
		//--private properties
		//-------------------------------------------------------------------------------
		private var _bashShell:File;
		private var _compilerURL:String;
		private var _localSupportDirectory:File;
		
		private var _tempSWFDirectory:File;
		private var _workingDirectory:File;
		
		private var _nativeProcess:NativeProcess;
		private var _nativeProcessStartupInfo:NativeProcessStartupInfo;
		private var _nativeProcessArgsVector:Vector.<String>;
		private var _nativeProcessEventHandlerObject:Object;
		private var _nativeProcessRunning:Boolean;
		
		//-------------------------------------------------------------------------------
		//--constructor
		//-------------------------------------------------------------------------------
		public function SWFCompiler (mxmlcCompilerURL:String, localSupportDirectoryToCreate:File)
		{
			_nativeProcessRunning = false;
			
			// TODO : check the OS and assign the appropriate command line interpreter (on Win this would be cmd.exe)
			_bashShell = new File ("/bin/bash");
			
			_compilerURL = mxmlcCompilerURL;
			_localSupportDirectory = localSupportDirectoryToCreate;
			
			//this method automatically checks whether or not the specified file (directory) exists.
			//If it does exist this method does nothing, otherwise the directory is created.
			_localSupportDirectory.createDirectory ();
			
			_nativeProcessEventHandlerObject = new Object ();
		}
		
		//-------------------------------------------------------------------------------
		//--public methods
		//-------------------------------------------------------------------------------
		public function compile (documentClassURL:String, args:Array=null, workingDirectory:File=null):void
		{
			_nativeProcessRunning = true;
			
			_nativeProcessArgsVector = new Vector.<String>;
			_nativeProcessArgsVector.push (_compilerURL);
			_nativeProcessArgsVector.push (documentClassURL);
			
			if (args != null)
			{
				for (var i:int=0; i < args.length; i++)
				{
					trace (args[i]);
					_nativeProcessArgsVector.push (args[i]);
				}
			}
			
			_nativeProcessStartupInfo = new NativeProcessStartupInfo ();
			//_nativeProcessStartupInfo.workingDirectory = _localSupportDirectory;
			_nativeProcessStartupInfo.executable = _bashShell;
			_nativeProcessStartupInfo.arguments = _nativeProcessArgsVector;
			
			if (workingDirectory != null)
			{
				_nativeProcessStartupInfo.workingDirectory = workingDirectory;
			}
			
			_nativeProcess = new NativeProcess ();
			
			_nativeProcessEventHandlerObject.standardOutputDataHandler = compileOutputDataHandler;
			//_nativeProcessEventHandlerObject.stabdardInputProgressHandler = undefined;
			_nativeProcessEventHandlerObject.exitHandler = compileExitHandler;
			_nativeProcessEventHandlerObject.standardErrorDataHandler = standardErrorDataHandler;
			_nativeProcessEventHandlerObject.standardErrorIOErrorHandler = standardErrorIOErrorHandler;
			
			addNativeProcessListeners ();
			
			_nativeProcess.start (_nativeProcessStartupInfo);
			
			dispatchEvent (new SWFCompilerEvent (SWFCompilerEvent.COMPILE_COMMAND_STARTED));
		}
		
		//-------------------------------------------------------------------------------
		//--private methods
		//-------------------------------------------------------------------------------
		private function compileOutputDataHandler (event:ProgressEvent):void
		{
			var output:String = _nativeProcess.standardOutput.readUTFBytes (_nativeProcess.standardOutput.bytesAvailable);
			
			dispatchEvent (new SWFCompilerEvent (SWFCompilerEvent.COMPILE_COMMAND_PROGRESS, {outputData:output}));
		}
		
		private function compileExitHandler (event:NativeProcessExitEvent):void
		{
			_nativeProcess.removeEventListener (ProgressEvent.STANDARD_OUTPUT_DATA, compileOutputDataHandler);
			_nativeProcess.removeEventListener (NativeProcessExitEvent.EXIT, compileExitHandler);
			_nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, standardErrorDataHandler);
			_nativeProcess.removeEventListener (IOErrorEvent.STANDARD_ERROR_IO_ERROR, standardErrorIOErrorHandler);
			
			clearNativeProcessEventHandlerObject ();
			
			_nativeProcessRunning = false;
			
			dispatchEvent (new SWFCompilerEvent (SWFCompilerEvent.COMPILE_COMMAND_COMPLETE, {exitCode:event.exitCode}));
		}
		
		//-------------------------------------------------------------------------------
		//--shared private methods
		//-------------------------------------------------------------------------------
		private function standardErrorDataHandler (event:ProgressEvent):void
		{
			var errorString:String = _nativeProcess.standardError.readUTFBytes (_nativeProcess.standardError.bytesAvailable);
			
			trace (errorString);
			
			//dispatch error event
		}
		
		private function standardErrorIOErrorHandler (event:IOErrorEvent):void
		{
			trace ("SWFCompiler IOError \n" + event.toString());
		}
		
		private function addNativeProcessListeners ():void
		{
			_nativeProcess.addEventListener (ProgressEvent.STANDARD_OUTPUT_DATA, _nativeProcessEventHandlerObject.standardOutputDataHandler, false, 0, true);
			//_nativeProcess.addEventListener (ProgressEvent.STANDARD_INPUT_PROGRESS, _nativeProcessEventHandlerObject.standardInputProgressHandler);
			_nativeProcess.addEventListener (NativeProcessExitEvent.EXIT, _nativeProcessEventHandlerObject.exitHandler, false, 0, true);
			_nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, _nativeProcessEventHandlerObject.standardErrorDataHandler, false, 0, true);
			_nativeProcess.addEventListener (IOErrorEvent.STANDARD_ERROR_IO_ERROR, _nativeProcessEventHandlerObject.standardErrorIOErrorHandler, false, 0, true);
		}
		
		private function clearNativeProcessEventHandlerObject ():void
		{
			_nativeProcessEventHandlerObject.standardOutputDataHandler = undefined;
			_nativeProcessEventHandlerObject.exitHandler = undefined;
			_nativeProcessEventHandlerObject.standardErrorDataHandler = undefined;
			_nativeProcessEventHandlerObject.standardErrorIOErrorHandler = undefined;
		}
		
	}
}