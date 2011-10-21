
import com.codezen.mse.MusicSearchEngine;

import flash.events.Event;
import flash.media.Sound;
import flash.net.URLRequest;

import mielophone.ui.player.MusicPlayer;
import mielophone.ui.skins.MielophoneApplication;

public var musicPlayer:MusicPlayer;

private function onAppicationComplete():void{
	musicPlayer = (this.skin as MielophoneApplication).musicPlayer;
	
	// check update
	initAutoupdate();
	
	// init docking
	initDock();
	
	// init ui plugins
	initUIExtensions();
	
	// create search engine
	mse = new MusicSearchEngine();
	mse.addEventListener(Event.INIT, onMseInit);
	
	// init view helpers
	initViewHelpers();
	
	// init player
	musicPlayer.initPlayer();
	
	// init radio
	radioView.initRadio();
}

private function onMseInit(e:Event):void{
	mse.removeEventListener(Event.INIT, onMseInit);
	
	// init settings
	settingsView.initSettings();
	
	// get plugins
	marketView.fetchPlugins();
}