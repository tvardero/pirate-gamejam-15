using Godot;
using System;
using System.Collections.Generic;

public partial class WorldState : Node
{
    public static WorldState Instance { get; private set; }

    public bool InFuture = true;
    public bool DisableMovement = false;
    public Dictionary<string, PackedScene> SavedLevelStates = new Dictionary<string, PackedScene>();

    public int StarFragmentCount  = 0;
    public bool PolicemanMoved = false;
    public bool Town1GateOpen = false;
    public bool NewspaperPickedUp = false;
    public bool PasswordFound = false;
    public bool SewageValveOff = false;

    public override void _Ready()
    {
        Instance = this;
    } 

    public void Reset()
    {
        InFuture = true;
        SavedLevelStates.Clear();
        StarFragmentCount = 0;
        PolicemanMoved = false;
        Town1GateOpen = false;
        NewspaperPickedUp = false;
        PasswordFound = false;
        SewageValveOff = false;        
    }

    public void TransitPlayerToScene(PackedScene destination, int spawnID, Vector2 direction)
    {
        DisableMovement = true;
        // DialogState.disabled = true
        // scene_transition_visual.start()
        
        // var level = load_level_state(destination);
        // if !(level is Level):
        //     assert(false, "Invalid destination scene provided, should extend class 'Level'");
        
        // await scene_transition_visual.halfway
        
        // var current = GetCurrentLevel();
        // if current:
        //     save_level_state(current)
        //     current.visible = false;
        //     current.queue_free();
        // SoundPlayer.stop_all_sfx()
        
        // level.spawn_player_at(spawn_id, player_direction);
        // get_tree().root.call_deferred("add_child", level);
        
        // await scene_transition_visual.finished
        
        // DisableMovement = false;
        // DialogState.disabled = false
    }

}
