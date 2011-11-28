
import flash.events.Event;
import flash.net.SharedObject;

import mx.collections.ArrayCollection;
import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;

[Bindable]
private var pluginsCollection:ArrayCollection;

private var generalSettings:SharedObject;

public function doWork():void{
	this.dispatchEvent(new Event(Event.COMPLETE));
}

public function initSettings():void{
	// load general settings
	generalSettings = SharedObject.getLocal("mielophone.settings");
	// animation
	if( generalSettings.data.animation != null ){
		enableAnimations.selected = generalSettings.data.animation;
		FlexGlobals.topLevelApplication.animationEnabled = generalSettings.data.animation; 
	}
	
	enableTray.selected = FlexGlobals.topLevelApplication.minimizeToTray;
	
	pluginsCollection = new ArrayCollection( FlexGlobals.topLevelApplication.mse.getActivePlugins() );
}

private function onBufferChange(e:Event):void{
	FlexGlobals.topLevelApplication.musicPlayer.setBuffer(bufferingSlider.value * 1000);
}

private function onPlaylistBehaveChange(e:Event):void{
	FlexGlobals.topLevelApplication.musicPlayer.setPlaylistBehavior(playlistBehavior.selectedItem.value, playlistBehavior.selectedIndex);
}

private function pluginName(p:Object):String{
	return p.index + ". " + p.name + " (by " + p.author + ")";
}

private function saveSettings():void{
	FlexGlobals.topLevelApplication.musicPlayer.setScrobblingAuth(lastfmLogin.text, lastfmPass.text);
}

private function onEnableAnimationChange(e:Event):void{
	FlexGlobals.topLevelApplication.animationEnabled = enableAnimations.selected; 
	generalSettings.data.animation = enableAnimations.selected;
	generalSettings.flush();
}

private function onMinimizeToTrayChange(e:Event):void{
	FlexGlobals.topLevelApplication.setMinimizeToTray(enableTray.selected);
}

private function onFacebookClick(e:Event):void{
	FlexGlobals.topLevelApplication.connectFacebook();
}