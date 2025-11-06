CREATE TABLE Persona(
	Id int primary key identity(1,1),
	Nombres nvarchar(256) not null,
	Apellidos nvarchar(256) not null,
	DNI char(8) not null,
	Telefono char(9) not null,
	Sexo bit not null default 0,
	Correo nvarchar(254) not null
)

CREATE TABLE Miembro(
	Id int primary key,
	MembresiaInicio date not null,
	MembresiaFin date not null,
	GrupoSanguineo varchar(3) not null,
	Seguro nvarchar(16) not null,
	FechaNacimiento date not null,

	foreign key (Id) references Persona(Id)
)

CREATE TABLE Cargos(
	Id int primary key identity(1,1),
	Nombre nvarchar(64) not null
)

CREATE TABLE Especialidad(
	Id int primary key identity(1,1),
	EspNombre nvarchar(32) not null
)

CREATE TABLE Trabajador(
	Id int primary key,
	Cargo int not null,
	Salario decimal(10,2) not null,
	Especialidad int null,

	check(Salario>0),

	foreign key (Id) references Persona(Id),
	foreign key (Cargo) references Cargos(Id),
	foreign key (Especialidad) references Especialidad(Id)
)

CREATE TABLE Logins(
	Id int primary key,
	Usuario varchar(12),
	Contrasena varchar(12),

	foreign key (Id) references Persona(Id)
)

CREATE TABLE Consulta(
	Id bigint primary key identity(1,1),
	Miembro int not null,
	Medico int not null,
	Coach int not null,
	Nutricionista int not null,
	Fecha datetime not null,

	foreign key (Miembro) references Miembro(Id),
	foreign key (Medico) references Trabajador(Id),
	foreign key (Coach) references Trabajador(Id),
	foreign key (Nutricionista) references Trabajador(Id)
)

CREATE TABLE Horario(
	Trabajador int not null,
	Dia varchar(20) not null,
	HoraInicio time not null,
	HoraFin time not null,

	foreign key (Trabajador) references Trabajador(Id)
)
--select CAST(GETDATE() as time)

CREATE TABLE EvaluacionFisica(
	Id bigint primary key identity(1,1),
	Peso decimal(5,2) not null,
	Estatura decimal(5,2) not null,
	IMC as (Peso/(Estatura*Estatura)) persisted,
	PorcentajeGrasa decimal(5,2) not null default 0,
	Flexibilidad decimal(5,2) not null default 0,
	Fuerza decimal(5,2) not null default 0,
	Equilibrio decimal(5,2) not null default 0,
	Observacion nvarchar(512) not null,
	Objetivo nvarchar(128) not null
)

CREATE TABLE Ejercicios(
	Id int primary key identity(1,1),
	Nombre nvarchar(64) not null default '',
	Dificultad char(1) not null default '1',
	AtributoTecnico bit not null default 1,
	DescripcionTecnica nvarchar(512) not null default ''
)

CREATE TABLE PlanEntrenamiento(
	Id bigint primary key identity(1,1),
	Inicio date not null,
	Fin date not null,
	Asistencias int not null default 0,
	EjerciciosRealizados int not null default 0,
	ObservacionTecnica nvarchar(512) null default ''
)

CREATE TABLE RecursoDeportivo(
	Id int primary key identity(1,1),
	Nombre nvarchar(64) not null
)

CREATE TABLE RecursoDisponibilidad(
    Recurso INT NOT NULL,
    Fecha date not null,
    Hora TIME NOT NULL,
	PlanEntrenamiento bigint null,
	foreign key (PlanEntrenamiento) references PlanEntrenamiento(Id),
    FOREIGN KEY (Recurso) REFERENCES RecursoDeportivo(Id)
)

CREATE TABLE HorarioEjercicios(
	PlanEntrenamiento bigint not null,
	Ejercicio int not null,
	Recurso int null,

	foreign key (PlanEntrenamiento) references PlanEntrenamiento(Id),
	foreign key (Ejercicio) references Ejercicios(Id),
	foreign key (Recurso) references RecursoDeportivo(Id)
)

CREATE TABLE HistoriaClinica(
	Id bigint primary key identity(1,1),
	Antecedentes nvarchar(1024) not null,
	Alergias nvarchar(512) not null,
	Deporte bit not null default 0,
	Fumador bit not null default 0,
)

