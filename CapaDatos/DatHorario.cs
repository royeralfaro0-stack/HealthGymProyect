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
    public class DatHorario
    {
        // Singleton
        private static readonly DatHorario _instancia = new DatHorario();
        public static DatHorario Instancia
        {
            get { return _instancia; }
        }
        private DatHorario() { }

        // Método para listar Coaches (para el ComboBox)
        public List<EntCoachLookup> ListarCoaches()
        {
            SqlCommand cmd = null;
            List<EntCoachLookup> lista = new List<EntCoachLookup>();
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spListarCoaches", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    lista.Add(new EntCoachLookup
                    {
                        Id = Convert.ToInt32(dr["Id"]),
                        NombreCompleto = dr["NombreCompleto"].ToString()
                    });
                }
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return lista;
        }

   
        public List<EntHorario> ListarHorariosPorCoach(int coachId) // <--- Variable coachId
        {
            SqlCommand cmd = null;
            List<EntHorario> lista = new List<EntHorario>();
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spListarHorariosPorCoach", cn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@coachId", coachId); // <--- Línea agregada
            
                cn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    lista.Add(new EntHorario
                    {
                        Id = Convert.ToInt32(dr["Id"]),
                        TrabajadorId = Convert.ToInt32(dr["TrabajadorId"]),
                        Dia = dr["Dia"].ToString(),
                        HoraInicio = (TimeSpan)dr["HoraInicio"],
                        HoraFin = (TimeSpan)dr["HoraFin"]
                    });
                }
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return lista;
        }

        // Método para Insertar Horario
        public bool InsertarHorario(EntHorario h)
        {
            SqlCommand cmd = null;
            bool inserta = false;
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spInsertarHorario", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TrabajadorId", h.TrabajadorId);
                cmd.Parameters.AddWithValue("@Dia", h.Dia);
                cmd.Parameters.AddWithValue("@HoraInicio", h.HoraInicio);
                cmd.Parameters.AddWithValue("@HoraFin", h.HoraFin);
                cn.Open();
                int i = cmd.ExecuteNonQuery();
                if (i > 0) inserta = true;
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return inserta;
        }

        // Método para Editar Horario
        public bool EditarHorario(EntHorario h)
        {
            SqlCommand cmd = null;
            bool edita = false;
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spEditarHorario", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Id", h.Id);
                cmd.Parameters.AddWithValue("@Dia", h.Dia);
                cmd.Parameters.AddWithValue("@HoraInicio", h.HoraInicio);
                cmd.Parameters.AddWithValue("@HoraFin", h.HoraFin);
                cn.Open();
                int i = cmd.ExecuteNonQuery();
                if (i > 0) edita = true;
            }
            catch (Exception e) { throw e; }
            finally { if (cmd != null && cmd.Connection != null) cmd.Connection.Close(); }
            return edita;
        }

        // Método para Eliminar Horario
        public bool EliminarHorario(int horarioId)
        {
            SqlCommand cmd = null;
            bool elimina = false;
            try
            {
                SqlConnection cn = Conexion.Instancia.Conectar();
                cmd = new SqlCommand("spEliminarHorario", cn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Id", horarioId);
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
