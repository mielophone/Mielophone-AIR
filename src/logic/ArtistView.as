
import com.codezen.mse.MusicSearchEngine;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

public function doWork():void{
	getTopArtists();
}

private function getTopArtists():void{
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onArtists);
	mse.getTopArtists();
}

private function onArtists(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtists);
	
	artistList.dataProvider = new ArrayCollection(mse.artists);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}