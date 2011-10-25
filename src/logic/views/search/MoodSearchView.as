
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

private var topMoods:ArrayCollection;

public function doWork():void{
	getTopMoods();
}

private function getTopMoods():void{	
	if(mse != null && moodsList.dataProvider != null){
		this.dispatchEvent(new Event(Event.COMPLETE));
		return;
	}
	
	mse = FlexGlobals.topLevelApplication.mse;
	mse.addEventListener(Event.COMPLETE, onTopMoods);
	mse.getTopMoods();
}

private function onTopMoods(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onTopMoods);
	
	topMoods = new ArrayCollection(mse.moods);
	moodsList.dataProvider = topMoods;
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onSearchKeyUp(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		moodsList.dataProvider = new ArrayCollection(mse.findMood(searchInput.text));
		
		searchInput.text = '';
	}else if(e.keyCode == Keyboard.ESCAPE && searchInput.text.length < 1){
		moodsList.dataProvider = topMoods;
	}
}