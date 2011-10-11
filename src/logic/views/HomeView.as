
import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mielophone.ui.views.ArtistSearchView;

import mx.core.FlexGlobals;

public function doWork():void{
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onArtistClick(e:Event):void{
	FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.artistView);
}

private function onAlbumClick(e:Event):void{
	FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.albumView);
}

private function onSongClick(e:Event):void{
	FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.songView);
}

private function onSettingsClick(e:Event):void{
	FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.settingsView);
}

private function onMarketClick(e:Event):void{
	FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.marketView);
}

private function onSupportClick(e:Event):void{
	FlexGlobals.topLevelApplication.supportOverlay.alpha = 0;
	FlexGlobals.topLevelApplication.supportOverlay.visible = true;
	TweenLite.to(FlexGlobals.topLevelApplication.supportOverlay, 0.5, {alpha:1});
}

private function onSearchKey(e:KeyboardEvent):void{
	if(e.keyCode == Keyboard.ENTER && searchInput.text.length > 1){
		FlexGlobals.topLevelApplication.searchResView.query = searchInput.text;
		
		FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.searchResView);
		
		searchInput.text = '';
	}else if(e.keyCode == Keyboard.ESCAPE){
		searchInput.text = '';
	}
}