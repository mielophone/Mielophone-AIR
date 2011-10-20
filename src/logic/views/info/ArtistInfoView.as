
import com.codezen.mse.MusicSearchEngine;
import com.codezen.util.CUtils;
import com.greensock.TweenLite;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;

private var mse:MusicSearchEngine;

private var loadedArtist:String;

public function doWork():void{
	artistImage.source = FlexGlobals.topLevelApplication.currentArtist.image;
	artistDesc.text = CUtils.convertHTMLEntities( CUtils.stripTags(FlexGlobals.topLevelApplication.currentArtist.description_short) );
	artistName.text = FlexGlobals.topLevelApplication.currentArtist.name;
	
	mse = FlexGlobals.topLevelApplication.mse;
	
	if(loadedArtist != FlexGlobals.topLevelApplication.currentArtist.name){
		loadedArtist = FlexGlobals.topLevelApplication.currentArtist.name;
		
		// reset old info
		artistDesc.text = fullDescription.text = ""; 
		similarList.dataProvider = tagsList.dataProvider = new ArrayCollection();
		
		mse.addEventListener(Event.COMPLETE, onArtistInfo);
		mse.getArtistInfo(FlexGlobals.topLevelApplication.currentArtist);
	}else{
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}

private function onArtistInfo(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtistInfo);
	artistDesc.text = CUtils.convertHTMLEntities( CUtils.stripTags(FlexGlobals.topLevelApplication.currentArtist.description_short) );//description) );
	
	similarList.dataProvider = new ArrayCollection(mse.artistInfo.similar);
	tagsList.dataProvider = new ArrayCollection(mse.artistInfo.tags);
	fullDescription.text = CUtils.convertHTMLEntities( CUtils.stripTags(FlexGlobals.topLevelApplication.currentArtist.description) );//description) );
	
	mse.addEventListener(Event.COMPLETE, onArtistAlbums);
	mse.addEventListener(ErrorEvent.ERROR, onNoAlbums);
	mse.getArtistAlbums(FlexGlobals.topLevelApplication.currentArtist);
}

private function onArtistAlbums(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtistAlbums);
	mse.removeEventListener(ErrorEvent.ERROR, onNoAlbums);
	
	albumsList.dataProvider = new ArrayCollection(mse.albums);
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onNoAlbums(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onArtistAlbums);
	mse.removeEventListener(ErrorEvent.ERROR, onNoAlbums);
	
	albumsList.dataProvider = new ArrayCollection();
	
	this.dispatchEvent(new Event(Event.COMPLETE));
}
							

private function toggleInfo():void{
	albumsListScroller.visible = !albumsListScroller.visible;
	artistInfoScroller.visible = !artistInfoScroller.visible; 
}