CREATE TABLE EvaluacionNutricional(
	Id bigint primary key identity(1,1),
	Saludable bit not null default 0,
	Observacion nvarchar(512) null default '',
	Evolucion nvarchar(512) null default '',
)

ALTER TABLE EvaluacionNutricional
ADD 
    ReqEnergetico INT NOT NULL DEFAULT 0,
    ObjetivoNutri1 NVARCHAR(50) NULL DEFAULT '',
    ObjetivoNutri2 NVARCHAR(50) NULL DEFAULT '',
    ObjetivoNutri3 NVARCHAR(50) NULL DEFAULT '';

CREATE TABLE PlanNutricional(
	Id bigint primary key identity(1,1),
	EvaluacionNutricional bigint not null,
	Dia varchar(20) not null,
	Tipo varchar(10) not null,
	Alimento nvarchar(512) not null,
	ValorNutricional nvarchar(512) not null,

	foreign key (EvaluacionNutricional) references EvaluacionNutricional(Id)
)
ALTER TABLE PlanNutricional
ADD
	Comida NVARCHAR(8) NOT NULL;

ALTER TABLE PlanNutricional
DROP COLUMN Tipo, Alimento, ValorNutricional;

ALTER TABLE PlanNutricional
ADD
	Tipo varchar(10) not null,
	Alimento nvarchar(512) not null,
	ValorNutricional nvarchar(512) not null;

CREATE TABLE Expediente(
	Id bigint primary key identity(1,1),
	Miembro int not null,
	Consulta bigint not null,
	Fecha date not null,
	Observacion nvarchar(512) not null,
	HistoriaClinica bigint not null,
	EvaluacionFisica bigint not null,
	PlanEntrenamiento bigint not null,
	
	foreign key (Miembro) references Miembro(Id),
	foreign key (HistoriaClinica) references HistoriaClinica(Id),
	foreign key (PlanEntrenamiento) references PlanEntrenamiento(Id),
	foreign key (Consulta) references Consulta(Id)
)

create or alter procedure ListarRecursosDeportivos
as
begin try
	select Id, Nombre from RecursoDeportivo
end try
begin catch
	select ERROR_NUMBER() as Error, ERROR_MESSAGE() as MessageError
	if @@TRANCOUNT <> 0
		rollback transaction
end catch

create or alter procedure InsertarRecursoDeportivos
	@Nombre nvarchar(64) = null
as
begin try
begin transaction
	declare @nombreM nvarchar(64)
	set @nombreM = UPPER(@Nombre)

	if exists (select 1 from RecursoDeportivo where Nombre = @nombreM)
		throw 50005, 'Ya existe un recurso con ese nombre', 1

	insert into RecursoDeportivo(Nombre)
	values (@nombreM)
commit transaction
end try
begin catch
	select ERROR_NUMBER() as Error, ERROR_MESSAGE() as MessageError
	if @@TRANCOUNT <> 0
		rollback transaction
end catch

create or alter procedure EditarRecursoDeportivos
	@Id int = null,
	@Nombre nvarchar(64) = null
as
begin try
begin transaction
	
	declare @nombreM nvarchar(64)
	set @nombreM = UPPER(@Nombre)

	if not exists (select 1 from RecursoDeportivo where Id = @Id)
		throw 50005, 'No existe ese recurso deportivo', 1

	if exists (select 1 from RecursoDeportivo where Id <> @Id and Nombre = @nombreM)
		throw 50005, 'Ya existe un recurso deportivo con ese nombre', 1

	update RecursoDeportivo
		set Nombre = @nombreM
	where Id = @Id
commit transaction
end try
begin catch
	select ERROR_NUMBER() as Error, ERROR_MESSAGE() as MessageError
	if @@TRANCOUNT <> 0
		rollback transaction
end catch

create or alter procedure ListarDisponibilidadRecurso
	@Id int = null
as
begin try
begin transaction
	if not exists (select 1 from RecursoDeportivo where Id = @Id)
		throw 50005, 'No existe un recurso con ese id', 1

	select Fecha, Hora, PlanEntrenamiento from RecursoDisponibilidad where Recurso = @Id
commit transaction
end try
begin catch
	select ERROR_NUMBER() as Error, ERROR_MESSAGE() as MessageError
	if @@TRANCOUNT <> 0
		rollback transaction
end catch

