package com.litl.racer15
{
    import com.electrotank.electroserver5.ElectroServer;
    import com.electrotank.electroserver5.api.MessageType;
    import com.electrotank.electroserver5.zone.Room;
    import com.litl.racer15.player.Player;
    import com.litl.racer15.player.PlayerManager;

    import fl.controls.List;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class Racer15Game extends Sprite
    {
        private var _es:ElectroServer;
        private var _room:Room;
        private var _playerManager:PlayerManager;
        private var _playerListUI:List;

        private var _itemsHolder:Sprite;
        //private var _trowel:Trowel;

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
            //var bg:Background = new Background();
            //addChild(bg);

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
            //_trowel = new Trowel();
            //addChild(_trowel);

            //hide the mouse
            //Mouse.hide();

            _es.engine.addEventListener(MessageType.PluginMessageEvent.name, onPluginMessageEvent);

            _myUsername = _es.managerHelper.userManager.me.userName;

            _playerManager = new PlayerManager();

            //createWaitingField();

            //sendInitializeMe();
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
                //sendMousePosition();

                //send my position
            }

            for (var i:int = 0; i < _playerManager.players.length; ++i) {
                var p:Player = _playerManager.players[i];

                if (!p.isMe) {
                    //p.trowel.run();
                }
            }
        }
    }
}
