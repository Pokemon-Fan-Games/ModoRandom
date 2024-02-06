# Modo Random

## Descripción

El modo random randomizará ataques y habilidades de los pokémon tanto de entrenadores como de los salvajes, se puede activar que también se randomize la compatibilidad con las MTs, se podrá restringir las generaciones de los pokémon que apareceran en el random.

Se puede elegir como funciona el random de las habilidades si 100% random por especie o mapeo de una habilidad a otra, o directamente no randomizar las habilidades.
Unos ejemplos:

- Opcion 1: 100% random -> Para esta opcion hay que poner la constante `FULL_RANDOM_ABS` que esta en el script `Random.rb` en `true`
  Ejemplo Pikachu tendra Intimidacion y Cura Natural, pero Raichu podria tener otras distintas, como Absorbe agua y levitacion
- Opcion 2: Mapeo de habilidades -> Para esta opcion hay que poner la constante `MAP_RANDOM_ABS` que esta en el script `Random.rb` en `true`
  Ejemplo Intimidacion se convierte en Inicio Lento, lo que no significa, que Inicio Lento se convierta en Intimidacion

Si ninguno de las 2 constantes está en `true` no se randomizaran las habilidades.

El random es progresivo en base a la cantidad de medallas del jugador, entre más medallas tenga salen pokémon con mas BST, aquí dejo la formula, que la pueden modificar en el metodo `getMaxBSTCap` y `getMinBSTCap`

- 0 y 1 medalla BST min 0 y BST max 400
- 2 medallas BST min 0 y BST max 440
- 3 medallas BST min 350 y BST max 480
- 4 medallas BST min 375 y BST max 520
- 5 medallas BST min 400 y BST max 560
- 6 medallas BST min 425 y BST max 600
- Más de 6 medallas BST min 440 y BST max 800

También si el jugador tiene menos de 3 medallas no pueden salir movimientos con mas de 70 de poder base.

Se puede hacer que los pokemon salgan de un listado definido por el maker, para eso actualice el script `Random.rb` en la variable `ListaStartersRandomizado` si se debe separar por comas, por ejemplo `[PBSpecies::BULBASAUR,PBSpecies::CHARMANDER,PBSpecies::SQUIRTLE, PBSpecies::PIDGEY,PBSpecies::NIDORANmA,PBSpecies::NIDORANfE,PBSpecies::ZUBAT,PBSpecies::MANKEY,PBSpecies::POLIWAG, PBSpecies::ABRA]`
Si este listado esta vacio los iniciales serán 100% random respetando las restricciones de generaciones, BST y blacklist de pokémon.

También se pueden randomizar los objetos obtenidos, para eso en los eventos que dan objetos hay que checkear si el switch del random está activo, si lo está en lugar de llamar a pbItemBall, hay que llamar `getItemRandomFromPokeball()` abajo dejo un ejemplo de como hacerlo.
![Objeto random](images/evento_objeto_random.png)

En el script `ObjetosRandom.rb` hay una variable `BLACK_LIST` que contiene los objetos que no se pueden obtener, de un objeto random si se quiere restringir mas de un objeto se debe separar por comas, por ejemplo `[:LOPUNNYTE, :SACREDASH, :BLACKFLUTE]`

También se hay una variable `MTLIST_RANDOM` que contiene las MTs que SI se pueden conseguir a través de un objeto random si se quiere agregar mas MTs se debe separar por comas, por ejemplo `[:TM01, :TM02, :TM03]`

## Implementación

1. Descargar el zip del [último release](https://github.com/Pokemon-Fan-Games/ModoRandom/releases/latest)
2. Crear los 3 scripts que estan en el zip, arriba del script Main
3. Crear el siguiente NPC para activar el modo random
   1. Debe activar el switch que tengan definido en el script, si lo dejan tal cual sería el 409
   2. Agregar una opción de script al evento con el llamado a la función `generarInicialesRandom()`
   3. El NPC también podría deasactivar el random, solo tiene que desactivar el switch
   **Ejemplo del evento que activa/desactiva el random**
   ![NPC Activar Random](images/activar_random.png)
4. Crear un NPC para que el jugador pueda limitar los pokémon de que generaciones salen en el random
   _Nota: Saldrán Pokémon de las generaciones elegidas y evoluciones que hayan salido en gens posteriores, eligiendo la gen 1 podria salir Magnezone por ejemplo_
   ![NPC Restringir Generaciones](images/random_gens_event.png)
   Codigo del script del evento:
   ```ruby
    ret = Kernel.pbMessage("¿Pokémon de
    que generaciones deseas?",
    get_random_gens_choice_array());
    # 9 es el numero de la opcion
    # "Terminar" si no es 9 activa el
    # switch, para que vuelvan a mostrar
    # las opciones y puedas
    # seleccionar mas
    $game_switches[159] = ret != 9;
    add_or_remove_random_gen(ret+1);
   ```
5. Si quieres activar el randomizado de la compatibilidad con las MTs, en el script `Random.rb` hay una variable que se llama `RANDOM_TM_COMPAT` por defecto esta en `false` si la cambias a `true` se randomizara la compatibilidad con las MTs
6. Se puede restringir que pokemon salen en el random, para eso se debe modificar el script `Random.rb` en la variable `BlackListedPokemon` si se quiere restringir mas de un pokemon se debe separar por comas, por ejemplo `[PBSpecies::ARTICUNO,PBSpecies::MOLTRES, PBSpecies::ZAPDOS]`
7. Se puede restringir que habilidades salen en el random, para eso se debe modificar el script `Random.rb` en la variable `ABILITYBLACKLIST` si se quiere restringir mas de una habilidad se debe separar por comas, por ejemplo `[PBAbilities::IMPOSTER, PBAbilities::ZENMODE, PBAbilities::WONDERGUARD]`
8. Se pueden restringir que movimientos salen en el random, para eso se debe modificar el script `Random.rb` en la variable `MOVEBLACKLIST` si se quiere restringir mas de un movimiento se debe separar por comas, por ejemplo `[PBMoves::CHATTER, PBMoves::DIG, PBMoves::TELEPORT, PBMoves::SONICBOOM, PBMoves::DRAGONRAGE, PBMoves::STRUGGLE]`

### Evento Iniciales

En el evento de los iniciales se debe generar una nueva pagina con la condicion de que el switch del random este activo

1. En el evento hay que agregar una sentencia de tipo script con esta linea `SpeciesIntro.new(pbGet(803)).set_mark_as_seen(false).show` 803 es el id de la variable que se usa para guardar el primer inicial random, para el segundo inicial se usa la variable 804 y para el tercero 805
2. Luego si el jugador confirma que quiere ese inicial
   1. Hay que desactivar el control switch del random
   2. Hay que agregar otra sentencia de tipo script con esta linea `pbAddPokemon(pbGet(803),5)` para que se le asigne el inicial random que se generó al activar el random y que el jugador no pueda reiniciar hasta que le salga el inicial que quiere
   3. Luego hay que volver a activar el switch del random
      Aqui dejo un ejemplo del evento, las partes importantes están marcadas con un cuadro rojo
      ![Evento Iniciales](images/evento_inicial_random.png)
