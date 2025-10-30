using System;
using System.Drawing.Text;
using Microsoft.Data.SqlClient;

public class Conexion
{
    // Patrón de Diseño Singleton
    private static readonly Conexion _instancia = new Conexion();
    public static Conexion Instancia
    {
        get { return _instancia; }
    }
    private Conexion() { }

    public SqlConnection Conectar()
    {
        SqlConnection cn = new SqlConnection();

    
        cn.ConnectionString = "Data Source=LAPTOP-30QQEM1I; Initial Catalog=MOANSOGYM; Integrated Security=true;TrustServerCertificate=True;";


        return cn;
    }
}