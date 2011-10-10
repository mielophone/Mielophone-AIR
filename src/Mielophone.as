
import com.codezen.mse.MusicSearchEngine;

import flash.events.Event;


private function onAppicationComplete():void{
	// check update
	initAutoupdate();
	
	// create search engine
	mse = new MusicSearchEngine();
	mse.addEventListener(Event.INIT, onMseInit);
	
	// init view helpers
	initViewHelpers();
	
	// init player
	musicPlayer.initPlayer();
}

private function onMseInit(e:Event):void{
	mse.removeEventListener(Event.INIT, onMseInit);
	
	// init settings
	settingsView.initSettings();
}