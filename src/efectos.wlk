import wollok.game.*
import viborita.*
import example.*
import sonidos.*

class Efecto {
	method aplicarEfecto()
	method eliminarEfecto()
	method assetsCarpeta()
}

object nulo inherits Efecto {
	override method aplicarEfecto(){}
	override method eliminarEfecto(){}
	override method assetsCarpeta() = "normal"
}

object confundido inherits Efecto {
	override method aplicarEfecto() {
		game.boardGround("assets/fondo_confundido.png")
		viborita.controlador(controlViboritaConfundida)
		
	}
	override method eliminarEfecto() {
		game.boardGround("assets/fondo.png")
		viborita.controlador(controlViborita)
	}
	
	override method assetsCarpeta() = "confundido"
}

object velocista inherits Efecto {
	override method aplicarEfecto() {
		try {
			game.removeTickEvent("mover viborita")
		} catch e {}
		
		const nuevaVelocidad = (juego.nivel().velocidad() * 0.7).roundUp()
		game.onTick(nuevaVelocidad, "mover viborita", {viborita.mover()})
		
		velocistaCancion.play()
	}
	
	override method eliminarEfecto() {
		velocistaCancion.stop()
		if (!juego.estaPausa() && juego.puntaje() < juego.nivel().puntajeParaAvanzar()) {	
			game.removeTickEvent("mover viborita")
			const nuevaVelocidad = juego.nivel().velocidad()
			game.onTick(nuevaVelocidad, "mover viborita", {viborita.mover()})	
		}
	}
	
	override method assetsCarpeta() = "velocista"
}