select * from RecursoDisponibilidad

CREATE OR ALTER PROCEDURE SepararRecurso
    @Id INT = NULL,
    @Fecha date = NULL,
    @HoraInicio TIME = NULL,
	@Plan bigint = null
AS
BEGIN TRY
begin transaction
    IF NOT EXISTS (SELECT 1 FROM RecursoDeportivo WHERE Id = @Id)
        THROW 50005, 'El recurso no existe', 1;

    IF @Fecha IS NULL OR @HoraInicio IS NULL
        THROW 50005, 'Debe ingresar el día y las horas de inicio y fin', 1;

    INSERT INTO RecursoDisponibilidad (Recurso, Fecha, Hora)
    VALUES (@Id, @Fecha, @HoraInicio);
commit transaction
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;

create or alter procedure BorrarSeparacion
	@Id int = null,
	@Fecha date = null,
	@Hora time = null
as
begin try
begin transaction
	if not exists (select 1 from RecursoDisponibilidad where Recurso=@Id and Fecha = @Fecha and Hora = @Hora)
		throw 50005, 'Esa hora no esta ocupada', 1

	delete from RecursoDisponibilidad
	where Recurso = @Id and Fecha = @Fecha and Hora = @Hora
commit transaction
end try
begin catch
	SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
end catch

create or alter procedure ListarEjercicios
as
begin try
	select Id, Nombre, Dificultad, AtributoTecnico, DescripcionTecnica from Ejercicios
end try
begin catch
	SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
end catch

select * from Ejercicios

create or alter procedure AgregarEjercicio
	@dif char(1) = '1',
	@att bit = 1,
	@desc nvarchar(512) = '',
	@Nombre nvarchar(64) = ''
as
begin try
begin transaction
	if ((@dif <> '1') and (@dif <> '2') and (@dif <> '3'))
		throw 50005, 'La dificultad no es valida', 1

	declare @nombreM nvarchar(64)
	set @nombreM = UPPER(@Nombre)

	if exists (select 1 from RecursoDeportivo where Nombre = @nombreM)
		throw 50005, 'Ya existe un ejercicio con ese nombre', 1
	
	insert into Ejercicios(Nombre, Dificultad, AtributoTecnico, DescripcionTecnica)
	values (@nombreM, @dif, @att, @desc)
commit transaction
end try
begin catch
	SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
end catch

create or alter procedure EditarEjercicio
	@id int = null,
	@dif char(1) = '1',
	@att bit = 1,
	@desc nvarchar(512) = '',
	@Nombre nvarchar(64) = ''
as
begin try
begin transaction
	if not exists(select 1 from Ejercicios where Id = @id)
		throw 50005, 'No existe ese ejercicio', 1
	if ((@dif <> '1') and (@dif <> '2') and (@dif <> '3'))
		throw 50005, 'La dificultad no es valida', 1

	declare @nombreM nvarchar(64)
	set @nombreM = UPPER(@Nombre)

	if exists (select 1 from RecursoDeportivo where Id<>@id and Nombre = @nombreM)
		throw 50005, 'Ya existe un ejercicio con ese nombre', 1

	update Ejercicios
		set Nombre = @nombreM,
		Dificultad = @dif,
		AtributoTecnico = @att,
		DescripcionTecnica = @desc
	where Id = @id

commit transaction
end try
begin catch
	SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
end catch

create or alter procedure EliminarEjercicio
	@id int = null
as
begin try
begin transaction
	if @id is null
		throw 50005, 'El ejercicio no existe', 1
	if exists (select 1 from HorarioEjercicios where Ejercicio = @id)
		throw 50005, 'El ejercicio ya esta asignado a un horario, no puede eliminarlo', 1

	delete Ejercicios where Id = @id
commit transaction
end try
begin catch
	select ERROR_NUMBER() as Error, ERROR_MESSAGE() as MessageError
	if @@TRANCOUNT <> 0
		rollback transaction
end catch

create or alter procedure BuscarEjercicio
	@id int = null
as
begin try
	if not exists (select 1 from Ejercicios where Id = @id)
		throw 50005, 'No existe ese ejercicio', 1

	select Id, Nombre, Dificultad, AtributoTecnico, DescripcionTecnica from Ejercicios where Id = @id
end try
begin catch
	SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
end catch

