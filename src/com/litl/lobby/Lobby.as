package com.litl.lobby
{

    //ElectroServer imports
    import com.electrotank.electroserver5.ElectroServer;
    import com.electrotank.electroserver5.api.CreateOrJoinGameResponse;
    import com.electrotank.electroserver5.api.CreateRoomRequest;
    import com.electrotank.electroserver5.api.ErrorType;
    import com.electrotank.electroserver5.api.FindGamesRequest;
    import com.electrotank.electroserver5.api.FindGamesResponse;
    import com.electrotank.electroserver5.api.GenericErrorResponse;
    import com.electrotank.electroserver5.api.JoinGameRequest;
    import com.electrotank.electroserver5.api.JoinRoomEvent;
    import com.electrotank.electroserver5.api.LeaveRoomEvent;
    import com.electrotank.electroserver5.api.LeaveRoomRequest;
    import com.electrotank.electroserver5.api.MessageType;
    import com.electrotank.electroserver5.api.PrivateMessageEvent;
    import com.electrotank.electroserver5.api.PrivateMessageRequest;
    import com.electrotank.electroserver5.api.PublicMessageEvent;
    import com.electrotank.electroserver5.api.PublicMessageRequest;
    import com.electrotank.electroserver5.api.QuickJoinGameRequest;
    import com.electrotank.electroserver5.api.SearchCriteria;
    import com.electrotank.electroserver5.api.ServerGame;
    import com.electrotank.electroserver5.api.UserUpdateEvent;
    import com.electrotank.electroserver5.api.ZoneUpdateEvent;
    import com.electrotank.electroserver5.user.User;
    import com.electrotank.electroserver5.zone.Room;
    import com.electrotank.electroserver5.zone.Zone;
//    import com.gamebook.dig.PluginConstants;
    import com.litl.lobby.ui.CreateRoomScreen;
    import com.litl.lobby.ui.MyTextLabel;
    import com.litl.lobby.ui.PopuupBackground;

    import fl.controls.Button;
    import fl.controls.List;
    import fl.controls.TextArea;
    import fl.controls.TextInput;
    import fl.data.DataProvider;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class Lobby extends MovieClip
    {

        public static const JOINED_GAME:String = "joinedGame";

        //ElectroServer instance
        private var _es:ElectroServer;

        //room you are in
        private var _room:Room;

        private var _gameRoom:Room;

        //UI components
        private var _userList:List;
        private var _gameList:List;
        private var _history:TextArea;
        private var _message:TextInput;
        private var _joinGame:Button;
        private var _send:Button;

        //chat room label
        private var _chatRoomLabel:MyTextLabel;

        //screen used to allow a user to create a screen
        private var _joinGameScreen:CreateRoomScreen;

        private var _gameListRefreshTimer:Timer;
        private var _quickJoinGame:Button;
        private var _pendingRoomName:String;

        public function Lobby() {

        }

        public function initialize():void {
            //add ElectroServer listeners- new format is _es.engine.addEventListener(MessageType.LoginResponse.name, onLoginResponse);
            _es.engine.addEventListener(MessageType.JoinRoomEvent.name, onJoinRoomEvent);
            _es.engine.addEventListener(MessageType.PublicMessageEvent.name, onPublicMessageEvent);
            _es.engine.addEventListener(MessageType.PrivateMessageEvent.name, onPrivateMessageEvent);
            _es.engine.addEventListener(MessageType.UserUpdateEvent.name, onUserUpdateEvent);
            _es.engine.addEventListener(MessageType.FindGamesResponse.name, onFindGamesResponse);
            _es.engine.addEventListener(MessageType.GenericErrorResponse.name, onGenericErrorResponse);
            _es.engine.addEventListener(MessageType.CreateOrJoinGameResponse.name, onCreateOrJoinGameResponse);

            _gameListRefreshTimer = new Timer(2000);
            _gameListRefreshTimer.start();
            _gameListRefreshTimer.addEventListener(TimerEvent.TIMER, onGameListRefreshTimer);

            //build UI elements
            buildUIElements();

            //join a default room
            joinRoom("Lobby");
        }

        public function destroy():void {
            var lrr:LeaveRoomRequest = new LeaveRoomRequest();
            lrr.roomId = _room.id;
            lrr.zoneId = _room.zoneId;
            _es.engine.send(lrr);

            _es.engine.removeEventListener(MessageType.JoinRoomEvent.name, onJoinRoomEvent);
            _es.engine.removeEventListener(MessageType.PublicMessageEvent.name, onPublicMessageEvent);
            _es.engine.removeEventListener(MessageType.PrivateMessageEvent.name, onPrivateMessageEvent);
            _es.engine.removeEventListener(MessageType.UserUpdateEvent.name, onUserUpdateEvent);
            _es.engine.removeEventListener(MessageType.FindGamesResponse.name, onFindGamesResponse);
            _es.engine.removeEventListener(MessageType.GenericErrorResponse.name, onGenericErrorResponse);
            _es.engine.removeEventListener(MessageType.CreateOrJoinGameResponse.name, onCreateOrJoinGameResponse);

        }

        private function quickJoin():void {
            _quickJoinGame.enabled = false;

            var qjr:QuickJoinGameRequest = new QuickJoinGameRequest();
//            qjr.gameType = PluginConstants.GAME_NAME;
            qjr.zoneName = "GameZone";
            qjr.createOnly = false;
            _es.engine.send(qjr);
        }

        private function joinGame(serverGame:ServerGame):void {
            var jgr:JoinGameRequest = new JoinGameRequest();
            jgr.gameId = serverGame.id;
            _es.engine.send(jgr);
        }

        public function onCreateOrJoinGameResponse(e:CreateOrJoinGameResponse):void {
            if (e.successful) {
                _gameRoom = new Room();
                _gameRoom.id = e.roomId;
                _gameRoom.zoneId = e.zoneId;

                dispatchEvent(new Event(JOINED_GAME));
            }
            else {
                _quickJoinGame.enabled = true;
                trace(e.error.name);

                if (e.error == ErrorType.GameDoesntExist) {
                    trace("This game hasn't been registered with the server. Do that first.");
                }
            }
        }

        /**
         * An error happened on the server because of something the client did. This captures it and traces it.
         */
        public function onGenericErrorResponse(e:GenericErrorResponse):void {
            trace(e.errorType.name);
        }

        /**
         * Request the game list from the server
         */
        private function onGameListRefreshTimer(e:TimerEvent):void {
            //create request
            var fgr:FindGamesRequest = new FindGamesRequest();

            //create search criteria that will filter the game list
            var criteria:SearchCriteria = new SearchCriteria();
// Add in game type
//            criteria.gameType = PluginConstants.GAME_NAME;
            criteria.gameId = -1;

            //add the search criteria to the request
            fgr.searchCriteria = criteria;

            //send it
            _es.engine.send(fgr);
        }

        /**
         * Called when a response is received for the FindGamesRequest
         */
        public function onFindGamesResponse(e:FindGamesResponse):void {
            trace("number games found: " + e.games.length);
            refresGameList(e.games);
        }

        /**
         * Called when a user name in the list is selected
         */
        private function onUserSelected(e:Event):void {
            if (_userList.selectedItem != null) {

                //grab the User object off of the list item
                var user:User = _userList.selectedItem.data as User;

                //add private message syntax to the message entry field
                _message.text = "/" + user.userName + ": ";
            }
        }

        /**
         * Called when the send button is clicked
         */
        private function onSendClick(e:MouseEvent):void {

            //if there is text to send, then proceed
            if (_message.text.length > 0) {

                //get the message to send
                var msg:String = _message.text;

                //check to see if it is a public or private message
                if (msg.charAt(0) == "/" && msg.indexOf(":") != -1) {
                    //private message

                    //parse the message to get who it is meant to go to
                    var to:String = msg.substr(1, msg.indexOf(":") - 1);

                    //parse the message to get the message content and strip out the 'to' value
                    msg = msg.substr(msg.indexOf(":") + 2);

                    //create the request object
                    var prmr:PrivateMessageRequest = new PrivateMessageRequest();
                    prmr.userNames = [ to ];
                    prmr.message = msg;

                    //send it
                    _es.engine.send(prmr);

                }
                else {
                    //public message

                    //create the request object
                    var pmr:PublicMessageRequest = new PublicMessageRequest();
                    pmr.message = _message.text;
                    pmr.roomId = _room.id;
                    pmr.zoneId = _room.zoneId;

                    //send it
                    _es.engine.send(pmr);
                }

                //clear the message input field
                _message.text = "";

                //give the message field focus
                stage.focus = _message;
            }
        }

        /**
         * Attempt to create or join the room specified
         */
        private function joinRoom(roomName:String):void {
            _pendingRoomName = roomName;

            //if currently in a room, leave the room
            if (_room != null) {
                //create the request
                var lrr:LeaveRoomRequest = new LeaveRoomRequest();
                lrr.roomId = _room.id;
                lrr.zoneId = _room.zoneId;

                //send it
                _es.engine.send(lrr);
            }

            //create the request
            var crr:CreateRoomRequest = new CreateRoomRequest();
            crr.roomName = roomName;
            crr.zoneName = "chat";

            //send it
            _es.engine.send(crr);
        }

        /**
         * Called when the server says you joined a room
         */
        public function onJoinRoomEvent(e:JoinRoomEvent):void {
            /*
            This function gets called every time you join a room, including a game. But we only want to react here if you joined a room intended for chat.
            There is another event fired when you join a game, and it is handled here: onCreateOrJoinGameResponse
            */
            //room = _es.managerHelper.zoneManager.zoneById(event.zoneId).roomById(event.roomId);

            var eventRoom:Room = _es.managerHelper.zoneManager.zoneById(e.zoneId).roomById(e.roomId);

            if (eventRoom.name == _pendingRoomName) {
                //the room you joined
                _room = eventRoom;

                //update the display to say the name of the room
                _chatRoomLabel.label_txt.text = eventRoom.name;

                //refresh the lists
                refreshUserList();
            }
        }

        /**
         * Called when you receive a chat message from the room you are in
         */
        public function onPublicMessageEvent(e:PublicMessageEvent):void {

            //add a chat message to the history field
            _history.appendText(e.userName + ": " + e.message + "\n");
        }

        /**
         * Called when you receive a chat message from another user
         */
        public function onPrivateMessageEvent(e:PrivateMessageEvent):void {

            //add a chat message to the history field
            _history.appendText("[private] " + e.userName + ": " + e.message + "\n");
        }

        /**
         * This is called when the user list for the room youa re in changes
         */
        public function onUserUpdateEvent(e:UserUpdateEvent):void {
            refreshUserList();
        }

        /**
         * Used to refresh the names in the user list
         */
        private function refreshUserList():void {
            //get the user list
            var users:Array = _room.users;

            //create a new data provider for the list component
            var dp:DataProvider = new DataProvider();

            //loop through the user list and add each user to the data provider
            for (var i:int = 0; i < users.length; ++i) {
                var user:User = users[i];
                dp.addItem({ label: user.userName, data: user });
            }

            //tell the component to use this data
            _userList.dataProvider = dp;
        }

        /**
         * Used to refresh the games in the game list
         */
        private function refresGameList(games:Array):void {
            var lastSelectedGameId:int = -1;
            var indexToSelect:int = -1;

            if (_gameList.selectedItem != null) {
                lastSelectedGameId = ServerGame(_gameList.selectedItem.data).id;
            }

            //create a new data provider for the list component
            var dp:DataProvider = new DataProvider();

            //loop through the rooom list and add each room to the data provider
            for (var i:int = 0; i < games.length; ++i) {
                var game:ServerGame = games[i];
                var label:String = "Game " + game.id;
                label += " [" + (game.locked ? "full" : "open") + "]";
                dp.addItem({ label: label, data: game });

                if (game.id == lastSelectedGameId) {
                    indexToSelect = i;
                }
            }

            //tell the component to use this data
            _gameList.dataProvider = dp;

            if (indexToSelect > -1) {
                _joinGame.enabled = true;
                _gameList.selectedIndex = indexToSelect;
            }
            else {
                _joinGame.enabled = false;
            }
        }

        /**
         * Add all of the user interface elements
         */
        private function buildUIElements():void {

            //background of the chat history area
            var bg1:PopuupBackground = new PopuupBackground();
            bg1.x = 30;
            bg1.y = 142;
            bg1.width = 428;
            bg1.height = 328;
            addChild(bg1);

            //background of the user list area
            var bg2:PopuupBackground = new PopuupBackground();
            bg2.x = 493;
            bg2.y = 142;
            bg2.width = 260;
            bg2.height = 150;
            addChild(bg2);

            //background of the game list area
            var bg3:PopuupBackground = new PopuupBackground();
            bg3.x = 493;
            bg3.y = 295;
            bg3.width = 260;
            bg3.height = 176;
            addChild(bg3);

            //text label in the chat history area
            var txt1:MyTextLabel = new MyTextLabel();
            txt1.label_txt.text = "Chat";
            txt1.x = 220;
            txt1.y = 160;
            addChild(txt1);
            _chatRoomLabel = txt1;

            //text label in the user list area
            var txt2:MyTextLabel = new MyTextLabel();
            txt2.label_txt.text = "Users";
            txt2.x = 620;
            txt2.y = 160;
            addChild(txt2);

            //text label in the game list area
            var txt3:MyTextLabel = new MyTextLabel();
            txt3.label_txt.text = "Games";
            txt3.x = 625;
            txt3.y = 312;
            addChild(txt3);

            //history TextArea component used to show the chat log
            _history = new TextArea();
            _history.editable = false;
            _history.x = 50;
            _history.y = 181;
            _history.width = 389;
            _history.height = 207;
            addChild(_history);

            //used to allow users to enter new chat messages
            _message = new TextInput();
            _message.x = 50;
            _message.y = 400;
            _message.width = 390;
            addChild(_message);

            //used to send a chat message
            _send = new Button();
            _send.label = "send";
            _send.x = 340;
            _send.y = 430;
            addChild(_send);
            _send.addEventListener(MouseEvent.CLICK, onSendClick);

            //used to display the user list
            _userList = new List();
            _userList.x = 513;
            _userList.y = 170;
            _userList.width = 222;
            _userList.height = 103;
            _userList.addEventListener(Event.CHANGE, onUserSelected);
            addChild(_userList);

            //used to display the game list
            _gameList = new List();
            _gameList.x = 513;
            _gameList.y = 323;
            _gameList.width = 222;
            _gameList.height = 103;
            _gameList.addEventListener(Event.CHANGE, onGameSelected);
            addChild(_gameList);

            //used to launch the create room screen
            _joinGame = new Button();
            _joinGame.addEventListener(MouseEvent.CLICK, onJoinGameClicked);
            _joinGame.x = 634;
            _joinGame.y = 431;
            _joinGame.label = "Join Game";
            addChild(_joinGame);

            _joinGame.enabled = false;

            //used to launch the create room screen
            _quickJoinGame = new Button();
            _quickJoinGame.addEventListener(MouseEvent.CLICK, onQuickJoinClicked);
            _quickJoinGame.x = 513;
            _quickJoinGame.y = 431;
            _quickJoinGame.label = "Quick Join";
            addChild(_quickJoinGame);

        }

        private function onGameSelected(e:Event):void {
            _joinGame.enabled = true;
        }

        private function onJoinGameClicked(e:MouseEvent):void {
            trace(_gameList.selectedItem)

            if (_gameList.selectedItem != null) {
                var serverGame:ServerGame = _gameList.selectedItem.data as ServerGame;
                joinGame(serverGame);
            }
        }

        private function onQuickJoinClicked(e:MouseEvent):void {
            quickJoin();
        }

        public function set es(value:ElectroServer):void {
            _es = value;
        }

        public function get gameRoom():Room {
            return _gameRoom;
        }

    }

}
