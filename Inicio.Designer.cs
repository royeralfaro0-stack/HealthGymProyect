namespace HealthGym
{
    partial class Inicio
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code
        private void InitializeComponent()
        {
            btnGestionarHorarios = new Button();
            btnGestionarRecursos = new Button();
            SuspendLayout();
            // 
            // btnGestionarHorarios
            // 
            btnGestionarHorarios.Location = new Point(543, 293);
            btnGestionarHorarios.Name = "btnGestionarHorarios";
            btnGestionarHorarios.Size = new Size(193, 34);
            btnGestionarHorarios.TabIndex = 0;
            btnGestionarHorarios.Text = "Gestionar Horarios";
            btnGestionarHorarios.UseVisualStyleBackColor = true;
            btnGestionarHorarios.Click += btnGestionarHorarios_Click;
            // 
            // btnGestionarRecursos
            // 
            btnGestionarRecursos.Location = new Point(543, 354);
            btnGestionarRecursos.Name = "btnGestionarRecursos";
            btnGestionarRecursos.Size = new Size(193, 34);
            btnGestionarRecursos.TabIndex = 1;
            btnGestionarRecursos.Text = "Gestionar Recursos";
            btnGestionarRecursos.UseVisualStyleBackColor = true;
            btnGestionarRecursos.Click += btnGestionarRecursos_Click;
            // 
            // Inicio
            // 
            AutoScaleDimensions = new SizeF(10F, 25F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(btnGestionarRecursos);
            Controls.Add(btnGestionarHorarios);
            Name = "Inicio";
            Text = "Form1";
            ResumeLayout(false);
        }
        #endregion

        private Button btnGestionarHorarios;
        private Button btnGestionarRecursos;
    }
}
