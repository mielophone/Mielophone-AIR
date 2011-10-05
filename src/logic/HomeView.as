
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