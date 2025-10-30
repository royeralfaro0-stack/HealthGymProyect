using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaEntidad
{
    public class EntHorario
    {
        public int Id { get; set; }
        public int TrabajadorId { get; set; }
        public string Dia { get; set; }
        public TimeSpan HoraInicio { get; set; } // 'time' de SQL se mapea a 'TimeSpan'
        public TimeSpan HoraFin { get; set; }
    }

    // Entidad simple para el ComboBox de Coaches
    public class EntCoachLookup
    {
        public int Id { get; set; }
        public string NombreCompleto { get; set; }

        public override string ToString()
        {
            return NombreCompleto;
        }
    }
}
