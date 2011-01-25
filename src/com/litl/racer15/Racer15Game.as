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
    import com.litl.racer15.gameobjects.Car;
    import com.litl.racer15.player.Player;
    import com.litl.racer15.player.PlayerManager;
    import com.litl.racer15.player.movement.Heading;
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

        private var _playerManager:PlayerManager;
        private var _playerListUI:List;

        private var _itemsHolder:Sprite;
        private var _myPlayer:Car;
        private var _maxSpeed:Number;

        private var _myUsername:String;
        private var _myUserInfo:Player;

        private var _countdownField:TextField;
        private var _countdownTimer:Timer;
        private var _secondsLeft:int;
        private var _gameStarted:Boolean;

        private var _lastTimeSent:int;
        private var _okToSend:Boolean;
        private var _waitingField:TextField;

        public function Racer15Game() {

        }

        public function initialize():void {
            _gameStarted = false;
            _lastTimeSent = -1;
            _okToSend = true;

            //add a background
            var track:Background = new Background();
            track.x -= track.width - 2700;
            track.y -= track.height - 900;
            addChild(track);

            //add the player list UI
            _playerListUI = new List();
            _playerListUI.x = 650;
            _playerListUI.y = 10;
            _playerListUI.width = 800 - _playerListUI.x - 10;
            addChild(_playerListUI);

            addEventListener(Event.ENTER_FRAME, run);

            _es.engine.addEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);
            _myUsername = _es.managerHelper.userManager.me.userName;
            _playerManager = new PlayerManager();

            _myPlayer = new Car;
            _myPlayer.time = _clock.time;
            _myPlayer.name = _myUsername;
            addChild(_myPlayer);

            createWaitingField();
            sendInitializeMe();
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

        private function run(e:Event):void {
            if (getTimer() - _lastTimeSent > 500 && _okToSendMousePosition) {
                sendMyPosition();
            }

            for (var i:int = 0; i < _playerManager.players.length; ++i) {
                var p:Player = _playerManager.players[i];

                if (!p.isMe) {
                    p.car.run();
                }
            }
        }

        private function sendInitializeMe():void {
            //tell the plugin that you're ready
            var esob:EsObject = new EsObject();
            esob.setString(PluginConstants.ACTION, PluginConstants.INIT_ME);

            //send to the plugin
            sendToPlugin(esob);
        }

        private function sendMyPosition():void {
            _lastTimeSent = getTimer();

            var esob:EsObject = new EsObject();
            esob.setString(PluginConstants.ACTION, PluginConstants.POSITION_UPDATE);
            esob.setInteger(PluginConstants.X, _car.x);
            esob.setInteger(PluginConstants.Y, _car.y);

            sendToPlugin(esob);
        }

        /**
         * Sends formatted EsObjects to the DigGame plugin
         */
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
                case PluginConstants.POSITION_UPDATE:
                    //handlePositionUpdate(esob);
                    trace("handle position");
                    break;
                case PluginConstants.PLAYER_LIST:
                    handlePlayerList(esob);
                    trace("handlePlayerList(esob);");
                    break;
                case PluginConstants.START_COUNTDOWN:
                    handleStartCountdown(esob);
                    break;
                case PluginConstants.STOP_COUNTDOWN:
                    handleStopCountdown(esob);
                    break;
                case PluginConstants.START_GAME:
                    //handleStartGame(esob);
                    trace("start game");
                    break;
                case PluginConstants.GAME_OVER:
                    //handleGameOver(esob);
                    trace("game over");
                    break;
                case PluginConstants.ADD_PLAYER:
                    handleAddPlayer(esob);
                    break;
                case PluginConstants.REMOVE_PLAYER:
                    handleRemovePlayer(esob);
                    break;
                case PluginConstants.ERROR:
                    //handleError(esob);
                    trace("error");
                    break;
                default:
                    trace("Action not handled: " + action);
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
                p.score = player_esob.getInteger(PluginConstants.SCORE);
                p.isMe = p.name == _myUsername;

                if (!p.isMe) {
                    // add car
                    addChild(p.car);
                }

                _playerManager.addPlayer(p);
            }
            refreshPlayerList();
        }

        /**
         * Remove a player
         */
        private function handleRemovePlayer(esob:EsObject):void {
            var name:String = esob.getString(PluginConstants.NAME);
            var player:Player = _playerManager.playerByName(name);

            if (!player.isMe) {
                // remove car
                removeChild(player.car);
            }
            _playerManager.removePlayer(name);
            refreshPlayerList();
        }

        /**
         * Add a player
         */
        private function handleAddPlayer(esob:EsObject):void {
            var p:Player = new Player();
            p.name = esob.getString(PluginConstants.NAME);
            p.score = 0;
            p.isMe = p.name == _myUsername;

            if (!p.isMe) {
                addChild(p.car);
            }

            _playerManager.addPlayer(p);

            refreshPlayerList();
        }

        private function refreshPlayerList():void {
            var dp:DataProvider = new DataProvider();

            for (var i:int = 0; i < _playerManager.players.length; ++i) {
                var p:Player = _playerManager.players[i];
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

                if (_playerManager.players.length == 1) {
                    createWaitingField();
                }
            }
        }

        private function onCountdownTimer(e:TimerEvent):void {
            --_secondsLeft;
            _countdownField.text = _secondsLeft.toString();
        }

        public function set es(value:ElectroServer):void {
            _es = value;
        }

        public function set room(value:Room):void {
            _room = value;
        }

    }

}
