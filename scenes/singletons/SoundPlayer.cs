using Godot;
using System;

public partial class SoundPlayer : Node
{
    public static SoundPlayer Instance { get; private set; }

    [Export]
    private Node AudioPlayers;

    [Export]
    private Node AudioPlayers2D;
    
    [Export]
    private AudioStreamPlayer PresentMusicPlayer;
    
    [Export]
    private AudioStreamPlayer PastMusicPlayer;
    
    private int SfxPresentBus;
    
    private int SfxPastBus;

    private float _musicPosition = 0f;
    private float _fadeSpeed = 0f;

    public override void _Ready()
    {
        Instance = this;

        SfxPresentBus = AudioServer.GetBusIndex("SFX Present");
        SfxPastBus = AudioServer.GetBusIndex("SFX Past");
    }

    public override void _PhysicsProcess(double delta)
    {
        if (_fadeSpeed == 0) return;

        float increment = _fadeSpeed * (float)delta;
	
        // Convert linear progress to decibels
        float presentProg = Mathf.Clamp(Mathf.DbToLinear(PresentMusicPlayer.VolumeDb) + increment, 0, 1);
        float presentDB = Mathf.Clamp(Mathf.LinearToDb(presentProg), -80, 0);
        
        float pastProg = Mathf.Clamp(Mathf.DbToLinear(PastMusicPlayer.VolumeDb) - increment, 0, 1);
        float pastDB = Mathf.Clamp(Mathf.LinearToDb(pastProg), -80, 0);

        PresentMusicPlayer.VolumeDb = presentDB;
        PastMusicPlayer.VolumeDb = pastDB;

        AudioServer.SetBusVolumeDb(SfxPresentBus, presentDB);
        AudioServer.SetBusVolumeDb(SfxPastBus, pastDB);
    }

    public AudioStreamPlayer PlaySound(AudioStream sound, float volume =0)
    {
        foreach (AudioStreamPlayer audioPlayer in AudioPlayers.GetChildren())
        {
            if (audioPlayer.Playing) continue;

            ResetSfxPlayer(audioPlayer);
            audioPlayer.Stream = sound;
            audioPlayer.VolumeDb = volume;
            audioPlayer.Play();

            return audioPlayer;
        }

        return null;
    }

    public AudioStreamPlayer2D PlaySound2D(AudioStream sound, Vector2 pos, float volume =0)
    {
        foreach (AudioStreamPlayer2D audioPlayer in AudioPlayers2D.GetChildren())
        {
            if (audioPlayer.Playing) continue;

            ResetSfxPlayer(audioPlayer);
            audioPlayer.Stream = sound;
            audioPlayer.VolumeDb = volume;
            audioPlayer.Position = pos;
            audioPlayer.Play();

            return audioPlayer;
        }

        return null;
    }

    public void PlayMusic(AudioStream presentTrack, AudioStream pastTrack)
    {
        if (PresentMusicPlayer.Stream == presentTrack)  return;
	
	    SetTime(WorldState.Instance.InFuture);

        PresentMusicPlayer.Stream = presentTrack;
        PastMusicPlayer.Stream = pastTrack;
        PresentMusicPlayer.Play();
        PastMusicPlayer.Play();
    }

    public void PauseMusic(bool flag)
    {
        if (flag)
        {
            _musicPosition = PresentMusicPlayer.GetPlaybackPosition();
            PresentMusicPlayer.Stop();
            PastMusicPlayer.Stop();
        }
        else
        {
            PresentMusicPlayer.Play(_musicPosition);
            PastMusicPlayer.Play(_musicPosition);
        }
    }

    public void StopMusic()
    {
        PresentMusicPlayer.Stop();
        PresentMusicPlayer.Stream = null;

        PastMusicPlayer.Stop();
        PastMusicPlayer.Stream = null;
    }

    public void StopAllSfx()
    {
        foreach(AudioStreamPlayer player in AudioPlayers.GetChildren())
        {
            ResetSfxPlayer(player);
        }

        foreach(AudioStreamPlayer2D player2D in AudioPlayers2D.GetChildren())  
        {
            ResetSfxPlayer(player2D);
        }
    }

    private void SetTime(bool inFuture, float fadeSeconds = 0f)
    {
        if (fadeSeconds <= 0)
        {
            float presentValue = (inFuture ? 0f : 80f);
            float pastValue = (inFuture ? -80f : 0f);

            PresentMusicPlayer.VolumeDb = presentValue;
            PastMusicPlayer.VolumeDb = pastValue;

            AudioServer.SetBusVolumeDb(SfxPresentBus, presentValue);
            AudioServer.SetBusVolumeDb(SfxPastBus, pastValue);

            return;
        }

	    // Calculate fade speed per second, from 0db to -80db
        _fadeSpeed = (inFuture ? 1.0f : -1.0f) / fadeSeconds;
    }
    
    private void SetTimeBus(AudioStreamPlayer2D soundPlayer, bool inFuture)
    {
        if (inFuture) 
        {
            soundPlayer.Bus = "SFX Present";
        }
        else
        {
            soundPlayer.Bus = "SFX Past";
        }
    }

    private void ResetSfxPlayer(Node sfxPlayerNode)
    {
        if (sfxPlayerNode is AudioStreamPlayer sfxPlayer)
        {
            sfxPlayer.Stop();
            sfxPlayer.Bus = "SFX";
            sfxPlayer.PitchScale = 1.0f;
        
            if (sfxPlayerNode is AudioStreamPlayer2D sfxPlayer2D)
            {
                sfxPlayer2D.MaxDistance = 2000;
            }
        }
    }
}