CREATE OR ALTER PROCEDURE AgregarEvaluacionFisica
    @Peso DECIMAL(5,2) = NULL,
    @Estatura DECIMAL(5,2) = NULL,
    @PorcentajeGrasa DECIMAL(5,2) = NULL,
    @Flexibilidad DECIMAL(5,2) = NULL,
    @Fuerza DECIMAL(5,2) = NULL,
    @Equilibrio DECIMAL(5,2) = NULL,
    @Observacion NVARCHAR(512) = NULL,
    @Objetivo NVARCHAR(128) = NULL
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF @Peso IS NULL OR 
       @Estatura IS NULL OR 
       @PorcentajeGrasa IS NULL OR 
       @Flexibilidad IS NULL OR 
       @Fuerza IS NULL OR 
       @Equilibrio IS NULL OR 
       @Objetivo IS NULL OR 
       @Observacion IS NULL
        THROW 50005, 'Alguno de los datos fue nulo', 1;

    IF @PorcentajeGrasa < 0
        THROW 50005, 'El porcentaje de grasa debe ser al menos 0', 1;

    IF @PorcentajeGrasa > 100
        THROW 50005, 'El porcentaje de grasa no debe ser mayor a 100', 1;

    INSERT INTO EvaluacionFisica
        (Peso, Estatura, PorcentajeGrasa, Flexibilidad, Fuerza, Equilibrio, Observacion, Objetivo)
    VALUES
        (@Peso, @Estatura, @PorcentajeGrasa, @Flexibilidad, @Fuerza, @Equilibrio, @Observacion, @Objetivo);

    DECLARE @IdGenerado BIGINT = SCOPE_IDENTITY();

    COMMIT TRANSACTION;
	
    SELECT @IdGenerado AS NuevoId;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;

CREATE OR ALTER PROCEDURE spListarTrabajador
AS
BEGIN TRY
    SELECT 
    t.Id,
    p.Nombres,
    p.Apellidos,
    p.DNI,
    p.Telefono,
    p.Sexo,
    p.Correo,
    t.Cargo,        
    t.Salario,
    t.Especialidad  
FROM Trabajador t
INNER JOIN Persona p ON t.Id = p.Id;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spBuscarTrabajador
    @DNI CHAR(8)
AS
BEGIN TRY
    SELECT 
        t.Id,
        p.Nombres,
        p.Apellidos,
        p.DNI,
        p.Telefono,
        p.Sexo,
        p.Correo,
        t.Cargo,         
        t.Salario,
        t.Especialidad   -- Devuelve el ID de la especialidad
    FROM Trabajador t
    INNER JOIN Persona p ON t.Id = p.Id
    WHERE p.DNI = @DNI;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spAgregarTrabajador
    @Nombres NVARCHAR(256),
    @Apellidos NVARCHAR(256),
    @DNI CHAR(8),
    @Telefono CHAR(9),
    @Sexo BIT,
    @Correo NVARCHAR(254),
    @Cargo INT,
    @Salario DECIMAL(10,2),
    @Especialidad INT = NULL
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Persona WHERE DNI = @DNI)
        THROW 50005, 'Ya existe una persona con ese DNI', 1;

    INSERT INTO Persona (Nombres, Apellidos, DNI, Telefono, Sexo, Correo)
    VALUES (@Nombres, @Apellidos, @DNI, @Telefono, @Sexo, @Correo);

    DECLARE @Id INT = SCOPE_IDENTITY();

    INSERT INTO Trabajador (Id, Cargo, Salario, Especialidad)
    VALUES (@Id, @Cargo, @Salario, @Especialidad);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spEditarTrabajador
    @DNI CHAR(8),
    @Nombres NVARCHAR(200),
    @Apellidos NVARCHAR(200),
    @Sexo TINYINT,
    @Telefono CHAR(9),
    @Correo NVARCHAR(254),
    @Cargo INT,
    @Salario DECIMAL(10,2),
    @Especialidad INT = NULL
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Persona WHERE DNI = @DNI)
        THROW 50005, 'No existe un trabajador con ese DNI', 1;

    DECLARE @Id INT;
    SELECT @Id = Id FROM Persona WHERE DNI = @DNI;

    -- Actualiza Persona
    UPDATE Persona
    SET Nombres    = @Nombres,
        Apellidos  = @Apellidos,
        Sexo       = @Sexo,
        Telefono   = @Telefono,
        Correo     = @Correo
    WHERE Id = @Id;

    -- Actualiza Trabajador
    UPDATE Trabajador
    SET Cargo       = @Cargo,
        Salario     = @Salario,
        Especialidad = @Especialidad
    WHERE Id = @Id;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spEliminarTrabajador
    @DNI CHAR(8)
