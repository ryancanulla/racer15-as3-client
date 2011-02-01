package com.litl.racer15.track
{
    import com.litl.racer15.helpers.movement.CollisionManager;
    import com.litl.racer15.player.Player;
    import com.litl.racer15.player.PlayerBase;
    import com.litl.racer15.player.PlayerManager;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.utils.Dictionary;

    public class TrackBase extends Sprite
    {
        protected var _track:Bitmap;
        protected var _bounds:Bitmap;
        protected var _playerManager:PlayerManager;
        protected var _startingPosition:Point;

        private var collisionManager:CollisionManager;

        public function TrackBase() {
            super();
            collisionManager = new CollisionManager();
            _startingPosition = new Point(2700, 1675);
            _playerManager = new PlayerManager();
        }

        protected function create(track:Class, bounds:Class):void {
            _track = new track as Bitmap;
            _track.smoothing = true;
            _track.cacheAsBitmap = true;

            _bounds = new bounds as Bitmap;
            _bounds.visible = true;

            addChild(_track);
            //addChild(_bounds);
        }

        public function run():void {
            for (var j:int = 0; j < _playerManager.players.length; ++j) {
                var player1:Player = _playerManager.players[j];

                for (var k:uint = 0; k < _playerManager.players.length; k++) {
                    if (!(j == k)) {
                        var player2:Player = _playerManager.players[k];

                        if (collisionManager.checkCollision(player1, player2)) {
                            player1.collide(player2.heading);
                            player2.collide(player2.heading);
                        }
                    }
                }

                player1.run();
            }
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
