package com.litl.lobby
{
    import com.electrotank.electroserver5.ElectroServer;
    import com.electrotank.electroserver5.api.ConnectionClosedEvent;
    import com.electrotank.electroserver5.api.ConnectionResponse;
    import com.electrotank.electroserver5.api.ErrorType;
    import com.electrotank.electroserver5.api.LoginRequest;
    import com.electrotank.electroserver5.api.LoginResponse;
    import com.electrotank.electroserver5.api.MessageType;
    import com.electrotank.electroserver5.zone.Room;
    import com.litl.lobby.ui.ErrorScreen;
    import com.litl.lobby.ui.LoginScreen;
    import com.litl.racer15.Racer15Game;

    import flash.display.Loader;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;

    /**
     * ...
     * @author Jobe Makar - jobe@electrotank.com
     */
    public class LobbyFlow extends MovieClip
    {

        private var _es:ElectroServer;
        private var _lobby:Lobby;

        private var _game:Racer15Game;

        public function LobbyFlow() {
            initialize();
        }

        private function initialize():void {
            //create a new ElectroServer instance
            _es = new ElectroServer();
            _es.loadAndConnect("settings.xml");

            //add event listeners - new format is _es.engine.addEventListener(MessageType.LoginResponse.name, onLoginResponse);
            _es.engine.addEventListener(MessageType.ConnectionResponse.name, onConnectionResponse);
            _es.engine.addEventListener(MessageType.LoginResponse.name, onLoginResponse);
            _es.engine.addEventListener(MessageType.ConnectionClosedEvent.name, onConnectionClosed);
        }

        /**
         * Called when a user is connected and logged in. It creates a chat room screen.
         */
        private function createLobby():void {
            _lobby = new Lobby();
            _lobby.addEventListener(Lobby.JOINED_GAME, onJoinedGame);
            _lobby.es = _es;
            _lobby.initialize();
            addChild(_lobby);
        }

        /**
         * If the Lobby says you joined a game, then remove the lobby and create the game.
         */
        private function onJoinedGame(e:Event):void {
            //create a new game and give it the ElectroServer reference as well as a room
            _game = new Racer15Game();
            _game.es = _es;
            _game.room = _lobby.gameRoom;

            //listen for when the game is done
            _game.addEventListener(Racer15Game.BACK_TO_LOBBY, onDigGameBackToLobby);

            //initialize the game and add it to the screen
            _game.initialize();
            addChild(_game);

            //tell the lobby it is about to be removed (it will clean up), then remove it
            _lobby.destroy();
            removeChild(_lobby);
            _lobby = null;
        }

        /**
         * Called when the game says it is done. Remove the game, create the lobby.
         */
        private function onDigGameBackToLobby(e:Event):void {
            //destroy and remove the game
            _game.destroy();
            removeChild(_game);
            _game.removeEventListener(Racer15Game.BACK_TO_LOBBY, onDigGameBackToLobby);
            _game = null;

            //create the lobby
            createLobby();
        }

        /**
         * This is used to display an error if one occurs
         */
        private function showError(msg:String):void {
            var alert:ErrorScreen = new ErrorScreen(msg);
            alert.x = 300;
            alert.y = 200;
            alert.addEventListener(ErrorScreen.OK, onErrorScreenOk);
            addChild(alert);
        }

        /**
         * Called as the result of an OK event on an error screen. Removes the error screen.
         */
        private function onErrorScreenOk(e:Event):void {
            var alert:ErrorScreen = e.target as ErrorScreen;
            alert.removeEventListener(ErrorScreen.OK, onErrorScreenOk);
            removeChild(alert);
        }

        /**
         * Called when a connection attempt has succeeded or failed
         */
        public function onConnectionResponse(e:ConnectionResponse):void {
            if (e.successful) {
                createLoginScreen();
            }
            else {
                showError("Failed to connect.");
            }
        }

        /**
         * Creates a screen where a user can enter a username
         */
        private function createLoginScreen():void {
            var login:LoginScreen = new LoginScreen();
            login.x = 400 - login.width / 2;
            login.y = 300 - login.height / 2;
            addChild(login);

            login.addEventListener(LoginScreen.OK, onLoginSubmit);
        }

        /**
         * Called as a result of the OK event on the login screen. Creates and sends a login request to the server
         */
        private function onLoginSubmit(e:Event):void {
            var screen:LoginScreen = e.target as LoginScreen;

            //create the request
            var lr:LoginRequest = new LoginRequest();
            lr.userName = screen.username;

            //send it
            _es.engine.send(lr);

            screen.removeEventListener(LoginScreen.OK, onLoginSubmit);
            removeChild(screen);
        }

        /**
         * Called when the server responds to the login request. If successful, create the chat room screen
         */
        public function onLoginResponse(e:LoginResponse):void {
            if (e.successful) {
                createLobby();
            }
            else {
                showError(e.error.name);
            }
        }

        public function onConnectionClosed(e:ConnectionClosedEvent):void {
            showError("Connection was closed");
        }

    }

}
