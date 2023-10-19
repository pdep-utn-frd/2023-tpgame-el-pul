import wollok.game.*

object mate {
	method play() {
		game.sound("assets/sonidos/tomar_mate.mp3").play()
	}
}

object velocistaCancion {
	var sonido;
	method play() {
		sonido = game.sound("assets/sonidos/velocista.mp3")
		sonido.play()
	}
	
	method stop() {
		sonido.stop()
	}
	
}
