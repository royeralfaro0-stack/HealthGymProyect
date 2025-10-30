namespace HealthGym
{
    public partial class Inicio : Form
    {
        public Inicio()
        {
            InitializeComponent();
        }

        private void btnGestionarHorarios_Click(object sender, EventArgs e)
        {

            HealthGym.MantenedorHorario formHorario = new HealthGym.MantenedorHorario();

            formHorario.ShowDialog();
        }

        private void btnGestionarRecursos_Click(object sender, EventArgs e)
        {
            // Creamos una instancia de tu nuevo formulario
            HealthGym.MantenedorDisponibilidad formRecursos = new HealthGym.MantenedorDisponibilidad();

            // Lo mostramos
            formRecursos.ShowDialog();
        }
    }
}
