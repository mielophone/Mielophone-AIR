
import flash.desktop.DockIcon;
import flash.desktop.NativeApplication;
import flash.desktop.SystemTrayIcon;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
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

public function setTrayTooltip(tip:String = "Mielophone"):void{
	if(sysTrayIcon != null)
		sysTrayIcon.tooltip = tip;
}

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
		sysTrayIcon.menu = createIconMenu();
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
private function undock(event:Event = null):void{
	this.nativeWindow.visible = true;
	this.nativeWindow.restore();
	this.nativeApplication.icon.bitmaps = [];
}


/**
 * Exit app
 **/
private function doExit(e:Event):void{
	this.exit();
}
private function playPause(e:Event):void{
	musicPlayer.togglePlayPause();
	radioView.toggleRadio();
}
private function playNext(e:Event):void{
	musicPlayer.playNext();
}

/**
 * Create icon tray or dock
 **/
private function createIconMenu():NativeMenu{
	var iconMenu:NativeMenu = new NativeMenu();
	// playstop
	/*var playstopCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Play/Stop"));
	//playstopCommand.addEventListener(Event.SELECT,null);// playMusic);
	// next
	var playNextCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Next"));
	//playNextCommand.addEventListener(Event.SELECT,null);// skipMusic);
	// separator
	var separatorA:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("A", true));*/
	// win exit
	if(NativeApplication.supportsSystemTrayIcon){
		var playstopCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Play/Pause"));
		playstopCommand.addEventListener(Event.SELECT,playPause);
		
		var playNextCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Next"));
		playNextCommand.addEventListener(Event.SELECT,playNext);
		
		// separator
		var separatorA:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("A", true));
		
		var exitCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Exit"));
		exitCommand.addEventListener(Event.SELECT, doExit);
	}
	return iconMenu;
}