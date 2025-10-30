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
    public partial class MantenedorHorario : Form
    {
        private int? coachSeleccionadoId = null;

        public MantenedorHorario()
        {
            InitializeComponent();
            ConfigurarFormulario();
        }

        private void ConfigurarFormulario()
        {
            // Configurar DataGridView
            dgvHorarios.AutoGenerateColumns = false;

           
            if (dgvHorarios.Columns.Count == 0)
            {
            
                dgvHorarios.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "Id",  
                    DataPropertyName = "Id",
                    HeaderText = "ID",
                    Width = 50,
                    Visible = false
                });
                dgvHorarios.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "Dia", 
                    DataPropertyName = "Dia",
                    HeaderText = "Día",
                    Width = 120
                });
                dgvHorarios.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "HoraInicio", 
                    DataPropertyName = "HoraInicio",
                    HeaderText = "Hora Inicio",
                    Width = 100,
                    DefaultCellStyle = { Format = @"hh\:mm" }
                });
                dgvHorarios.Columns.Add(new DataGridViewTextBoxColumn
                {
                    Name = "HoraFin", 
                    DataPropertyName = "HoraFin",
                    HeaderText = "Hora Fin",
                    Width = 100,
                    DefaultCellStyle = { Format = @"hh\:mm" }
                });
               

                dgvHorarios.Columns.Add(new DataGridViewTextBoxColumn { DataPropertyName = "TrabajadorId", HeaderText = "CoachID", Visible = false });
            }

         
            dtpHoraInicio.Value = DateTime.Today.AddHours(8);
            dtpHoraFin.Value = DateTime.Today.AddHours(9);   
        }

        private void MantenedorHorario_Load(object sender, EventArgs e)
        {
            CargarCoaches();
            // Deshabilitar botones al inicio
            HabilitarControles(false);
            btnNuevo.Enabled = false;
            btnEditar.Enabled = false;
            btnEliminar.Enabled = false;
        }

        private void CargarCoaches()
        {
            try
            {
                cmbCoaches.DataSource = LogHorario.Instancia.ListarCoaches();
                cmbCoaches.DisplayMember = "NombreCompleto";
                cmbCoaches.ValueMember = "Id";
                cmbCoaches.SelectedIndex = -1; // Dejarlo sin seleccionar
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al cargar la lista de coaches: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void CargarHorarios(int coachId)
        {
            try
            {
                dgvHorarios.DataSource = LogHorario.Instancia.ListarHorariosPorCoach(coachId);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al cargar los horarios: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void cmbCoaches_SelectedIndexChanged(object sender, EventArgs e)
        {
           
            if (cmbCoaches.SelectedValue is int coachId)
            {
                coachSeleccionadoId = coachId;
                CargarHorarios(coachId);
                // Habilitar botones principales
                btnNuevo.Enabled = true;
                btnEditar.Enabled = true;
                btnEliminar.Enabled = true;
            }
            else
            {
                coachSeleccionadoId = null;
                dgvHorarios.DataSource = null;
                // Deshabilitar si no hay coach
                btnNuevo.Enabled = false;
                btnEditar.Enabled = false;
                btnEliminar.Enabled = false;
            }
        
            HabilitarControles(false);
        }

        private void HabilitarControles(bool habilitar)
        {
            grupBoxDatos.Enabled = habilitar;
            // Invertir la lógica para los controles principales
            cmbCoaches.Enabled = !habilitar;
            dgvHorarios.Enabled = !habilitar;
            btnNuevo.Enabled = !habilitar && coachSeleccionadoId.HasValue;
            btnEditar.Enabled = !habilitar && coachSeleccionadoId.HasValue;
            btnEliminar.Enabled = !habilitar && coachSeleccionadoId.HasValue;
        }

        private void LimpiarFormularioDetalle()
        {
            txtHorarioId.Text = "";
            cmbDia.SelectedIndex = -1; 
            dtpHoraInicio.Value = DateTime.Today.AddHours(8);
            dtpHoraFin.Value = DateTime.Today.AddHours(9);
        }

        private void btnNuevo_Click(object sender, EventArgs e)
        {
            HabilitarControles(true);
            LimpiarFormularioDetalle();
            cmbDia.Focus();
        }

        private void btnEditar_Click(object sender, EventArgs e)
        {
            if (dgvHorarios.SelectedRows.Count > 0)
            {
                CargarDatosDelGridAlFormulario();
                HabilitarControles(true);
            }
            else
            {
                MessageBox.Show("Debe seleccionar un horario de la lista para editar.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void dgvHorarios_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
          
            if (e.RowIndex >= 0)
            {
                CargarDatosDelGridAlFormulario();
                HabilitarControles(true);
            }
        }

       
        private void CargarDatosDelGridAlFormulario()
        {
            DataGridViewRow fila = dgvHorarios.CurrentRow;

         
            txtHorarioId.Text = fila.Cells["Id"].Value.ToString();
            cmbDia.SelectedItem = fila.Cells["Dia"].Value.ToString();

            
            TimeSpan inicio = (TimeSpan)fila.Cells["HoraInicio"].Value;
            TimeSpan fin = (TimeSpan)fila.Cells["HoraFin"].Value;
            dtpHoraInicio.Value = DateTime.Today + inicio;
            dtpHoraFin.Value = DateTime.Today + fin;
        }


        private void btnEliminar_Click(object sender, EventArgs e)
        {
            if (dgvHorarios.SelectedRows.Count > 0)
            {
                if (MessageBox.Show("¿Está seguro de que desea eliminar este horario?", "Confirmar Eliminación", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                {
                    try
                    {
                        int horarioId = Convert.ToInt32(dgvHorarios.CurrentRow.Cells["Id"].Value);
                        bool eliminado = LogHorario.Instancia.EliminarHorario(horarioId);

                        if (eliminado)
                        {
                            MessageBox.Show("Horario eliminado correctamente.", "Éxito", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            CargarHorarios(coachSeleccionadoId.Value); // Recargar la grilla
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Error al eliminar el horario: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            else
            {
                MessageBox.Show("Debe seleccionar un horario de la lista para eliminar.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnGuardar_Click(object sender, EventArgs e)
        {
            try
            {
                if (cmbDia.SelectedItem == null)
                {
                    MessageBox.Show("Debe seleccionar un día.", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                EntHorario h = new EntHorario
                {
                    TrabajadorId = coachSeleccionadoId.Value,
                    Dia = cmbDia.SelectedItem.ToString(),
                    // Extraer solo la hora (TimeSpan) del DateTimePicker
                    HoraInicio = dtpHoraInicio.Value.TimeOfDay,
                    HoraFin = dtpHoraFin.Value.TimeOfDay
                };

                bool resultado = false;
                string mensaje = "";

                if (!string.IsNullOrEmpty(txtHorarioId.Text)) // Si hay ID, es una EDICIÓN
                {
                    h.Id = Convert.ToInt32(txtHorarioId.Text);
                    resultado = LogHorario.Instancia.EditarHorario(h);
                    mensaje = "Horario modificado correctamente.";
                }
                else 
                {
                    resultado = LogHorario.Instancia.InsertarHorario(h);
                    mensaje = "Horario agregado correctamente.";
                }

                if (resultado)
                {
                    MessageBox.Show(mensaje, "Éxito", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    HabilitarControles(false);
                    LimpiarFormularioDetalle();
                    CargarHorarios(coachSeleccionadoId.Value);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error al guardar el horario: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
