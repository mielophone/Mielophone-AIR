
import com.codezen.mse.MusicSearchEngine;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.MouseEvent;

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

private function onMouseMove(e:MouseEvent):void{
	if( e.stageY < 32 ){
		TweenLite.to(searchInput, 0.3, {height:32});
		//searchInput.height = 26;
	}else{
		if( searchInput.text.length == 0 ){
			TweenLite.to(searchInput, 0.3, {height:0});
		}
		//searchInput.height = 0;
	}
}