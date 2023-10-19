import wollok.game.*
import example.*
import efectos.*

class ParteDeViborita {
	var property position
	var property posicionAnterior = false
	var property anterior
	method image() {
		if (confundido.equals(viborita.efecto())) {
			return "assets/confundido/cuerpo.png"
		} else if (velocista.equals(viborita.efecto())) {
			return "assets/velocista/cuerpo.png"
		}
		return "assets/normal/cuerpo.png"
	}
	
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
		const carpeta = "assets/" + viborita.efecto().assetsCarpeta() + "/"
		if (direccion == 'E') {
			return carpeta + "cabeza_este.png"
		} else if (direccion == 'O') {
			return carpeta + "cabeza_oeste.png"
		} else if (direccion == 'N') {
			return carpeta + "cabeza_norte.png"
		} else {
			return carpeta + "cabeza_sur.png"
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
			juego.puntaje(0)
			viborita.morir()
			game.addVisual(pantallaGameOver)
			juego.nivel(juego.primerNivel())
			juego.reiniciar()
			juego.pausa()
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
	var property controlador = controlViborita
	var property efecto = nulo
	
	method agrandar() {
		var nuevaPosicion = cola.posicionAnterior()
		var nuevaParte = new ParteDeViborita(anterior = false, position = nuevaPosicion)
		cola.anterior(nuevaParte)
		cuerpo.add(nuevaParte)
		cola = nuevaParte
		game.addVisual(nuevaParte)
	}
	
	method cambiarDireccion(dir) {
		var nuevaDir = controlador.nuevaDireccion(dir)
		var c1 = nuevaDir == 'N' && cabeza.direccion() == 'S'
		var c2 = nuevaDir == 'S' && cabeza.direccion() == 'N'
		var c3 = nuevaDir == 'E' && cabeza.direccion() == 'O'
		var c4 = nuevaDir == 'O' && cabeza.direccion() == 'E'
		if (puedeCambiarDireccion && not (c1 || c2 || c3 || c4)) {
			cabeza.direccion(nuevaDir)
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
	
	method cambiarEfecto(nuevoEfecto) {
		efecto.eliminarEfecto()
		efecto = nuevoEfecto
		efecto.aplicarEfecto()
	}
	
	method eliminarViborita() {
		cuerpo.forEach({p => game.removeVisual(p)})
		cuerpo.clear()
	}
	
	
	method morir() {
		self.cambiarEfecto(nulo)
		self.eliminarViborita()
		game.removeTickEvent("mover viborita")
		
		tmp = new ParteDeViborita(anterior=false, position = game.at(9,10))
		cabeza = new Cabeza(anterior = tmp, position = game.at(10, 10))
		cuerpo = [cabeza, cabeza.anterior()]
		cola = tmp
		hayQueAgrandar = false
		
	}
}

object controlViborita {
	method nuevaDireccion(dir) {
		return dir
	}
}

object controlViboritaConfundida {
	method nuevaDireccion(dir) {
		if (dir == 'E') {
			return 'O'
		} else if (dir == 'O') {
			return 'E'
		} else if (dir == 'N') {
			return 'S'
		} else {
			return 'N'
		}
	}
}
