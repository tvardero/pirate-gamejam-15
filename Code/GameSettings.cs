using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace SunfallGame.Code;

public class GameSettings : INotifyPropertyChanged
{
    private float _sfxVolume = 1f;
    private float _musicVolume = 1f;

    public float SfxVolume { get => _sfxVolume; set => SetField(ref _sfxVolume, value); }

    public float MusicVolume { get => _musicVolume; set => SetField(ref _musicVolume, value); }

    public event PropertyChangedEventHandler? PropertyChanged;

    protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    protected bool SetField<T>(ref T field, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(field, value)) return false;

        field = value;
        OnPropertyChanged(propertyName);
        return true;
    }
}
