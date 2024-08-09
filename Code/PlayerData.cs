namespace SunfallGame.Code;

public class PlayerData
{
    public PlayerData(string saveName)
    {
        SaveName = saveName;
    }

    #region Header

    public string SaveName { get; set; }
    public string SaveFileName { get; } = $"{Guid.NewGuid():N}.json";
    public DateTimeOffset CreatedAt { get; } = DateTimeOffset.Now;

    #endregion

    #region Data

    public string CurrentLevelPackedScenePath { get; set; } = string.Empty;
    public int CurrentLevelSpawnPointId { get; set; }
    public bool InFuture { get; private set; } = true;
    public bool NewspaperPickedUp { get; set; }
    public bool PolicemanQuestActive { get; set; }

    #endregion

    public void SetTime(bool toFuture)
    {
        InFuture = toFuture;
    }

    public void SwitchTime()
    {
        SetTime(!InFuture);
    }
}
