import com.greensock.TweenLite;

import flash.events.Event;

import spark.components.Group;

public function changeView(view:*):void{
	// show loader
	loadingIndicator.visible = loadingIndicator.isLoading = true;
	
	// do view work
	view.addEventListener(Event.COMPLETE, onViewWork);
	view.doWork();
}

private function onViewWork(e:Event):void{
	e.target.removeEventListener(Event.COMPLETE, onViewWork);
	
	loadingIndicator.visible = loadingIndicator.isLoading = false;
	var view:Group = e.target as Group;
	
	// position window outside
	//view.percentWidth = view.percentHeight = 95;
	view.width = this.stage.width - 100;
	view.height = this.stage.height - 100;
	view.horizontalCenter = this.stage.width; 
	view.verticalCenter = 0;
	view.visible = true;
	
	// animate move-in
	TweenLite.to(view, 0.5, {horizontalCenter:0, onComplete:function():void{
		TweenLite.to(view, 0.3, {width:nativeWindow.width, height:stage.height, onComplete:function():void{
			view.x = view.y = 0;
			view.percentHeight = view.percentWidth = 100;
		}});
	}});
}