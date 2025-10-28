using System;

public class DatMiembro
{
    #region Singleton

    private static readonly DatMiembro _instancia = new DatMiembro();

    public static DatMiembro Instancia
    {
        get { return DatMiembro._instancia; }
    }

    #endregion

    #region Metodos



    #endregion
}
