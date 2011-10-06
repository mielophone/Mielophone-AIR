
import com.codezen.mse.MusicSearchEngine;
import com.codezen.util.CUtils;
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;

private var mse:MusicSearchEngine;

public function doWork():void{
	trace(ObjectUtil.toString(FlexGlobals.topLevelApplication.currentArtist));
	
	artistImage.source = FlexGlobals.topLevelApplication.currentArtist.image;
	artistDesc.text = FlexGlobals.topLevelApplication.currentArtist.description_short;
	artistName.text = FlexGlobals.topLevelApplication.currentArtist.name;
	
	mse = FlexGlobals.topLevelApplication.mse;
	
	mse.addEventListener(Event.COMPLETE, onArtistInfo);
	mse.getArtistInfo(FlexGlobals.topLevelApplication.currentArtist);
	trace('start');
}

private function onArtistInfo(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtistInfo);
	artistDesc.text = CUtils.convertHTMLEntities( CUtils.stripTags(FlexGlobals.topLevelApplication.currentArtist.description_short) );//description) );
	
	trace('info get');
	
	mse.addEventListener(Event.COMPLETE, onArtistAlbums);
	mse.getArtistAlbums(FlexGlobals.topLevelApplication.currentArtist);
}

private function onArtistAlbums(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtistAlbums);
	
	trace('albums get');
	albumsList.dataProvider = new ArrayCollection(mse.albums);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

