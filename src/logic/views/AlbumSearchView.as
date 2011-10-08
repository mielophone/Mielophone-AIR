
import com.codezen.mse.MusicSearchEngine;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

public function doWork():void{
	getTopAlbums();
}

private function getTopAlbums():void{
	if(mse != null && albumList.dataProvider != null){
		this.dispatchEvent(new Event(Event.COMPLETE));
		return;
	}
	
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onChart);
	mse.getTopAlbums();
}

private function onChart(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onChart);
	
	albumList.dataProvider = new ArrayCollection(mse.albums);
	
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

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		mse.addEventListener(Event.COMPLETE, onSearch);
		mse.findAlbum(searchInput.text);
		
		FlexGlobals.topLevelApplication.loadingOn();
		
		searchInput.text = '';
	}
}

private function onSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	albumList.dataProvider = new ArrayCollection(mse.albums);
}