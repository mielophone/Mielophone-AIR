
import com.greensock.TweenLite;

import flash.events.Event;

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

private function onSupportClick(e:Event):void{
	FlexGlobals.topLevelApplication.supportOverlay.alpha = 0;
	FlexGlobals.topLevelApplication.supportOverlay.visible = true;
	TweenLite.to(FlexGlobals.topLevelApplication.supportOverlay, 0.5, {alpha:1});
}