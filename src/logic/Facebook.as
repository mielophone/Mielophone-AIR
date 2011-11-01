
import com.codezen.mse.models.Song;
import com.facebook.graph.FacebookDesktop;

import mx.utils.ObjectUtil;

private var fbAppID:String = "255624951156266";
private var fbPermission:Array = ["offline_access", "publish_actions"];
private var fbInitialized:Boolean = false;
private var fbUser:Object;

private function initFacebook():void{
	FacebookDesktop.init(fbAppID, onFbLogin);
}

public function connectFacebook():void{
	FacebookDesktop.login(onFbLogin, fbPermission);
}

private function onFbLogin(session:Object, failure:Object):void{
	if( session != null ){ // logged in
		if(fbInitialized){
			fbUser = {
				'id':session.uid,
				'token':session.accessToken,
				'fname':session.user.first_name,
				'gender':session.user.gender,
				'lname':session.user.last_name,
				'location':session.user.location.name
			};
			
			//
			trace('logged in');
		}else{
			trace('fb init ok');
			fbInitialized = true;
		}
	}else if( failure != null ){
		if(fbInitialized){
			trace(ObjectUtil.toString(failure));
		}else{
			//Alert.show("Facebook init failed!", "Error");
			trace("Initialized with error.");
			fbInitialized = true;
		}
	}
}

public function postSong(s:Song):void{
	var action:String = "/me/mielophone:listen";
	
}




