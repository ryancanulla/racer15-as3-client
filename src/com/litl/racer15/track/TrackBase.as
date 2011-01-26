package com.litl.racer15.track
{
    import com.litl.racer15.player.Player;
    import com.litl.racer15.player.PlayerBase;
    import com.litl.racer15.player.PlayerManager;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.utils.Dictionary;

    public class TrackBase extends Sprite
    {
        protected var _track:Bitmap;
        protected var _playerManager:PlayerManager;

        public function TrackBase() {
            super();
            _playerManager = new PlayerManager();
        }

        protected function create(e:Class):void {
            _track = new e as Bitmap;
            _track.smoothing = true;
            _track.cacheAsBitmap = true;
            _track.scaleX = 1.5;
            _track.scaleY = 1.5;
            addChild(_track);
        }

        protected function destroy():void {
            removeChild(_track);
            _track = null;
        }

        public function addPlayer(e:Player):void {
            var player:Player = e;
            _playerManager.addPlayer(player);
            addChild(player);
        }

        public function removePlayer(e:String):void {
            var player:Player = _playerManager.playerByName(e);
            _playerManager.removePlayer(player.name);
            removeChild(player);
        }

        public function get playerManager():PlayerManager {
            return _playerManager;
        }

    }
}
