using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.CapaLogica
{
    internal class LogTrabajador
    {
        #region Singleton

        public static readonly LogTrabajador _instancia = new LogTrabajador();

        public static LogTrabajador Instancia
        {
            get { return LogTrabajador._instancia; }
        }

        #endregion
    }
}
