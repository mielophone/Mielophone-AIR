
import com.codezen.mse.MusicSearchEngine;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

public function doWork():void{
	getTopAlbums();
}

private function getTopAlbums():void{
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onChart);
	mse.getTopAlbums();
}

private function onChart(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onChart);
	
	albumList.dataProvider = new ArrayCollection(mse.albums);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}