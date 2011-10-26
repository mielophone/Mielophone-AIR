import com.codezen.mse.models.Artist;
import com.codezen.mse.models.Song;
import com.codezen.util.CUtils;

import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.FileFilter;

import mx.collections.ArrayCollection;
import mx.utils.ObjectUtil;

private function storePlaylist():void{
	//playerSettings.data.playlist = playQueue;
	//playerSettings.flush();
}

private function clearPlaylist():void{
	playQueue = [];
	songList.dataProvider = new ArrayCollection(playQueue);
}

private function savePlaylist():void{
	var plXML:XML = <playlist/>;
	
	var s:Object;
	for each(s in playQueue){
		plXML.appendChild(
			<song>
				<artist>{s.artist.name}</artist>
				<title>{s.name}</title>
				<duration>{s.duration}</duration>
			</song>
		);
	}
	
	// create xml strign 
	var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
	// append data
	outputString += plXML.toXMLString();
	// remove string breaks
	outputString = outputString.replace(/\n/gs, File.lineEnding);
	// load prefs file from app dir
	var playlistFile:File = File.documentsDirectory.resolvePath("playlist.mpl");
	playlistFile.addEventListener(Event.SELECT, function():void{
		// create new reading stream
		var stream:FileStream = new FileStream();
		// create new file if not exist and open
		stream.open(playlistFile, FileMode.WRITE);
		// write settings
		stream.writeUTFBytes(outputString);
		// close file
		stream.close();
		// reset vars
		playlistFile = null;
		stream = null;
		plXML = null;
	});
	playlistFile.browseForSave("Save playlist");
}

private function openPlaylist():void{
	// load prefs file from app dir
	var playlistFile:File = File.documentsDirectory.resolvePath("playlist.mpl");
	playlistFile.addEventListener(Event.SELECT, function(e:Event):void{
		// create new reading stream
		var stream:FileStream = new FileStream();
		// if file exists
		if (playlistFile.exists) {
			// read file
			stream.open(playlistFile, FileMode.READ);
			// create xml from file
			var prefsXML:XML = XML(stream.readUTFBytes(stream.bytesAvailable));
			// close stream
			stream.close();
			
			// new queue
			playQueue = [];
			
			// fill vars
			var item:XML;
			var s:Song;
			for each(item in prefsXML.children()){
				s = new Song();
				s.artist = new Artist();
				s.artist.name = item.artist.text();
				s.name = item.title.text();
				s.duration = item.duration.text();
				s.durationText = CUtils.secondsToString(s.duration/1000);
				
				playQueue.push(s);
			}
			
			songList.dataProvider = new ArrayCollection(playQueue);
		}
		
		item = null;
		playlistFile = null;
		stream = null;
	});
	playlistFile.browseForOpen("Open Playlist", [new FileFilter("Mielophone playlist", "mpl")]);
}