AS
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Id INT;
    SELECT @Id = Id FROM Persona WHERE DNI = @DNI;

    IF @Id IS NULL
        THROW 50005, 'No existe una persona con ese DNI', 1;

    DELETE FROM Trabajador WHERE Id = @Id;
    DELETE FROM Persona WHERE Id = @Id;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spListarMiembro
AS
BEGIN TRY
    SET NOCOUNT ON;

    SELECT 
        m.Id,
        p.Nombres,
        p.Apellidos,
        p.DNI,
        p.Telefono,
        p.Sexo,
        p.Correo,
        m.MembresiaInicio,
        m.MembresiaFin,
        m.GrupoSanguineo,
        m.Seguro,
        m.FechaNacimiento
    FROM Miembro m
    INNER JOIN Persona p ON m.Id = p.Id
    ORDER BY m.Id; -- 🔹 Ordenado por Id (de menor a mayor)

END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spBuscarMiembro
    @DNI CHAR(8)
AS
BEGIN TRY
    SET NOCOUNT ON;

    SELECT TOP(1)
        m.Id,
        p.Nombres,
        p.Apellidos,
        p.DNI,
        p.Telefono,
        p.Sexo,
        p.Correo,
        m.MembresiaInicio,
        m.MembresiaFin,
        m.GrupoSanguineo,
        m.Seguro,
        m.FechaNacimiento
    FROM Miembro m
    INNER JOIN Persona p ON m.Id = p.Id
    WHERE p.DNI = @DNI;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spAgregarMiembro
    @Nombres NVARCHAR(256),
    @Apellidos NVARCHAR(256),
    @DNI CHAR(8),
    @Telefono CHAR(9),
    @Sexo BIT,
    @Correo NVARCHAR(254),
    @MembresiaInicio DATE,
    @MembresiaFin DATE,
    @GrupoSanguineo VARCHAR(3),
    @Seguro NVARCHAR(16),
    @FechaNacimiento DATE
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF EXISTS (SELECT 1 FROM Persona WHERE DNI = @DNI)
        THROW 50005, 'Ya existe una persona registrada con ese DNI', 1;

    INSERT INTO Persona (Nombres, Apellidos, DNI, Telefono, Sexo, Correo)
    VALUES (@Nombres, @Apellidos, @DNI, @Telefono, @Sexo, @Correo);

    DECLARE @Id INT = SCOPE_IDENTITY();

    INSERT INTO Miembro (Id, MembresiaInicio, MembresiaFin, GrupoSanguineo, Seguro, FechaNacimiento)
    VALUES (@Id, @MembresiaInicio, @MembresiaFin, @GrupoSanguineo, @Seguro, @FechaNacimiento);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spEditarMiembro
    @DNI CHAR(8),
    @Nombres NVARCHAR(256),
    @Apellidos NVARCHAR(256),
    @Telefono CHAR(9),
    @Sexo BIT,
    @Correo NVARCHAR(254),
    @MembresiaInicio DATE,
    @MembresiaFin DATE,
    @GrupoSanguineo VARCHAR(3),
    @Seguro NVARCHAR(16),
    @FechaNacimiento DATE
AS
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Id INT;
    SELECT @Id = Id FROM Persona WHERE DNI = @DNI;

    IF @Id IS NULL
        THROW 50005, 'No existe un miembro con ese DNI', 1;

    UPDATE Persona
    SET Nombres = @Nombres,
        Apellidos = @Apellidos,
        Telefono = @Telefono,
        Sexo = @Sexo,
        Correo = @Correo
    WHERE Id = @Id;

    UPDATE Miembro
    SET MembresiaInicio = @MembresiaInicio,
        MembresiaFin = @MembresiaFin,
        GrupoSanguineo = @GrupoSanguineo,
        Seguro = @Seguro,
        FechaNacimiento = @FechaNacimiento
    WHERE Id = @Id;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

CREATE OR ALTER PROCEDURE spEliminarMiembro
    @DNI CHAR(8)
