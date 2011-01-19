package
{

    import com.litl.lobby.LobbyFlow;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    public class Main extends Sprite
    {
        public function Main() {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;

            //create the chat flow
            var lobbyFlow:LobbyFlow = new LobbyFlow();
            addChild(lobbyFlow);
        }
    }
}
