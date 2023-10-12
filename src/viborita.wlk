import wollok.game.*
import example.*

class ParteDeViborita {
	var property position
	var property posicionAnterior = false
	var property anterior
	method image() = "assets/cuerpo_2.png"
	
	method moverUno(pos) {
		posicionAnterior = position
		position = pos
		
		if (anterior != false) {
			anterior.moverUno(posicionAnterior)
		}
	}
	
}

class Cabeza inherits ParteDeViborita {
	var property direccion = 'E'

	override method image() {
		if (direccion == 'E') {
			return "assets/cabeza_este.png"
		} else if (direccion == 'O') {
			return "assets/cabeza_oeste.png"
		} else if (direccion == 'N') {
			return "assets/cabeza_norte.png"
		} else {
			return "assets/cabeza_sur.png"
		}
	}
	
	override method moverUno(pos) {
		posicionAnterior = position
		if (direccion == 'E') {
		position = position.right(1)
		} else if (direccion == 'O') {
			position = position.left(1)
		} else if (direccion == 'N') {
			position = position.up(1)
		} else {
			position = position.down(1)
		}
		
		if (position.x() >= juego.ancho() || position.y() >= juego.alto()-1 || position.x() < 0 || position.y() < 0) {
			viborita.morir()
		}
		
		if (anterior != false) {
			anterior.moverUno(posicionAnterior)
		}
	}

}

object viborita {
	var property tmp = new ParteDeViborita(anterior=false, position = game.at(9,10))
	var property cabeza = new Cabeza(anterior = tmp, position = game.at(10, 10))
	var property cuerpo = [cabeza, cabeza.anterior()]
	var property cola = tmp
	var property hayQueAgrandar = false
	var property puedeCambiarDireccion = true
	
	method agrandar() {
		var nuevaPosicion = cola.posicionAnterior()
		var nuevaParte = new ParteDeViborita(anterior = false, position = nuevaPosicion)
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
		
		tmp = new ParteDeViborita(anterior=false, position = game.at(9,10))
		cabeza = new Cabeza(anterior = tmp, position = game.at(10, 10))
		cuerpo = [cabeza, cabeza.anterior()]
		cola = tmp
		hayQueAgrandar = false
		game.addVisual(cabeza)
		game.addVisual(tmp)
		juego.agregarColisiones()
		game.onTick(juego.velocidad(), "mover viborita", {self.mover()})
		juego.puntaje(0)
	}
}
