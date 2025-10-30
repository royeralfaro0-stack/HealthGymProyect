using HealthGym.CapaEntidad;
using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaDatos
{
    public class DatDisponibilidad
    {
        // Singleton
        private static readonly DatDisponibilidad _instancia = new DatDisponibilidad();
        public static DatDisponibilidad Instancia
        {
            get { return _instancia; }
        }
        private DatDisponibilidad() { }

        // Método para listar Recursos (para el ComboBox)
        public List<EntRecursoLookup> ListarRecursos()
        {
            SqlCommand cmd = null;
            List<EntRecursoLookup> lista = new List<EntRecursoLookup>();
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spListarRecursosDeportivos", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    lista.Add(new EntRecursoLookup
                    {
                        Id = Convert.ToInt32(dr["Id"]),
                        Nombre = dr["Nombre"].ToString()
                    });
                }
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return lista;
        }

        // Método para listar Disponibilidad de un Recurso
        public List<EntDisponibilidad> ListarDisponibilidadPorRecurso(int recursoId)
        {
            SqlCommand cmd = null;
            List<EntDisponibilidad> lista = new List<EntDisponibilidad>();
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spListarDisponibilidadPorRecurso", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@RecursoId", recursoId);
                cn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    lista.Add(new EntDisponibilidad
                    {
                        Id = Convert.ToInt32(dr["Id"]),
                        RecursoId = Convert.ToInt32(dr["Recurso"]),
                        Inicio = Convert.ToDateTime(dr["Inicio"]),
                        Fin = Convert.ToDateTime(dr["Fin"])
                    });
                }
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return lista;
        }

        // Método para Insertar Disponibilidad
        public bool InsertarDisponibilidad(EntDisponibilidad d)
        {
            SqlCommand cmd = null;
            bool inserta = false;
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spInsertarDisponibilidadRecurso", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Recurso", d.RecursoId);
                cmd.Parameters.AddWithValue("@Inicio", d.Inicio);
                cmd.Parameters.AddWithValue("@Fin", d.Fin);
                cn.Open();
                int i = cmd.ExecuteNonQuery();
                if (i > 0) inserta = true;
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return inserta;
        }

        // Método para Editar Disponibilidad
        public bool EditarDisponibilidad(EntDisponibilidad d)
        {
            SqlCommand cmd = null;
            bool edita = false;
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spEditarDisponibilidadRecurso", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Id", d.Id);
                cmd.Parameters.AddWithValue("@Inicio", d.Inicio);
                cmd.Parameters.AddWithValue("@Fin", d.Fin);
                cn.Open();
                int i = cmd.ExecuteNonQuery();
                if (i > 0) edita = true;
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return edita;
        }

        // Método para Eliminar Disponibilidad
        public bool EliminarDisponibilidad(int id)
        {
            SqlCommand cmd = null;
            bool elimina = false;
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spEliminarDisponibilidadRecurso", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Id", id);
                cn.Open();
                int i = cmd.ExecuteNonQuery();
                if (i > 0) elimina = true;
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return elimina;
        }
    }
}
