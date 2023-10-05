import wollok.game.*


object juego {
	var property velocidad = 60
	
	method iniciar() {
		self.configurarInicio()
		self.agregarVisuales()
		self.programarTeclas()
		self.agregarColisiones()
		game.start()
	}
	
	method configurarInicio() {
		game.width(30)
		game.height(30)
		game.cellSize(20)
		game.title("La Viborita")
		
		game.onTick(velocidad, "mover viborita", {viborita.mover()})
		game.onTick(2000, "agregar parte SACAR DESPUES", {viborita.hayQueAgrandar(true)})
		
	}
	
	method aumentarVelocidad(nuevaVel) {
		game.removeTickEvent("mover viborita")
		game.onTick(nuevaVel, "mover viborita", {viborita.mover()})
	}
	
	method agregarVisuales() {
		game.addVisual(viborita.cabeza())
		game.addVisual(viborita.tmp())
		
	}
	
	method programarTeclas() {
		keyboard.up().onPressDo({viborita.cambiarDireccion('N')})
		keyboard.down().onPressDo({viborita.cambiarDireccion('S')})
		keyboard.left().onPressDo({viborita.cambiarDireccion('O')})
		keyboard.right().onPressDo({viborita.cambiarDireccion('E')})
	}
	
	method agregarColisiones() {
		game.onCollideDo(viborita.cabeza(), {parte => 
			if (viborita.cuerpo().filter({aux => aux == parte}).size() != 0) {
				viborita.morir()
			}
		})
	}
	
	method reiniciar() {
		game.addVisual(viborita.cabeza())
		game.addVisual(viborita.tmp())
	}
	
}

class ParteDeViborita {
	var property position
	var property posicionAnterior = false
	var property direccion = 'E'
	var property anterior
	var property esCabeza
	method image() = "assets/viborita.png"
	
	method moverUno(pos) {
		posicionAnterior = position
		if (esCabeza) {
			if (direccion == 'E') {
			position = position.right(1)
			} else if (direccion == 'O') {
				position = position.left(1)
			} else if (direccion == 'N') {
				position = position.up(1)
			} else {
				position = position.down(1)
			}
			if (position.x() >= 30 || position.y() >= 30 || position.x() < 0 || position.y() < 0) {
				viborita.morir()
			}
		} else {
			position = pos
		}
		
		if (anterior != false) {
			anterior.moverUno(posicionAnterior)
			anterior.direccion(direccion)
		}
	}
	
}

object viborita {
	var property tmp = new ParteDeViborita(esCabeza = false, anterior=false, position = game.at(9,10))
	var property cabeza = new ParteDeViborita(esCabeza = true, anterior = tmp, position = game.at(10, 10))
	var property cuerpo = [cabeza, cabeza.anterior()]
	var property cola = tmp
	var property hayQueAgrandar = false
	var property puedeCambiarDireccion = true
	
	method agrandar() {
		var nuevaPosicion = cola.posicionAnterior()
		var nuevaParte = new ParteDeViborita(esCabeza = false, anterior = false, position = nuevaPosicion, direccion = cola.direccion())
		cola.anterior(nuevaParte)
		cuerpo.add(nuevaParte)
		cola = nuevaParte
		game.addVisual(nuevaParte)
	}
	
	method cambiarDireccion(dir) {
		var c1 = dir == 'N' && cabeza.direccion() == 'S'
		var c2 = dir == 'S' && cabeza.direccion() == 'N'
		var c3 = dir == 'E' && cabeza.direccion() == 'O'
		var c4 = dir == 'O' && cabeza.direccion() == 'E'
		if (puedeCambiarDireccion && not (c1 || c2 || c3 || c4)) {
			cabeza.direccion(dir)
			puedeCambiarDireccion = false
		}
	}
	
	method mover() {
		if (hayQueAgrandar) {
			self.agrandar()
			hayQueAgrandar = false
		}
		cabeza.moverUno(false)
		puedeCambiarDireccion = true
	}
	
	method eliminarViborita() {
		cuerpo.forEach({p => game.removeVisual(p)})
		cuerpo.clear()
	}
	
	
	method morir() {
		self.eliminarViborita()
		game.removeTickEvent("mover viborita")
		game.removeTickEvent("agregar parte SACAR DESPUES")
		
		tmp = new ParteDeViborita(esCabeza = false, anterior=false, position = game.at(9,10))
		cabeza = new ParteDeViborita(esCabeza = true, anterior = tmp, position = game.at(10, 10))
		cuerpo = [cabeza, cabeza.anterior()]
		cola = tmp
		hayQueAgrandar = false
		game.addVisual(viborita.cabeza())
		game.addVisual(viborita.tmp())
		juego.agregarColisiones()
		game.onTick(juego.velocidad(), "mover viborita", {self.mover()})
		game.onTick(2000, "agregar parte SACAR DESPUES", {self.hayQueAgrandar(true)})
	}
}