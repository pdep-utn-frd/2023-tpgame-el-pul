import wollok.game.*
import comida.Comida
import viborita.*


object juego {
	var property velocidad = 100
	var property comidaActiva = new Comida(position = game.at(8, 7))
	var property ancho = 20
	var property alto = 16
	var property estaPausa = false
	var property puntaje = 0
	
	
	method iniciar() {
		self.configurarInicio()
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
		
		game.onTick(velocidad, "mover viborita", {viborita.mover()})
//		game.onTick(1000, "agregar parte SACAR DESPUES", {viborita.hayQueAgrandar(true)})
		
	}
	
	method aumentarVelocidad(nuevaVel) {
		game.removeTickEvent("mover viborita")
		game.onTick(nuevaVel, "mover viborita", {viborita.mover()})
	}
	
	method agregarVisuales() {
		game.addVisual(viborita.cabeza())
		game.addVisual(viborita.tmp())
		game.addVisual(comidaActiva)
		game.addVisual(score)
		
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
			game.onTick(velocidad, "mover viborita", {viborita.mover()})
			estaPausa = false
			
		}
	}
	
	method agregarColisiones() {
		game.onCollideDo(viborita.cabeza(), {cosa => 
			if (viborita.cuerpo().filter({aux => aux == cosa}).size() != 0) {
				viborita.morir()
			} else if (cosa == comidaActiva) {
				self.nuevaComida()
				viborita.hayQueAgrandar(true)
				puntaje+=20
			}
		})
	}
	
	method reiniciar() {
		game.addVisual(viborita.cabeza())
		game.addVisual(viborita.tmp())
	}
	
	method nuevaComida() {
		game.removeVisual(comidaActiva)
		
//		var grilla = []
//		alto.times({i =>
//			const fila = []
//			ancho.times({j =>
//				fila.add(j-1)
//			})
//			grilla.add(fila)
//		})
//		
//		viborita.cuerpo().forEach({parte => 
//			const x = parte.position().x()
//			const y = parte.position().y()
//			
//			grilla.get(y).remove(x)
//			return parte
//		})
//		
//		const grilla_filtrada = grilla.filter({r => r.size() != 0})
//		const fila = grilla_filtrada.get(0.randomUpTo(grilla_filtrada.size()))
//		var y
//		
//		grilla.size().times({i => 
//			if (grilla.get(i-1) == fila) {
//				y = i
//			}
//		})
//		var x = fila.get(0.randomUpTo(fila.size()))
		
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
}

object score {
	var property position = game.at(1, juego.alto()-2)
	method text() = "Puntaje: " + juego.puntaje()
}

