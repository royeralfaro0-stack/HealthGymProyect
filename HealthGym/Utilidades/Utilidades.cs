using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HealthGym.Utilidades
{
    internal class Utilidades
    {
        #region Singleton
        public static readonly Utilidades _instancia = new Utilidades();

        public static Utilidades Instancia
        {
            get { return Utilidades._instancia; }
        }
        #endregion

        public bool ValidarPorcentaje(double num)
        {
            return (
                num <= 100
                &&
                num > 0
                );
        }
    }
}