AS
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Id INT;
    SELECT @Id = Id FROM Persona WHERE DNI = @DNI;

    IF @Id IS NULL
        THROW 50005, 'No existe una persona con ese DNI', 1;

    DELETE FROM Miembro WHERE Id = @Id;
    DELETE FROM Persona WHERE Id = @Id;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

CREATE OR ALTER PROCEDURE [dbo].[spListarEvaNutricional]
AS
BEGIN
    SELECT Id, Saludable, Observacion, Evolucion, ReqEnergetico,
           ObjetivoNutri1, ObjetivoNutri2, ObjetivoNutri3
    FROM dbo.EvaluacionNutricional
    ORDER BY Id ASC;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[spInsertarEvaNutricional]
(
	@Saludable bit,
	@Observacion nvarchar(512),
	@Evolucion nvarchar(512),
	@ReqEnergetico int,
	@ObjetivoNutri1 nvarchar(50),
	@ObjetivoNutri2 nvarchar(50),
	@ObjetivoNutri3 nvarchar(50)
)
AS
BEGIN
	INSERT INTO EvaluacionNutricional(Saludable, Observacion, Evolucion, ReqEnergetico, ObjetivoNutri1, ObjetivoNutri2, ObjetivoNutri3)
	values (@Saludable, @Observacion, @Evolucion, @ReqEnergetico, @ObjetivoNutri1, @ObjetivoNutri2, @ObjetivoNutri3)
END
GO

CREATE OR ALTER PROCEDURE [dbo].[spEditarEvaNutricional]
(
	@Id bigint,
	@Saludable bit,
	@Observacion nvarchar(512),
	@Evolucion nvarchar(512),
	@ReqEnergetico int,
	@ObjetivoNutri1 nvarchar(50),
	@ObjetivoNutri2 nvarchar(50),
	@ObjetivoNutri3 nvarchar(50)
)
AS
BEGIN
		update EvaluacionNutricional set
		Saludable = @Saludable,
		Observacion = @Observacion,
		Evolucion = @Evolucion,
		ReqEnergetico = @ReqEnergetico,
		ObjetivoNutri1 = @ObjetivoNutri1,
		ObjetivoNutri2 = @ObjetivoNutri2,
		ObjetivoNutri3 = @ObjetivoNutri3
		where ID = @Id;
END
GO

SELECT * FROM PlanNutricional

GO

CREATE OR ALTER PROCEDURE [dbo].[spListarPlanNutricional]
AS
BEGIN
    SELECT Id, EvaluacionNutricional, Comida, Dia, Tipo, Alimento,
           ValorNutricional
    FROM dbo.PlanNutricional
    ORDER BY Id ASC;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[spInsertarPlanNutricional]
(
	@EvaluacionNutricional bigint,
	@Comida nvarchar(8),
	@Dia nvarchar(20),
	@Tipo nvarchar(10),
	@Alimento nvarchar(512),
	@ValorNutricional nvarchar(512)
)
AS
BEGIN
	INSERT INTO PlanNutricional(EvaluacionNutricional, Comida, Dia, Tipo, Alimento, ValorNutricional)
	values (@EvaluacionNutricional, @Comida, @Dia, @Tipo, @Alimento, @ValorNutricional)
END
GO

CREATE OR ALTER PROCEDURE [dbo].[spEditarPlanNutricional]
(
	@Id bigint,
	@EvaluacionNutricional bigint,
	@Comida nvarchar(8),
	@Dia nvarchar(20),
	@Tipo nvarchar(10),
	@Alimento nvarchar(512),
	@ValorNutricional nvarchar(512)
)
AS
BEGIN
		update PlanNutricional set
		EvaluacionNutricional = @EvaluacionNutricional,
		Comida = @Comida,
		Dia = @Dia,
		Tipo = @Tipo,
		Alimento = @Alimento,
		ValorNutricional = @ValorNutricional
		where Id = @Id;
END
GO

-- IMPORTANTE: Agregar ID a la tabla Horario

IF NOT EXISTS (SELECT 1 FROM sys.columns 
               WHERE Name = 'Id' 
               AND Object_ID = Object_ID('Horario'))
BEGIN
    ALTER TABLE Horario
    ADD Id INT PRIMARY KEY IDENTITY(1,1);
    PRINT 'Columna [Id] agregada a la tabla [Horario].'
