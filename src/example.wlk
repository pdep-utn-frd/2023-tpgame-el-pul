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
		keyboard.up().onPressDo({viborita.cambiarDireccion(norte)})
		keyboard.down().onPressDo({viborita.cambiarDireccion(sur)})
		keyboard.right().onPressDo({viborita.cambiarDireccion(este)})
		keyboard.left().onPressDo({viborita.cambiarDireccion(oeste)})
		
		keyboard.w().onPressDo({viborita.cambiarDireccion(norte)})
		keyboard.s().onPressDo({viborita.cambiarDireccion(sur)})
		keyboard.d().onPressDo({viborita.cambiarDireccion(este)})
		keyboard.a().onPressDo({viborita.cambiarDireccion(oeste)})
		
		keyboard.p().onPressDo({self.aumentarPuntaje(50)})
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
			cosa.colisionar()
			if (juego.puntaje() >= nivel.puntajeParaAvanzar()) {
				nivel.subirNivel()
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
	
	method aumentarPuntaje(c) {
		puntaje += c
	}
	
	method reiniciarPuntaje() {
		puntaje = 0
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

	method subirNivel() {
		if (self.proximoNivel() != null) {
			game.addVisual(pantallaSubirNivel)
			juego.nivel(self.proximoNivel())
			viborita.morir()
			juego.reiniciar()
			juego.pausa()
		} else {
			aplausos.play()
			viborita.morir()
			game.addVisual(pantallaFinDeJuego)
		}
	}
}

const nivel3 = new Nivel(
	velocidad = 60,
	proximoNivel = null,
	mensajeExito = "Felicidades! Avanzaste al nivel 3. \n Presione espacio para continuar.",
	puntajeParaAvanzar = 700,
	textoNivel = "Nivel 3"
)

const nivel2 = new Nivel(
	velocidad = 100,
	proximoNivel = nivel3,
	mensajeExito = "Felicidades! Avanzaste al nivel 2. \n Presione espacio para continuar.",
	puntajeParaAvanzar = 450,
	textoNivel = "Nivel 2"
)

const nivel1 = new Nivel(
	velocidad = 150,
	proximoNivel = nivel2,
	mensajeExito = "",
	puntajeParaAvanzar = 150,
	textoNivel = "Nivel 1"
)
