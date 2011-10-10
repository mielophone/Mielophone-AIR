
import com.codezen.mse.MusicSearchEngine;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

private var topArtists:ArrayCollection;

public function doWork():void{
	getTopArtists();
}

private function getTopArtists():void{
	if(mse != null && artistList.dataProvider != null){
		this.dispatchEvent(new Event(Event.COMPLETE));
		return;
	}
	
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onArtists);
	mse.getTopArtists();
}

private function onArtists(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtists);
	
	topArtists = new ArrayCollection(mse.artists);
	artistList.dataProvider = topArtists;
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		mse.addEventListener(Event.COMPLETE, onSearch);
		mse.findArtist(searchInput.text);
		
		FlexGlobals.topLevelApplication.loadingOn();
		
		searchInput.text = '';
	}else if(e.keyCode == Keyboard.ESCAPE && searchInput.text.length < 1){
		artistList.dataProvider = topArtists;
	}
}

private function onSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	artistList.dataProvider = new ArrayCollection(mse.artists);
}


