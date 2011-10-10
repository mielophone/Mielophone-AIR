import air.update.ApplicationUpdaterUI;
import air.update.events.UpdateEvent;

private function initAutoupdate():void{
	var up:ApplicationUpdaterUI = new ApplicationUpdaterUI();
	up.updateURL = "http://mielophone.github.com/update.xml";
	up.isCheckForUpdateVisible = false;
	up.addEventListener(UpdateEvent.INITIALIZED, function():void{
		up.checkNow();
	});
	up.initialize();
}