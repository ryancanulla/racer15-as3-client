package com.litl.racer15
{
    import com.electrotank.electroserver5.ElectroServer;
    import com.electrotank.electroserver5.api.EsObject;
    import com.electrotank.electroserver5.api.LeaveRoomRequest;
    import com.electrotank.electroserver5.api.MessageType;
    import com.electrotank.electroserver5.api.PluginMessageEvent;
    import com.electrotank.electroserver5.api.PluginRequest;
    import com.electrotank.electroserver5.zone.Room;
    import com.litl.racer15.gameobjects.Background;
    import com.litl.racer15.helpers.camera.Camera;
    import com.litl.racer15.helpers.movement.Heading;
    import com.litl.racer15.player.Player;
    import com.litl.racer15.player.PlayerBase;
    import com.litl.racer15.player.PlayerManager;
    import com.litl.racer15.track.Track1;
    import com.litl.racer15.track.TrackBase;
    import com.litl.utils.network.clock.Clock;

    import fl.controls.List;
    import fl.data.DataProvider;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class Racer15Game extends Sprite
    {
        public static const BACK_TO_LOBBY:String = "backToLobby";

        private var _es:ElectroServer;
        private var _clock:Clock;
        private var _room:Room;

        private var _playerListUI:List;

        private var _itemsHolder:Sprite;
        private var _myPlayer:Player;
        private var _maxSpeed:Number;

        private var _myUsername:String;
        private var _myUserInfo:PlayerBase;

        private var _countdownField:TextField;
        private var _countdownTimer:Timer;
        private var _secondsLeft:int;
        private var _gameStarted:Boolean;

        private var _okToSend:Boolean;
        private var _waitingField:TextField;

        private var track:TrackBase;
        private var camera:Camera;

        public function Racer15Game() {

        }

        public function initialize():void {
            _gameStarted = false;
            _okToSend = true;

            track = new Track1();
            addChild(track);

            //add the player list UI
            _playerListUI = new List();
            _playerListUI.x = this.width * .80;
            _playerListUI.y = this.height * .10;
            _playerListUI.width = 800 - _playerListUI.x - 10;
            addChild(_playerListUI);

            _es.engine.addEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);
            _myUsername = _es.managerHelper.userManager.me.userName;

            _myPlayer = new Player;
            _myPlayer.time = _clock.time;
            _myPlayer.name = _myUsername;
            _myPlayer.isMe = true;
            track.addPlayer(_myPlayer);

            camera = new Camera();
            camera.track = track;
            camera.follow(_myPlayer);
            addChild(camera);

            addEventListener(Event.ENTER_FRAME, run);
            createWaitingField();
            sendInitializeMe();
        }

        private function run(e:Event):void {

            camera.moveCamera();

            if (_clock.time - _myPlayer.lastTimeSent > 250 && _myPlayer != null) {
                sendMyPosition();
            }

            for (var i:uint = 0; i < track.playerManager.players.length; i++) {
                var player:Player = track.playerManager.players[i];

//                if (player.collision)
//                    sendMyPosition();
            }

            track.run();
        }

        private function sendInitializeMe():void {
            //tell the plugin that you're ready
            var esob:EsObject = new EsObject();
            esob.setString(PluginConstants.ACTION, PluginConstants.INIT_ME);

            //send to the plugin
            sendToPlugin(esob);
        }

        private function sendMyPosition():void {
            if (_myPlayer != null && _okToSend && _clock.time > _myPlayer.lastTimeSent) {
                _myPlayer.lastTimeSent = _clock.time;

                var esob:EsObject = new EsObject();
                esob.setString(PluginConstants.ACTION, PluginConstants.UPDATE_HEADING);
                esob.setEsObject(PluginConstants.HEADING, _myPlayer.esObject);

                //trace("send my position: " + _myUsername);
                sendToPlugin(esob);
            }
        }

        private function sendToPlugin(esob:EsObject):void {
            //build the request
            var pr:PluginRequest = new PluginRequest();
            pr.parameters = esob;
            pr.roomId = _room.id;
            pr.zoneId = _room.zoneId;
            pr.pluginName = PluginConstants.PLUGIN_NAME;

            //send it
            _es.engine.send(pr);
        }

        /**
         * Called when a message is received from a plugin
         */
        public function onPluginMessageEvent(e:PluginMessageEvent):void {
            var esob:EsObject = e.parameters;

            //get the action which determines what we do next
            var action:String = esob.getString(PluginConstants.ACTION);

            switch (action) {
                case PluginConstants.UPDATE_HEADING:
                    handleUpdateHeading(esob);
                    break;
                case PluginConstants.PLAYER_LIST:
                    handlePlayerList(esob);
                    break;
                case PluginConstants.START_COUNTDOWN:
                    handleStartCountdown(esob);
                    break;
                case PluginConstants.STOP_COUNTDOWN:
                    handleStopCountdown(esob);
                    break;
                case PluginConstants.START_GAME:
                    //handleStartGame(esob);
                    break;
                case PluginConstants.GAME_OVER:
                    //handleGameOver(esob);
                    break;
                case PluginConstants.ADD_PLAYER:
                    handleAddPlayer(esob);
                    break;
                case PluginConstants.REMOVE_PLAYER:
                    handleRemovePlayer(esob);
                    break;
                case PluginConstants.ERROR:
                    //handleError(esob);
                    break;
                default:
                    trace("Action not handled: " + action);
            }
        }

        private function handleUpdateHeading(esob:EsObject):void {
            var ob:EsObject = esob.getEsObject(PluginConstants.HEADING);
            var name:String = ob.getString(PluginConstants.NAME);

            var heading:Heading = new Heading();
            heading.x = ob.getNumber(PluginConstants.X);
            heading.y = ob.getNumber(PluginConstants.Y);
            heading.angle = ob.getNumber(PluginConstants.ANGLE);
            heading.time = ob.getNumber(PluginConstants.ANGLE);
            heading.speed = ob.getNumber(PluginConstants.SPEED);

            var player:Player = track.playerManager.playerByName(name);

            //trace(track.playerManager.playerByName(name).name);

//            if (player == null) {
//                // add the player to the stage
//                player = new Player();
//                player.setHeading(heading);
//                player.name = name;
//                track.addPlayer(player);
//            }

            //            if (name == _myUsername) {
            //                name = "my_mirror";
            //                player.name = "my_mirror";
            //            }

            if (!player.isMe) {
                player.setHeading(heading);

//              if (name == "my_mirror") {
//                player.alpha = .5;
//              }
            }

        }

        public function destroy():void {
            _es.engine.addEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);

            var lrr:LeaveRoomRequest = new LeaveRoomRequest();
            lrr.roomId = _room.id;
            lrr.zoneId = _room.zoneId;

            _es.engine.send(lrr);
        }

        /**
         * Parse the player list
         */
        private function handlePlayerList(esob:EsObject):void {
            var players:Array = esob.getEsObjectArray(PluginConstants.PLAYER_LIST);

            for (var i:int = 0; i < players.length; ++i) {
                var player_esob:EsObject = players[i];

                var p:Player = new Player();
                p.name = player_esob.getString(PluginConstants.NAME);
                p.ranking = player_esob.getInteger(PluginConstants.RANKING);
                p.isMe = p.name == _myUsername;
                p.time = _clock.time;

                if (!p.isMe) {
                    track.addPlayer(p);
                }
            }
            refreshPlayerList();
        }

        /**
         * Remove a player
         */
        private function handleRemovePlayer(esob:EsObject):void {
            var name:String = esob.getString(PluginConstants.NAME);

            if (!name == _myUsername) {
                // remove car
                track.removePlayer(name);
            }
            refreshPlayerList();
        }

        /**
         * Add a player
         */
        private function handleAddPlayer(esob:EsObject):void {
            var p:Player = new Player();
            p.name = esob.getString(PluginConstants.NAME);
            p.ranking = 0;
            p.isMe = p.name == _myUsername;
            p.time = _clock.time;

            //p.converger.clock = _clock;
//            if (p.isMe)
//                p.name = "my_mirror";

            if (!p.isMe) {
                track.addPlayer(p);
                p.run();
            }

            //track.addPlayer(p);

            refreshPlayerList();
        }

        private function refreshPlayerList():void {
            var dp:DataProvider = new DataProvider();

            for (var i:int = 0; i < track.playerManager.players.length; ++i) {
                var p:PlayerBase = track.playerManager.players[i];
                //dp.addItem({ label: p.name + ", position: " + p.score.toString(), data: p });
                dp.addItem({ label: p.name + ", position: " + (i + 1).toString(), data: p });
            }

            _playerListUI.dataProvider = dp;
        }

        private function handleStartCountdown(esob:EsObject):void {
            if (_waitingField != null) {
                removeChild(_waitingField);
                _waitingField = null;
            }

            _secondsLeft = esob.getInteger(PluginConstants.COUNTDOWN_LEFT);
            trace("secondsLeft: " + _secondsLeft.toString());

            _countdownField = new TextField();
            addChild(_countdownField);

            _countdownField.x = 320;
            _countdownField.y = 200;
            _countdownField.selectable = false;

            _countdownField.autoSize = TextFieldAutoSize.CENTER;

            var tf:TextFormat = new TextFormat();
            tf.size = 80;
            tf.bold = true;
            tf.font = "Arial";
            tf.color = 0xFFFFFF;

            _countdownField.defaultTextFormat = tf;
            _countdownField.text = _secondsLeft.toString();

            _countdownField.filters = [ new GlowFilter(0x009900), new DropShadowFilter()];

            _countdownTimer = new Timer(1000);
            _countdownTimer.start();
            _countdownTimer.addEventListener(TimerEvent.TIMER, onCountdownTimer);

        }

        private function handleStopCountdown(esob:EsObject):void {
            if (_countdownTimer != null) {
                _countdownTimer.stop();
                _countdownTimer.removeEventListener(TimerEvent.TIMER, onCountdownTimer);
                _countdownTimer = null;

                removeChild(_countdownField);
                _countdownField = null;

                if (track.playerManager.players.length == 1) {
                    createWaitingField();
                }
            }
        }

        private function onCountdownTimer(e:TimerEvent):void {
            --_secondsLeft;
            _countdownField.text = _secondsLeft.toString();
        }

        private function createWaitingField():void {
            var tf:TextFormat = new TextFormat();
            tf.size = 30;
            tf.bold = true;
            tf.font = "Arial";
            tf.color = 0xFFFFFF;

            var field:TextField = new TextField();
            field.x = 320;
            field.y = 150;
            field.autoSize = TextFieldAutoSize.CENTER;
            field.defaultTextFormat = tf;

            field.text = "Waiting for players...";

            _waitingField = field;

            addChild(field);
        }

        public function set es(value:ElectroServer):void {
            _es = value;
        }

        public function set room(value:Room):void {
            _room = value;
        }

        public function set clock(value:Clock):void {
            _clock = value;
        }

    }

}
