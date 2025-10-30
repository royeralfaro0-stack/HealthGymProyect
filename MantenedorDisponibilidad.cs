using HealthGym.CapaEntidad;
using HealthGym.CapaLogica;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace HealthGym
{
    public partial class MantenedorDisponibilidad : Form
    {
        private int? recursoSeleccionadoId = null;

        public MantenedorDisponibilidad()
        {
            InitializeComponent();
            ConfigurarFormulario();
        }

        private void ConfigurarFormulario()
        {
            // Configurar DataGridView
            dgvDisponibilidad.AutoGenerateColumns = false;

            if (dgvDisponibilidad.Columns.Count == 0)
            {
                // --- INICIO DE LA CORRECCIÓN ---
                // Asignamos la propiedad 'Name' a cada columna.
                dgvDisponibilidad.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "Id", // <-- CORRECCIÓN
                    DataPropertyName = "Id",
                    HeaderText = "ID",
                    Width = 50,
                    Visible = false
                });
                dgvDisponibilidad.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "Inicio", // <-- CORRECCIÓN
                    DataPropertyName = "Inicio",
                    HeaderText = "Fecha/Hora Inicio",
                    Width = 150,
                    DefaultCellStyle = { Format = "g" }
                });
                dgvDisponibilidad.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "Fin", // <-- CORRECCIÓN
                    DataPropertyName = "Fin",
                    HeaderText = "Fecha/Hora Fin",
                    Width = 150,
                    DefaultCellStyle = { Format = "g" }
                });
                dgvDisponibilidad.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "RecursoId", // <-- CORRECCIÓN
                    DataPropertyName = "RecursoId",
                    HeaderText = "RecursoId",
                    Visible = false
                });
                // --- FIN DE LA CORRECCIÓN ---
            }

            // Configurar DateTimePickers
            dtpInicio.Value = DateTime.Now;
            dtpFin.Value = DateTime.Now.AddHours(1);
        }

        private void MantenedorDisponibilidad_Load(object sender, EventArgs e)
        {
            CargarRecursos();
            HabilitarControles(false);
            btnNuevo.Enabled = false;
            btnEditar.Enabled = false;
            btnEliminar.Enabled = false;
        }

        private void CargarRecursos()
        {
            try
            {
                cmbRecursos.DataSource = LogDisponibilidad.Instancia.ListarRecursos();
                cmbRecursos.DisplayMember = "Nombre";
                cmbRecursos.ValueMember = "Id";
                cmbRecursos.SelectedIndex = -1;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al cargar la lista de recursos: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void CargarDisponibilidad(int recursoId)
        {
            try
            {
                dgvDisponibilidad.DataSource = LogDisponibilidad.Instancia.ListarDisponibilidadPorRecurso(recursoId);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al cargar la disponibilidad: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void cmbRecursos_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (cmbRecursos.SelectedValue is int recursoId)
            {
                recursoSeleccionadoId = recursoId;
                CargarDisponibilidad(recursoId);
                btnNuevo.Enabled = true;
                btnEditar.Enabled = true;
                btnEliminar.Enabled = true;
            }
            else
            {
                recursoSeleccionadoId = null;
                dgvDisponibilidad.DataSource = null;
                btnNuevo.Enabled = false;
                btnEditar.Enabled = false;
                btnEliminar.Enabled = false;
            }
            HabilitarControles(false);
        }

        private void HabilitarControles(bool habilitar)
        {
            grupBoxDatos.Enabled = habilitar;
            cmbRecursos.Enabled = !habilitar;
            dgvDisponibilidad.Enabled = !habilitar;
            btnNuevo.Enabled = !habilitar && recursoSeleccionadoId.HasValue;
            btnEditar.Enabled = !habilitar && recursoSeleccionadoId.HasValue;
            btnEliminar.Enabled = !habilitar && recursoSeleccionadoId.HasValue;
        }

        private void LimpiarFormularioDetalle()
        {
            txtId.Text = "";
            dtpInicio.Value = DateTime.Now;
            dtpFin.Value = DateTime.Now.AddHours(1);
        }

        private void btnNuevo_Click(object sender, EventArgs e)
        {
            HabilitarControles(true);
            LimpiarFormularioDetalle();
            dtpInicio.Focus();
        }

        private void btnEditar_Click(object sender, EventArgs e)
        {
            if (dgvDisponibilidad.SelectedRows.Count > 0)
            {
                CargarDatosDelGridAlFormulario(); // Esta línea también fallaba, ahora funcionará
                HabilitarControles(true);
            }
            else
            {
                MessageBox.Show("Debe seleccionar un bloque de disponibilidad para editar.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void dgvDisponibilidad_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                CargarDatosDelGridAlFormulario(); // Esta línea también fallaba, ahora funcionará
                HabilitarControles(true);
            }
        }

        private void CargarDatosDelGridAlFormulario()
        {
            DataGridViewRow fila = dgvDisponibilidad.CurrentRow;
            // Ahora estas líneas funcionarán gracias al 'Name' que agregamos
            txtId.Text = fila.Cells["Id"].Value.ToString();
            dtpInicio.Value = Convert.ToDateTime(fila.Cells["Inicio"].Value);
            dtpFin.Value = Convert.ToDateTime(fila.Cells["Fin"].Value);
        }

        private void btnEliminar_Click(object sender, EventArgs e)
        {
            if (dgvDisponibilidad.SelectedRows.Count > 0)
            {
                if (MessageBox.Show("¿Está seguro de que desea eliminar este bloque de disponibilidad?", "Confirmar Eliminación", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    try
                    {
                        // Esta línea ahora funcionará
                        int id = Convert.ToInt32(dgvDisponibilidad.CurrentRow.Cells["Id"].Value);
                        bool eliminado = LogDisponibilidad.Instancia.EliminarDisponibilidad(id);
                        if (eliminado)
                        {
                            MessageBox.Show("Disponibilidad eliminada correctamente.", "Éxito", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            CargarDisponibilidad(recursoSeleccionadoId.Value);
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Error al eliminar: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            else
            {
                MessageBox.Show("Debe seleccionar un bloque de la lista para eliminar.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                EntDisponibilidad d = new EntDisponibilidad
                {
                    RecursoId = recursoSeleccionadoId.Value,
                    Inicio = dtpInicio.Value,
                    Fin = dtpFin.Value
                };

                bool resultado = false;
                string mensaje = "";

                if (!string.IsNullOrEmpty(txtId.Text))
                {
                    d.Id = Convert.ToInt32(txtId.Text);
                    resultado = LogDisponibilidad.Instancia.EditarDisponibilidad(d);
                    mensaje = "Disponibilidad modificada correctamente.";
                }
                else
                {
                    resultado = LogDisponibilidad.Instancia.InsertarDisponibilidad(d);
                    mensaje = "Disponibilidad agregada correctamente.";
                }

                if (resultado)
                {
                    MessageBox.Show(mensaje, "Éxito", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    HabilitarControles(false);
                    LimpiarFormularioDetalle();
                    CargarDisponibilidad(recursoSeleccionadoId.Value);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al guardar: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void btnCancelar_Click(object sender, EventArgs e)
        {
            HabilitarControles(false);
            LimpiarFormularioDetalle();
        }

        private void btnSalir_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
