using HealthGym.CapaDatos;
using HealthGym.CapaEntidad;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaLogica
{
    public class LogHorario
    {
        // Singleton
        private static readonly LogHorario _instancia = new LogHorario();
        public static LogHorario Instancia
        {
            get { return _instancia; }
        }
        private LogHorario() { }

        // Listar Coaches
        public List<EntCoachLookup> ListarCoaches()
        {
            return DatHorario.Instancia.ListarCoaches();
        }

        // Listar Horarios por Coach
        public List<EntHorario> ListarHorariosPorCoach(int trabajadorId)
        {
            return DatHorario.Instancia.ListarHorariosPorCoach(trabajadorId);
        }

        // Insertar Horario
        public bool InsertarHorario(EntHorario horario)
        {
            if (horario.HoraFin <= horario.HoraInicio)
            {
                throw new System.Exception("La hora final debe ser mayor a la inicial");
            }
            return DatHorario.Instancia.InsertarHorario(horario);
        }

        // Editar Horario
        public bool EditarHorario(EntHorario horario)
        {
            if (horario.HoraFin <= horario.HoraInicio)
            {
                throw new System.Exception("La hora final debe ser mayor a la inicial");
            }
            return DatHorario.Instancia.EditarHorario(horario);
        }

        // Eliminar Horario
        public bool EliminarHorario(int horarioId)
        {
            return DatHorario.Instancia.EliminarHorario(horarioId);
        }
    }
}
