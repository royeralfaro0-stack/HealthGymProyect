using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaDatos
{
    internal class DatTrabajador
    {
        #region Singleton

        private static readonly DatTrabajador _instancia = new DatTrabajador();

        public static DatTrabajador Instancia
        {
            get { return DatTrabajador._instancia; }
        }

        #endregion

        #region Metodos



        #endregion
    }
}
