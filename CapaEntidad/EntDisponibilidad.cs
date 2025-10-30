using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaEntidad
{
    // Clase para la tabla (DataGridView) de Disponibilidad
    public class EntDisponibilidad
    {
        public int Id { get; set; }
        public int RecursoId { get; set; }
        public DateTime Inicio { get; set; } // 'datetime' de SQL se mapea a 'DateTime'
        public DateTime Fin { get; set; }
    }
}
