using System;

public class LogMiembro
{
    #region Singleton

    public static readonly LogMiembro _instancia = new LogMiembro();

    public static LogMiembro Instancia
    {
        get { return LogMiembro._instancia; }
    }

    #endregion
}
