
import flash.desktop.DockIcon;
import flash.desktop.NativeApplication;
import flash.desktop.SystemTrayIcon;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.NativeWindowDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowDisplayStateEvent;

import mx.core.FlexGlobals;

[Embed(source='/assets/logo/logo-128.png')]
private var trayIcon:Class;

// System tray and doc icon classes
private var sysTrayIcon:SystemTrayIcon;
//private var dockIcon:DockIcon;

/**
 * Initialize system tray or dock icon
 * add event listeners
 **/
private function initDock():void{
	// check if it's mac
	//if(NativeApplication.supportsDockIcon){
	//	dockIcon = NativeApplication.nativeApplication.icon as DockIcon; // stopIcon as DockIcon;
		//NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, undock);
		//dockIcon.menu = createIconMenu();
	//} else 
	if (NativeApplication.supportsSystemTrayIcon){ // if it's windows
		sysTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
		sysTrayIcon.tooltip = "Mielophone";
		sysTrayIcon.addEventListener(MouseEvent.CLICK, undock);
	}
	// add dock handling
	this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onMinimize);
}

/**
 * On minimize go to tray
 **/
private function onMinimize(e:NativeWindowDisplayStateEvent):void{
	if(e.afterDisplayState == NativeWindowDisplayState.MINIMIZED){
		dock();
	}
}

/**
 * Exit app
 **/
private function doExit(e:Event):void{
	this.exit();
}

/**
 * Dock to tray
 **/
private function dock(event:Event = null):void{
	this.nativeWindow.visible = false;
	var image:Bitmap = new trayIcon;
	NativeApplication.nativeApplication.icon.bitmaps = [image.bitmapData];
	
	// erase vars
	image = null;
}

/**
 * Undock from tray
 **/		
protected function undock(event:Event = null):void{
	this.nativeWindow.visible = true;
	this.nativeWindow.restore();
	this.nativeApplication.icon.bitmaps = [];
}