
import com.codezen.mse.MusicSearchEngine;
import com.greensock.TweenLite;

import flash.events.Event;

import mielophone.ui.views.ArtistSearchView;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

public var query:String;

public function doWork():void{
	mse = FlexGlobals.topLevelApplication.mse;
	
	mse.addEventListener(Event.COMPLETE, onResults);
	mse.query(query);
}

private function onResults(e:Event):void{
	artistList.dataProvider = new ArrayCollection(mse.artists.slice(0,5));
	albumList.dataProvider = new ArrayCollection(mse.albums.slice(0,5));
	songList.dataProvider = new ArrayCollection(mse.songs.slice(0,7));
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}
