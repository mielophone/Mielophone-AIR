import com.greensock.TweenLite;

import flash.events.Event;
import flash.net.navigateToURL;

import spark.components.Group;

private function onClick(e:Event):void{
	var grp:Group = this;
	TweenLite.to(this, 0.5, {alpha:0, onComplete:function():void{
		grp.visible = false;
	}});
}