END
GO


-- DATOS DE PRUEBA
-- Insertamos cargos y luego creamos 3 coaches de ejemplo.

IF NOT EXISTS (SELECT 1 FROM Cargos WHERE Nombre = 'COACH')
    INSERT INTO Cargos (Nombre) VALUES ('COACH');
IF NOT EXISTS (SELECT 1 FROM Cargos WHERE Nombre = 'NUTRICIONISTA')
    INSERT INTO Cargos (Nombre) VALUES ('NUTRICIONISTA');
IF NOT EXISTS (SELECT 1 FROM Cargos WHERE Nombre = 'MEDICO')
    INSERT INTO Cargos (Nombre) VALUES ('MEDICO');
IF NOT EXISTS (SELECT 1 FROM Cargos WHERE Nombre = 'ADMINISTRADOR')
    INSERT INTO Cargos (Nombre) VALUES ('ADMINISTRADOR');
GO

-- Insertar Especialidades (Opcional, pero bueno tenerlas)
IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE EspNombre = 'MUSCULACION')
    INSERT INTO Especialidad (EspNombre) VALUES ('MUSCULACION');
IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE EspNombre = 'CARDIO')
    INSERT INTO Especialidad (EspNombre) VALUES ('CARDIO');
IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE EspNombre = 'FUNCIONAL')
    INSERT INTO Especialidad (EspNombre) VALUES ('FUNCIONAL');
GO

-- Insertar Coaches (Persona -> Trabajador)
BEGIN
    -- Declarar variables para IDs
    DECLARE @IdCargoCoach INT = (SELECT Id FROM Cargos WHERE Nombre = 'COACH');
    DECLARE @IdEspMusculacion INT = (SELECT Id FROM Especialidad WHERE EspNombre = 'MUSCULACION');
    DECLARE @IdEspFuncional INT = (SELECT Id FROM Especialidad WHERE EspNombre = 'FUNCIONAL');
    DECLARE @IdPersona INT;

    -- Coach 1: Carlos Mendoza
    IF NOT EXISTS (SELECT 1 FROM Persona WHERE DNI = '70000001')
    BEGIN
        INSERT INTO Persona (Nombres, Apellidos, DNI, Telefono, Sexo, Correo)
        VALUES ('Carlos', 'Mendoza', '70000001', '987654321', 1, 'carlos.m@gym.com');
        
        SET @IdPersona = SCOPE_IDENTITY();
        
        INSERT INTO Trabajador (Id, Cargo, Salario, Especialidad)
        VALUES (@IdPersona, @IdCargoCoach, 2500.00, @IdEspMusculacion);
    END

    -- Coach 2: Ana Torres
    IF NOT EXISTS (SELECT 1 FROM Persona WHERE DNI = '70000002')
    BEGIN
        INSERT INTO Persona (Nombres, Apellidos, DNI, Telefono, Sexo, Correo)
        VALUES ('Ana', 'Torres', '70000002', '987654322', 0, 'ana.t@gym.com');
        
        SET @IdPersona = SCOPE_IDENTITY();
        
        INSERT INTO Trabajador (Id, Cargo, Salario, Especialidad)
        VALUES (@IdPersona, @IdCargoCoach, 2600.00, @IdEspFuncional);
    END

    -- Coach 3: Luis Ramos
    IF NOT EXISTS (SELECT 1 FROM Persona WHERE DNI = '70000003')
    BEGIN
        INSERT INTO Persona (Nombres, Apellidos, DNI, Telefono, Sexo, Correo)
        VALUES ('Luis', 'Ramos', '70000003', '987654323', 1, 'luis.r@gym.com');
        
        SET @IdPersona = SCOPE_IDENTITY();
        
        INSERT INTO Trabajador (Id, Cargo, Salario, Especialidad)
        VALUES (@IdPersona, @IdCargoCoach, 2400.00, @IdEspMusculacion);
    END
END
GO


-- PROCEDIMIENTOS ALMACENADOS (SPs) PARA HORARIOS

