using HealthGym.CapaDatos;
using HealthGym.CapaEntidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaLogica
{
    public class LogDisponibilidad
    {
        // Singleton
        private static readonly LogDisponibilidad _instancia = new LogDisponibilidad();
        public static LogDisponibilidad Instancia
        {
            get { return _instancia; }
        }
        private LogDisponibilidad() { }

        // Listar Recursos
        public List<EntRecursoLookup> ListarRecursos()
        {
            return DatDisponibilidad.Instancia.ListarRecursos();
        }

        // Listar Disponibilidad por Recurso
        public List<EntDisponibilidad> ListarDisponibilidadPorRecurso(int recursoId)
        {
            return DatDisponibilidad.Instancia.ListarDisponibilidadPorRecurso(recursoId);
        }

        // Insertar Disponibilidad
        public bool InsertarDisponibilidad(EntDisponibilidad d)
        {
            if (d.Fin <= d.Inicio)
            {
                throw new Exception("La fecha/hora final debe ser mayor a la inicial");
            }
            return DatDisponibilidad.Instancia.InsertarDisponibilidad(d);
        }

        // Editar Disponibilidad
        public bool EditarDisponibilidad(EntDisponibilidad d)
        {
            if (d.Fin <= d.Inicio)
            {
                throw new Exception("La fecha/hora final debe ser mayor a la inicial");
            }
            return DatDisponibilidad.Instancia.EditarDisponibilidad(d);
        }

        // Eliminar Disponibilidad
        public bool EliminarDisponibilidad(int id)
        {
            return DatDisponibilidad.Instancia.EliminarDisponibilidad(id);
        }
    }
}
