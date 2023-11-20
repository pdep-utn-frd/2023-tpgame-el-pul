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

	method colisionar() {
		juego.puntaje(0)
		viborita.morir()
		game.addVisual(pantallaGameOver)
		juego.nivel(juego.primerNivel())
		juego.reiniciar()	
		juego.pausa()
	}
	
}

class Cabeza inherits ParteDeViborita {
	var property direccion = este

	override method image() {
		const carpeta = "assets/" + viborita.efecto().assetsCarpeta() + "/"
		return carpeta + direccion.imagenCabeza()
	}
	
	override method moverUno(pos) {
		posicionAnterior = position
		position = direccion.moverEnDireccion(position)
		
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
		const nuevaDir = controlador.nuevaDireccion(dir)
		if (puedeCambiarDireccion && cabeza.direccion().puedeIr(nuevaDir)) {
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
	method nuevaDireccion(dir) = dir.opuesto() 
}

object norte {
	method imagenCabeza() = "cabeza_norte.png"
	method moverEnDireccion(pos) = pos.up(1) 
	method opuesto() = sur
	method puedeIr(dir) = dir != self.opuesto()

}

object sur {
	method imagenCabeza() = "cabeza_sur.png"
	method moverEnDireccion(pos) = pos.down(1) 
	method opuesto() = norte
	method puedeIr(dir) = dir != self.opuesto()

}

object este {
	method imagenCabeza() = "cabeza_este.png"
	method moverEnDireccion(pos) = pos.right(1) 
	method opuesto() = oeste
	method puedeIr(dir) = dir != self.opuesto()

}

object oeste {
	method imagenCabeza() = "cabeza_oeste.png"
	method moverEnDireccion(pos) = pos.left(1) 
	method opuesto() = este
	method puedeIr(dir) = dir != self.opuesto()

}