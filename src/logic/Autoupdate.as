import air.update.ApplicationUpdaterUI;
import air.update.events.UpdateEvent;

import flash.system.Capabilities;

private const GENERIC_UPDATE:String = "http://mielophone.github.com/update-generic.xml";
private const NORMAL_UPDATE:String = "http://mielophone.github.com/update.xml";

private function initAutoupdate():void{
	var up:ApplicationUpdaterUI = new ApplicationUpdaterUI();
	if( Capabilities.os.indexOf("Windows") != -1 || Capabilities.os.indexOf("Mac") != -1){
		trace('normal up');
		up.updateURL = NORMAL_UPDATE;
	}else{
		up.updateURL = GENERIC_UPDATE;
	}
	up.isCheckForUpdateVisible = false;
	up.addEventListener(UpdateEvent.INITIALIZED, function():void{
		up.checkNow();
	});
	up.initialize();
}