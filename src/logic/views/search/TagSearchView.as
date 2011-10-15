
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.VideoObject;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.media.StageWebView;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;

private var mse:MusicSearchEngine;

private var topTags:ArrayCollection;

public function doWork():void{
	getTopTags();
}

private function getTopTags():void{	
	if(mse != null && tagsList.dataProvider != null){
		this.dispatchEvent(new Event(Event.COMPLETE));
		return;
	}
	
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onTopTags);
	mse.getTopTags();
}

private function onTopTags(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onTopTags);
	
	topTags = new ArrayCollection(mse.tags);
	tagsList.dataProvider = topTags;
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		mse.addEventListener(Event.COMPLETE, onSearch);
		mse.findTags(searchInput.text);
		
		FlexGlobals.topLevelApplication.loadingOn();
		
		searchInput.text = '';
	}else if(e.keyCode == Keyboard.ESCAPE && searchInput.text.length < 1){
		tagsList.dataProvider = topTags;
	}
}

private function onSearch(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSearch);
	
	FlexGlobals.topLevelApplication.loadingOff();
	
	tagsList.dataProvider = new ArrayCollection(mse.tags);
}