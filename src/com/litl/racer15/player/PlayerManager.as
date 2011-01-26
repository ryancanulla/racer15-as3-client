package com.litl.racer15.player
{
    import flash.utils.Dictionary;

    public class PlayerManager
    {

        private var _players:Array;
        private var _playersByName:Dictionary;

        public function PlayerManager() {
            _players = [];
            _playersByName = new Dictionary();
        }

        public function playerByName(name:String):Player {
            return _playersByName[name];
        }

        public function addPlayer(p:Player):void {
            _players.push(p);
            _playersByName[p.name] = p;
        }

        public function removePlayer(name:String):void {
            var p:Player = _playersByName[name];
            _playersByName[name] = null;

            for (var i:int = 0; i < _players.length; ++i) {
                if (_players[i] == p) {
                    _players.splice(i, 1);
                    break;
                }
            }
        }

        public function get players():Array {
            return _players;
        }

    }

}
