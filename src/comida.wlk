import wollok.game.*
import example.*
import viborita.*
import efectos.*
import sonidos.*

class Comida {
	var property position
	method image() = "assets/mate.png"
	
	method comer() {
		mate.play()
		juego.nuevaComida()
		viborita.hayQueAgrandar(true)
		juego.puntaje(juego.puntaje() + 10)
	}
}

class ComidaConfundidora inherits Comida {
	override method image() = "assets/blue_label.png"
	
	override method comer() {
		viborita.cambiarEfecto(confundido)
		juego.puntaje(juego.puntaje() + 30)
		game.removeVisual(self)
		juego.comidasEspeciales().remove(self)
		
		game.schedule(10000, {
			viborita.cambiarEfecto(nulo)
		})
	}
	
}

class ComidaVelocidad inherits Comida {
	override method image() = "assets/redbull.png"
	
	override method comer() {
		
		juego.puntaje(juego.puntaje() + 15)
		viborita.cambiarEfecto(velocista)
		
		game.removeVisual(self)
		juego.comidasEspeciales().remove(self)
		
		game.schedule(7000, {
			viborita.cambiarEfecto(nulo)
		})
	}
}

class ComidaAchicadora inherits Comida {
	override method image() = "assets/herbalife.png"
	
	override method comer() {
		juego.puntaje(juego.puntaje() + 5)
		game.removeVisual(self)
		juego.comidasEspeciales().remove(self)
		
		if (viborita.cuerpo().size() > 2) {
			var ultimoCuerpo = viborita.cuerpo().last()
			game.removeVisual(ultimoCuerpo)
			viborita.cuerpo().remove(ultimoCuerpo)
			viborita.cuerpo().last().anterior(false)
			viborita.cola(viborita.cuerpo().last())
		}
		
	}
	
}
	
object generadorComidaEspecial {
	method nuevaComida() {
		var aux = 0.randomUpTo(3).roundUp()
		var nuevaPosicion = juego.nuevaPosicionDeComida()
		
		if (aux == 1) {
			return new ComidaConfundidora(position=nuevaPosicion)
		} else if (aux == 2) {
			return new ComidaVelocidad(position=nuevaPosicion)
		} else {
			return new ComidaAchicadora(position=nuevaPosicion)
		}
	}
}