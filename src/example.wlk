class Vacuna {

	const property precioBase = 1000
	const property precioPorAnio = 50
	const property anioBase = 30

	method efectoVacuna(persona) {
		persona.anticuerpos(self.definirAnticuerpos(persona))
		persona.inmunidad(self.sumarInmunidad(persona))
	}

	method definirAnticuerpos(persona)

	method sumarInmunidad(persona)

	method costoVacuna(persona) = self.calcularPrecioGeneral(persona) + self.costoAdicionalPorVacuna(persona)

	method calcularPrecioGeneral(persona) = precioBase + self.precioAdicionalPorAnio(persona)

	method precioAdicionalPorAnio(persona) = precioPorAnio * (persona.edad() - 30).max(0)

	method costoAdicionalPorVacuna(persona)

	method cuantosAnticuerposQuedaria(persona) = self.definirAnticuerpos(persona)

	method fechaDeInmunidadQueQuedaria(persona) = self.sumarInmunidad(persona)

}

object paifer inherits Vacuna {

	const fechaDeHoy = calendario.hoy()

	override method definirAnticuerpos(persona) = persona.anticuerpos() * 10

	override method sumarInmunidad(persona) = fechaDeHoy.plusMonths(if (persona.esMayorDe(40)) 6 else 9)

	override method costoAdicionalPorVacuna(persona) = if (persona.esMayorDe(18)) 100 else 400

}

class Larussa inherits Vacuna {

	var property efectoMultiplicador
	const maximoEfectoMultiplicador = 20
	const costoExtra = 100
	const property fechaInmunidad = new Date(day = 03, month = 03, year = 2022)

	override method definirAnticuerpos(persona) = self.anticuerposAAgregar(persona)

	method anticuerposAAgregar(persona) = self.calcularEfecto(persona, maximoEfectoMultiplicador.min(efectoMultiplicador))

	method calcularEfecto(persona, efecto) = persona.anticuerpos() * efecto

	override method sumarInmunidad(persona) = fechaInmunidad

	override method costoAdicionalPorVacuna(persona) = costoExtra * efectoMultiplicador

}

object astraLaVistaZeneca inherits Vacuna {

	const sumarAnticuerpos = 10000
	const lugaresEspeciales = [ "Tierra del fuego", "Santa Cruz", "Neuquen" ]

	override method definirAnticuerpos(persona) = persona.anticuerpos() + sumarAnticuerpos

	override method sumarInmunidad(persona) = if (persona.tieneNombrePar()) calendario.hoy().plusMonths(6) else calendario.hoy().plusMonths(7)

	override method costoAdicionalPorVacuna(persona) = if (self.viveEnUnLugarEspecial(persona)) 2000 else 0

	method viveEnUnLugarEspecial(persona) = lugaresEspeciales.contains(persona.provincia())

}

class Combineta inherits Vacuna {

	const dosisQueContienen = []
	const costoAdicional = 100

	method agregarDosis(dosis) {
		dosisQueContienen.addAll(dosis)
	}

	override method definirAnticuerpos(persona) = self.devolerTodosLosAnticuerpos(persona).min{ numero => numero }

	method devolerTodosLosAnticuerpos(persona) = dosisQueContienen.map{ dosis => dosis.definirAnticuerpos(persona) }

	override method sumarInmunidad(persona) = self.devolerLasFechasDeLosAnticuerpos(persona).max{ fecha => fecha }

	method devolerLasFechasDeLosAnticuerpos(persona) = dosisQueContienen.map{ dosis => dosis.sumarInmunidad(persona) }

	override method costoVacuna(persona) = self.costoDeLasDosis(persona)

	method costoDeLasDosis(persona) = dosisQueContienen.sum{ dosis => dosis.costoVacuna(persona) + costoAdicional }

	override method costoAdicionalPorVacuna(persona) = 0

}

class Persona {

	const property nombre
	var property anticuerpos = 1
	var property inmunidad = new Date()
	var property edad
	const property provincia = "Tierra del fuego"
	var property criterioEleccionVacuna = cualquierosas
	var property historialDeVacunas = []

	method esMayorDe(edadEntrante) = edad > edadEntrante

	method eleccionVacuna(vacuna) = criterioEleccionVacuna.eleccionVacuna(vacuna, self)

	method devolverVacunaDeseada(vacunas) = vacunas.filter{ vacuna => self.eleccionVacuna(vacuna) }

	method agregarVacunas(vacunas) {
		historialDeVacunas.addAll(vacunas)
	}

	method vacunarse(vacuna) {
		if (!criterioEleccionVacuna.eleccionVacuna(vacuna, self)) throw new Exception(message = "La vacuna solicitada no es aplicable para la persona")
		vacuna.efectoVacuna(self)
		self.agregarVacunas([ vacuna ])
	}

	method tieneNombrePar() = nombre.length().even()

}

object calendario {

	method hoy() = new Date()

	method hoyFija() = new Date(day = 01, month = 12, year = 2021)

	method adelantarHoyPorMes(cantidadDeMeses) = self.hoy().plusMonths(cantidadDeMeses)

	method adelantarHoyFijaPorMes(cantidadDeMeses) = self.hoyFija().plusMonths(cantidadDeMeses)

}

object cualquierosas {

	method eleccionVacuna(vacuna, persona) = true

}

object anticuerposas {

	const minimoDeAnticuerpo = 100000

	method eleccionVacuna(vacuna, persona) = vacuna.cuantosAnticuerposQuedaria(persona) > minimoDeAnticuerpo

}

object inmunidosasFijas {

	const fechaDeseada = new Date(day = 05, month = 03, year = 2022)

	method eleccionVacuna(vacuna, persona) = vacuna.fechaDeInmunidadQueQuedaria(persona) > fechaDeseada

}

class InmunidosasVariables {

	var property meses

	method fechaDeseada() = calendario.hoy().plusMonths(meses)

	method eleccionVacuna(vacuna, persona) = vacuna.fechaDeInmunidadQueQuedaria(persona) > self.fechaDeseada()

}

class PlanVacunacion {

	const vacunasDisponibles = []
	const personasAVacunar = []

	method agregarVacunas(vacunas) {
		vacunasDisponibles.addAll(vacunas)
	}

	method agregarPersonas(personas) {
		personasAVacunar.addAll(personas)
	}

	method costoInicialVacunacion() = personasAVacunar.sum{ persona => self.elegirLaMasBarata(persona) }

	method elegirLaMasBarata(persona) = self.devolverVacunasAceptadas(persona).map{ vacuna => vacuna.costoVacuna(persona) }.minIfEmpty({ 0 })

	method devolverVacunasAceptadas(persona) = persona.devolverVacunaDeseada(vacunasDisponibles)

}

