package com.litl.racer15
{
    import com.electrotank.electroserver5.ElectroServer;
    import com.electrotank.electroserver5.api.EsObject;
    import com.electrotank.electroserver5.api.LeaveRoomRequest;
    import com.electrotank.electroserver5.api.MessageType;
    import com.electrotank.electroserver5.api.PluginMessageEvent;
    import com.electrotank.electroserver5.api.PluginRequest;
    import com.electrotank.electroserver5.zone.Room;
    import com.litl.racer15.elements.Background;
    import com.litl.racer15.elements.Car;
    import com.litl.racer15.player.Player;
    import com.litl.racer15.player.PlayerManager;

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
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class Racer15Game extends Sprite
    {
        public static const BACK_TO_LOBBY:String = "backToLobby";

        private var _es:ElectroServer;
        private var _room:Room;
        private var _playerManager:PlayerManager;
        private var _playerListUI:List;

        private var _itemsHolder:Sprite;
        private var _car:Car;

        private var _myUsername:String;

        private var _countdownField:TextField;
        private var _countdownTimer:Timer;
        private var _secondsLeft:int;
        private var _gameStarted:Boolean;

        private var _lastTimeSent:int;
        private var _okToSendMousePosition:Boolean;
        private var _waitingField:TextField;

        public function Racer15Game() {
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(e:Event):void {
            // stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            // stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoved);
        }

        public function initialize():void {
            _gameStarted = false;
            _lastTimeSent = -1;
            _okToSendMousePosition = true;
            addEventListener(Event.ENTER_FRAME, run);

            //add a background
            var track:Background = new Background();
            track.x -= track.width - 1500;
            track.y -= track.height - 475;
            addChild(track);

            //add the player list UI
            _playerListUI = new List();
            _playerListUI.x = 650;
            _playerListUI.y = 10;
            _playerListUI.width = 800 - _playerListUI.x - 10;
            addChild(_playerListUI);

            //create a container for items that are added
            //_itemsHolder = new MovieClip();
            //addChild(_itemsHolder);

            //add mouse follower
            _car = new Car();
            addChild(_car);

            _es.engine.addEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);
            _myUsername = _es.managerHelper.userManager.me.userName;
            _playerManager = new PlayerManager();

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
                    //handleStartCountdown(esob);
                    trace("start countdown");
                    break;
                case PluginConstants.STOP_COUNTDOWN:
                    //handleStopCountdown(esob);
                    trace("stop countdown");
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
                    trace("handleAddPlayer(esob);");
                    break;
                case PluginConstants.REMOVE_PLAYER:
                    handleRemovePlayer(esob);
                    trace("handleRemovePlayer(esob);");
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
                dp.addItem({ label: p.name + ", score: " + p.score.toString(), data: p });
            }

            _playerListUI.dataProvider = dp;
        }

        public function set es(value:ElectroServer):void {
            _es = value;
        }

        public function set room(value:Room):void {
            _room = value;
        }

    }

}
