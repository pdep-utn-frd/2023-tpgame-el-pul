import wollok.game.*
import comida.*
import viborita.*
import sonidos.*


object juego {
	var property comidaActiva = new Comida(position = game.at(8, 7))
	var property ancho = 20
	var property alto = 16
	var property estaPausa = false
	var property puntaje = 0
	var property nivel
	var property primerNivel
	var property comidasEspeciales = []
	
	
	method iniciar(nivelInicial) {
		nivel = nivelInicial
		primerNivel = nivelInicial
		self.configurarInicio()
		self.configurarTickEvents()
		self.agregarVisuales()
		self.programarTeclas()
		self.agregarColisiones()
		game.start()
	}
	
	method configurarInicio() {
		game.width(ancho)
		game.height(alto)
		game.cellSize(23)
		game.title("La Viborita")
		game.boardGround("assets/fondo.png")
		

		
	}
	
	method configurarTickEvents() {
		game.onTick(nivel.velocidad(), "mover viborita", {viborita.mover()})
		//game.onTick(1000, "agregar parte SACAR DESPUES", {viborita.hayQueAgrandar(true)})
		
		game.onTick(5000, "agregar comida especial", {
			var nuevaComidaEspecial = generadorComidaEspecial.nuevaComida()
			comidasEspeciales.add(nuevaComidaEspecial)
			game.addVisual(nuevaComidaEspecial)
			
			game.schedule(6000, {
				if (game.hasVisual(nuevaComidaEspecial)) {
					game.removeVisual(nuevaComidaEspecial)
				}
			})
		})
	}
	
	method agregarVisuales() {
		game.addVisual(viborita.cabeza())
		game.addVisual(viborita.tmp())
		game.addVisual(comidaActiva)
		game.addVisual(score)
		game.addVisual(nivelActual)
	}
	
	method programarTeclas() {
		keyboard.up().onPressDo({viborita.cambiarDireccion('N')})
		keyboard.down().onPressDo({viborita.cambiarDireccion('S')})
		keyboard.left().onPressDo({viborita.cambiarDireccion('O')})
		keyboard.right().onPressDo({viborita.cambiarDireccion('E')})
		
		keyboard.w().onPressDo({viborita.cambiarDireccion('N')})
		keyboard.s().onPressDo({viborita.cambiarDireccion('S')})
		keyboard.a().onPressDo({viborita.cambiarDireccion('O')})
		keyboard.d().onPressDo({viborita.cambiarDireccion('E')})
		
		keyboard.enter().onPressDo({game.stop()})
		keyboard.space().onPressDo({self.pausa()})
	}
	
	method pausa (){
		if (estaPausa == false){
			game.removeTickEvent("mover viborita")
			estaPausa = true
		} else{
			if (game.hasVisual(pantallaSubirNivel)) {
				game.removeVisual(pantallaSubirNivel)
			}
			
			if (game.hasVisual(pantallaGameOver)) {
				game.removeVisual(pantallaGameOver)
			}
			game.onTick(nivel.velocidad(), "mover viborita", {viborita.mover()})
			estaPausa = false
			
		}
	}
	
	method agregarColisiones() {
		game.onCollideDo(viborita.cabeza(), {cosa => 
			if (viborita.cuerpo().any({aux => aux == cosa})) {
				self.puntaje(0)
				viborita.morir()
				game.addVisual(pantallaGameOver)
				nivel = primerNivel
				juego.reiniciar()	
				juego.pausa()
			} else if (cosa == comidaActiva) {
				comidaActiva.comer()
				
			} else if (comidasEspeciales.contains(cosa)) {
				cosa.comer()
			}
			if (juego.puntaje() >= nivel.puntajeParaAvanzar()) {
				juego.subirNivel()
			}
		})
	}
	
	method reiniciar() {
		game.removeVisual(score)
		game.removeVisual(nivelActual)
		game.removeVisual(comidaActiva)
		game.removeTickEvent("agregar comida especial")
		self.agregarVisuales()
		self.configurarTickEvents()
		self.agregarColisiones()
	}
	
	method nuevaComida() {
		game.removeVisual(comidaActiva)
		const nuevaPosicion = self.nuevaPosicionDeComida()
		comidaActiva = new Comida(position=nuevaPosicion)
		game.addVisual(comidaActiva)
	}
	
	method nuevaPosicionDeComida() {
		const x = 0.randomUpTo(ancho)
		const y = 0.randomUpTo(alto-1)
		
		if (viborita.cuerpo().any({p => p == game.at(x, y)})) {
			return self.nuevaPosicionDeComida()
			
		} else {
			return game.at(x, y)
		}
	}
	
	method subirNivel() {
		
		if (nivel.proximoNivel() != null) {
			game.addVisual(pantallaSubirNivel)
			nivel = nivel.proximoNivel()
			viborita.morir()
			self.reiniciar()
//			puntaje = 0
			self.pausa()
		} else {
			aplausos.play()
			viborita.morir()
			game.addVisual(pantallaFinDeJuego)
			
			
		}
		
		
		
	}
}

object score {
	var property position = game.at(1, juego.alto()-2)
	method text() = "Puntaje: " + juego.puntaje()
	method textColor() = "FFFFFFFF"
}

object nivelActual {
	var property position = game.at(juego.ancho() - 3, juego.alto()-2)
	method text() = juego.nivel().textoNivel()
	method textColor() = "FFFFFFFF"
}

object pantallaGameOver {
	var property text = "GAME OVER \n Presione espacio para continuar."
	
	method textColor() = "000000FF"
	
	method position() {
		var y = (juego.alto() / 2).roundUp()
		var x = (juego.ancho() / 2).roundUp() - 1
		
		return game.at(x, y)
	}
	
	
}

object pantallaSubirNivel {
	method text() {
		return juego.nivel().mensajeExito()
	}
	
	method textColor() = "000000FF"
	
	method position() {
		var y = (juego.alto() / 2).roundUp()
		var x = (juego.ancho() / 2).roundUp() - 1
		
		return game.at(x, y)
	}
}

object pantallaFinDeJuego {
	method text() {
		return "Felicidades! Completaste el juego. \n Presione ENTER para salir."
	}
	
	method textColor() = "000000FF"
	
	method position() {
		var y = (juego.alto() / 2).roundUp()
		var x = (juego.ancho() / 2).roundUp() - 1
		
		return game.at(x, y)
	}
}



class Nivel {
	var property velocidad
	var property mensajeExito
	var property proximoNivel
	var property puntajeParaAvanzar
	var property textoNivel
}

