import mx.collections.ArrayCollection;

private function storePlaylist():void{
	playerSettings.data.playlist = playQueue;
	playerSettings.flush();
}

private function clearPlaylist():void{
	playQueue = [];
	songList.dataProvider = new ArrayCollection(playQueue);
}