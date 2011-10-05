
import flash.events.Event;

import mielophone.ui.views.ArtistView;

import mx.core.FlexGlobals;

public function doWork():void{
	this.dispatchEvent(new Event(Event.COMPLETE));
}

private function onArtistClick(e:Event):void{
	FlexGlobals.topLevelApplication.changeView(FlexGlobals.topLevelApplication.artistView);
}