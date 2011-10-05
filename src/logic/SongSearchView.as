
import com.codezen.mse.MusicSearchEngine;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

public function doWork():void{
	getTopSongs();
}

private function getTopSongs():void{
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onSongs);
	mse.getTopTracks();
}

private function onSongs(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongs);
	
	songList.dataProvider = new ArrayCollection(mse.songs);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}