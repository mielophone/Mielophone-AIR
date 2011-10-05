import flash.events.Event;

import spark.components.Group;

public function changeView(view:*):void{
	// show loader
	
	// do view work
	view.addEventListener(Event.COMPLETE, onViewWork);
	view.doWork();
}

private function onViewWork(e:Event):void{
	e.target.removeEventListener(Event.COMPLETE, onViewWork);
	
	// animate view in
	e.target.visible = true;
}