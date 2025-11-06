using System;
using System.Drawing.Text;
using Microsoft.Data.SqlClient;


public class Conexion
{
    private static readonly Conexion _instancia = new Conexion();
    public static Conexion Instancia
    {
        get { return Conexion._instancia; }
    }

    public SqlConnection Conectar()
    {
        SqlConnection cn = new SqlConnection(
            "Server=localhost;" +
            "Database=HealthGym;" +
            "Integrated Security=True;" +
            "TrustServerCertificate=True;" +
            "Encrypt=False;"+
            "user=sa; password=12345678;");
        return cn;
    }
}