-- SP para llenar el ComboBox de Coaches
CREATE OR ALTER PROCEDURE spListarCoaches
AS
BEGIN TRY
    -- Busca el ID del cargo 'COACH'
    DECLARE @CargoCoach INT;
    SELECT @CargoCoach = Id FROM Cargos WHERE Nombre = 'COACH'; 

    IF @CargoCoach IS NULL
        THROW 50006, 'El cargo ''COACH'' no está definido en la tabla Cargos.', 1;

    -- Selecciona ID y NombreCompleto de los trabajadores que son 'COACH'
    SELECT 
        t.Id,
        p.Nombres + ' ' + p.Apellidos AS NombreCompleto
    FROM Trabajador t
    INNER JOIN Persona p ON t.Id = p.Id
    WHERE t.Cargo = @CargoCoach
    ORDER BY NombreCompleto;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
END CATCH;
GO

-- SP para listar los horarios de un coach específico
CREATE OR ALTER PROCEDURE spListarHorariosPorCoach
    @coachId INT
AS
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Trabajador WHERE Id = @coachId)
        THROW 50005, 'El trabajador (coach) no existe.', 1;

    SELECT 
        Id,
        Trabajador AS TrabajadorId, -- Alias para coincidir con EntHorario.cs
        Dia,
        HoraInicio,
        HoraFin
    FROM Horario
    WHERE Trabajador = @coachId
    ORDER BY CASE Dia
                WHEN 'Lunes' THEN 1
                WHEN 'Martes' THEN 2
                WHEN 'Miércoles' THEN 3
                WHEN 'Jueves' THEN 4
                WHEN 'Viernes' THEN 5
                WHEN 'Sábado' THEN 6
                WHEN 'Domingo' THEN 7
                ELSE 8
             END, HoraInicio;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
END CATCH;
GO

-- SP para insertar un nuevo bloque de horario
CREATE OR ALTER PROCEDURE spInsertarHorario
    @TrabajadorId INT,
    @Dia VARCHAR(20),
    @HoraInicio TIME,
    @HoraFin TIME
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF @HoraFin <= @HoraInicio
        THROW 50005, 'La hora final debe ser mayor que la hora inicial.', 1;

    -- Validación de traslape (que no choque con otro horario existente)
    IF EXISTS (
        SELECT 1 
        FROM Horario
        WHERE Trabajador = @TrabajadorId
          AND Dia = @Dia
          AND @HoraInicio < HoraFin -- El nuevo inicio es antes de que termine uno viejo
          AND @HoraFin > HoraInicio -- El nuevo fin es después de que empiece uno viejo
    )
        THROW 50006, 'El horario se traslapa con un bloque existente.', 1;

    INSERT INTO Horario (Trabajador, Dia, HoraInicio, HoraFin)
    VALUES (@TrabajadorId, @Dia, @HoraInicio, @HoraFin);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

-- SP para editar un bloque de horario existente
CREATE OR ALTER PROCEDURE spEditarHorario
    @Id INT, -- ID del horario a editar
    @Dia VARCHAR(20),
    @HoraInicio TIME,
    @HoraFin TIME
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF @HoraFin <= @HoraInicio
        THROW 50005, 'La hora final debe ser mayor que la hora inicial.', 1;

    -- Obtener el TrabajadorId para validar traslapes
    DECLARE @TrabajadorId INT;
    SELECT @TrabajadorId = Trabajador FROM Horario WHERE Id = @Id;

    IF @TrabajadorId IS NULL
        THROW 50007, 'El ID de horario no existe.', 1;

    -- Validación de traslape (excluyéndose a sí mismo de la validación)
    IF EXISTS (
        SELECT 1 
        FROM Horario
        WHERE Trabajador = @TrabajadorId
          AND Dia = @Dia
          AND @HoraInicio < HoraFin
          AND @HoraFin > HoraInicio
          AND Id <> @Id -- ¡Importante! Excluir el registro actual
    )
        THROW 50006, 'El horario modificado se traslapa con otro bloque.', 1;

    UPDATE Horario
    SET 
        Dia = @Dia,
        HoraInicio = @HoraInicio,
        HoraFin = @HoraFin
    WHERE Id = @Id;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO

-- SP para eliminar un bloque de horario
CREATE OR ALTER PROCEDURE spEliminarHorario
    @Id INT -- ID del horario a eliminar
AS
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Horario WHERE Id = @Id)
        THROW 50007, 'El ID de horario no existe o ya fue eliminado.', 1;

    DELETE FROM Horario
    WHERE Id = @Id;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS Error, ERROR_MESSAGE() AS MessageError;
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
END CATCH;
GO