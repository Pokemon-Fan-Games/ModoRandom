# Modo Random

## Descripción

El modo random randomizará ataques y habilidades de los pokémon tanto de entrenadores como de los salvajes, se puede activar que también se randomice la compatibilidad con las MTs, se podrá restringir las generaciones de los pokémon que apareceran en el random.

El random es progresivo en base a la cantidad de medallas del jugador, entre más medallas tenga salen pokémon con más BST, aquí dejo la formula, que la pueden modificar en el metodo `max_bst_cap` y `min_bst_cap`

- 0 y 1 medalla BST min 0 y BST max 400
- 2 medallas BST min 0 y BST max 440
- 3 medallas BST min 350 y BST max 480
- 4 medallas BST min 375 y BST max 520
- 5 medallas BST min 400 y BST max 560
- 6 medallas BST min 425 y BST max 600
- Más de 6 medallas BST min 440 y BST max 800

También si el jugador tiene menos de 3 medallas no pueden salir movimientos con más de 70 de poder base.

Si se quiere deshabilitar la progresivadad del random hay que poner la variable `PROGRESSIVE_RANDOM` del script `Random.rb` en `false`

Se puede hacer que los pokémon iniciales salgan de un listado definido por el maker, para se debe actualizar el script `Random.rb` en la variable `ListaStartersRandomizado` se deben separar los Pokémon por comas, por ejemplo `[PBSpecies::BULBASAUR,PBSpecies::CHARMANDER,PBSpecies::SQUIRTLE, PBSpecies::PIDGEY,PBSpecies::NIDORANmA,PBSpecies::NIDORANfE,PBSpecies::ZUBAT,PBSpecies::MANKEY,PBSpecies::POLIWAG, PBSpecies::ABRA]`
Si este listado está vacío los iniciales serán 100% random respetando las restricciones de generaciones, BST y blacklist de pokémon.

También se randomizarán los objetos pueden leer la sección [Objetos Random](#objetos-random) para más información

## Configuraciones Base

### Pokemón Random

- Se puede restringir qué pokémon salen en el random, para eso se debe modificar el script `Random.rb` en la variable `BlackListedPokemon` si se quiere restringir más de un pokémon se debe separar por comas, por ejemplo `[PBSpecies::ARTICUNO,PBSpecies::MOLTRES, PBSpecies::ZAPDOS]`
- Si quieres desactivar que el random sea progresivo, en el script `Random.rb` hay una variable que se llama `PROGRESSIVE_RANDOM_DEFAULT_VALUE` por defecto está en `true` si la cambias a `false`, el random no será progresivo, por lo que desde la ruta 1 te podrian salir Pokémons legendarios a menos que esten inluídos en la blacklist
- Si quieres cambiar las variables destinadas a los iniciales random puedes cambiarlas en la constante `STATERS_VARIABLES`
- `ENABLE_RANDOM_FORM` esto permite que salgan formas alternas de los pokemon como las regionales (solo podrá salir la 1) y nunca podrán salir formas megas o primigenias en salvajes o entrenadores, por defecto es `true` algo importante a aclarar es que si no tienen bien mantenidas las formas alternas puede generar resultados inesperados.
- `MEGAS_RANDOMIZE_TO_MEGAS` si se activa, los Pokémon de entrenadores que originalmente eran megas, tenian la megapiedra asignada, se convertirán en otro Pokémon con mega, requiere mantener el hash `POKEMON_MEGA_STONES` que relacione al Pokémon con su mega piedra, en el script `Random.rb` hay un ejemplo comentado.

#### Evoluciones Random

- Para el modo full random
  - Hay que poner la constante `RANDOM_EVOS_DEFAULT_VALUE = true` en el script `Random.rb`
- Para el modo con BSTs similares
  - Hay que poner la constante `RANDOM_EVOS_DEFAULT_VALUE = true` en el script `Random.rb`
  - Y la constante `RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE = true` en el script `Random.rb`
  - Tambien se puede configurar el margen de bst similares con `EVO_BST_MARGIN`

#### Tipos Random

- Se agregó la opción de tipos random.
  - Con esta opcion de agregaron 2 constantes en la configuracion
    - `RANDOM_TYPES_DEFAULT_VALUE` para activar el random de tipos, por defecto es false
    - `INVALID_TYPES` es un listado para excluir tipos del randomizado, por defecto solo tiene el tipo QMARKS
  - También se crearon 2 métodos
    - `random_types_enabled?` Devuelve true si los tipos random están activados, de lo contrario devuelve false
    - `toggle_random_types` Permite cambiar el estado de los tipos random, si estaba en true lo pone en false y viceversa

### Movimientos Random

- Si quieres desactivar el randomizado de los movimientos, en el script `Random.rb` hay una variable que se llama `RANDOM_MOVES_DEFAULT_VALUE` por defecto está en `true` si la cambias a `false` no se randomizarán los movimientos
- Si quieres activar el randomizado de la compatibilidad con las MTs, en el script `Random.rb` hay una variable que se llama `RANDOM_TM_COMPAT` por defecto está en `false` si la cambias a `true` se randomizará la compatibilidad con las MTs
- Se pueden restringir qué movimientos salen en el random, para eso se debe modificar el script `Random.rb` en la variable `MOVEBLACKLIST` si se quiere restringir más de un movimiento se debe separar por comas, por ejemplo `[PBMoves::CHATTER, PBMoves::DIG, PBMoves::TELEPORT, PBMoves::SONICBOOM, PBMoves::DRAGONRAGE, PBMoves::STRUGGLE]`

### Objetos Random

- `ITEM_BLACK_LIST` es un listado para excluir objetos del randomizado
- `MTLIST_RANDOM` Listado de MTs que pueden salir como objetos random, si la lista está vacía cualquier MT podrá salir en el modo random
- `UNRANDOMIZABLE_ITEMS` Listado de objetos que no pueden ser randomizados, es decir si son dados en un evento no se randomizarán
- `MT_GET_RANDOMIZED_TO_ANOTHER_MT` Las MTs dadas en un evento son randomizadas por otra MT que el jugador no tenga ya.
- `RANDOMIZE_WILD_ITEMS` Si se activa la constante se randomizará el objeto del pokémon salvaje
- `HELD_ITEM_BLACKLIST` Listado de objetos que no pueden salir en objetos de Pokémon salvajes, es una inclusion adicional sería la blacklist base + este listado.

### Habilidades Random

- Se puede restringir qué habilidades salen en el random, para eso se debe modificar el script `Random.rb` en la variable `ABILITYBLACKLIST` si se quiere restringir más de una habilidad se debe separar por comas, por ejemplo `[PBAbilities::IMPOSTER, PBAbilities::ZENMODE, PBAbilities::WONDERGUARD]`

- Se puede elegir como funciona el random de las habilidades, si es 100% random por especie o si mapea una habilidad a otra, o directamente no randomizar las habilidades.
  Unos ejemplos:
  - **Opción 1:** 100% random -> Para esta opcion hay que poner la constante `FULL_RANDOM_ABS` que está en el script `Random.rb` en `true`
  Ejemplo Pikachu tendra Intimidación y Cura Natural, pero Raichu podría tener otras distintas, como Absorbe agua y levitación
  - **Opción 2:** Mapeo de habilidades -> Para esta opcion hay que poner la constante `MAP_RANDOM_ABS` que está en el script `Random.rb` en `true`
  Ejemplo Intimidación se convierte en Inicio Lento, lo que no significa, que Inicio Lento se convierta en Intimidación
  
  Si ninguna de las 2 constantes está en `true` no se randomizarán las habilidades.
  Si ambas constantes están en `true` se utilizará la opción 1.

### Con la version 1.2.0

Hay varias mejoras, ahora se puede decidir si los movimientos están randomizados o no, se agregaron un total de 7 metodos nuevos para que como maker puedan darle la opcion al jugador de configurar el random a su gusto, estos metodos son:

- random_moves_on? -> Devuelve si los movimientos están randomizados, esto es mas que nada por si en un evento le quieren informar al usuario el estado de esta opción del random
- toggle_random_moves -> Permite cambiar el estado de los movimientos randomizados, si estaban en true los pone en false y viceversa
- progressive_random_on? -> Similar al primer metodo, devuelve si la progresividad del random está activa
- toggle_progressive_random -> Permite cambiar el estado de la progresividad del random, si estaba en true lo pone en false y viceversa
- random_tm_compat_on? -> Similar al primer metodo, devuelve si la compatibilidad con las MTs está randomizada
- toggle_random_tm_compat -> Permite cambiar el estado de la compatibilidad con las MTs, si estaba en true lo pone en false y viceversa
- choose_random_ability_mode -> Permite cambiar el modo de random de las habilidades, recibe en el modo esperado :FULL_RANDOM_ABS para el modo full random (la opcion 1 mencionanda mas arriba) o :MAP_RANDOM_ABS para el modo de mapeo de habilidades (la opcion 2 mencionanda mas arriba)
  Tengan en cuenta de que cambiar el modo de las habilidades las regenerará, por lo que si el jugador ya tiene un pokémon con habilidades randomizadas, estas se perderán

Se creó el metodo enable_random para facilitar la activacion del random, en el evento solo llamán a este metodo y el random se activará con las opciones que se hayan predefinido en el script, las opciones que se pueden predefinir son:

- `FULL_RANDOM_ABS = true` o `MAP_RANDOM_ABS = true` -> Esto determina el modo de random de las habilidades, si no se predefine ninguna de estas constantes, las habilidades no se randomizarán, si ambas están en true se utilizará la opcion 1
- `PROGRESSIVE_RANDOM_DEFAULT_VALUE = true o false` -> Esto determina si la progresividad del random está activa, el usuario podría cambiar esta opción si le crean un evento que llame al método toggle_progressive_random
- `RANDOM_MOVES_DEFAULT_VALUE = true o false` -> Esto determina si los movimientos están randomizados, el usuario podría cambiar esta opción si le crean un evento que llame al método toggle_random_moves
- `RANDOM_TM_COMPAT_DEFAULT_VALUE = true o false` -> Esto determina si la compatibilidad con las MTs está randomizada, el usuario podría cambiar esta opción si le crean un evento que llame al método toggle_random_tm_compat

Los valores por defecto para estas constantes son:

- `FULL_RANDOM_ABS = true`
- `MAP_RANDOM_ABS = false`
- `PROGRESSIVE_RANDOM_DEFAULT_VALUE = true`
- `RANDOM_MOVES_DEFAULT_VALUE = true`
- `RANDOM_TM_COMPAT_DEFAULT_VALUE = false`

### Versión 1.3.0

- Se agregó la opcion de evoluciones random, ya sea con BSTs similares o full random.
  - Para el modo full random
    - Hay que poner la constante `RANDOM_EVOS_DEFAULT_VALUE = true` en el script `Random.rb`
  - Para el modo con BSTs similares
    - Hay que poner la constante `RANDOM_EVOS_DEFAULT_VALUE = true` en el script `Random.rb`
    - Y la constante `RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE = true` en el script `Random.rb`
    - Tambien se puede configurar el margen de bst similares con `EVO_BST_MARGIN`

- Se agregaron los métodos `are_random_evos_on`, `toggle_random_evos`, `are_random_evos_similar_bst_on` y `toggle_random_evos_similar_bst` para poder activar y desactivar fácilmente el random de evoluciones

### Versión 1.4.0

- Se agregó la opción de tipos random.
  - Con esta opcion de agregaron 2 constantes en la configuracion
    - `RANDOM_TYPES_DEFAULT_VALUE` para activar el random de tipos, por defecto es false
    - `INVALID_TYPES` es un listado para excluir tipos del randomizado, por defecto solo tiene el tipo QMARKS
  - También se crearon 2 métodos
    - `random_types_enabled?` Devuelve true si los tipos random están activados, de lo contrario devuelve false
    - `toggle_random_types` Permite cambiar el estado de los tipos random, si estaba en true lo pone en false y viceversa

## Implementación

1. Descargar el zip "ModoRandom.zip" desde [aquí](https://github.com/Pokemon-Fan-Games/ModoRandom/releases/download/16_BES_v1.5.0/ModoRandom.zip)
2. Crear los 3 scripts que están en el zip, arriba del script Main
3. Crear el siguiente NPC para activar el modo random
   1. **Ejemplo del evento activación y configuración del random**
      1. Crear un Label llamado "Inicio"
      2. Crear una conditional branch de si el random está activo, para esto la condicion debe ser un script con el llamado a `random_enabled?`
      3. Dentro del true de esa conditional branch crear un label llamado "Choices"
      4. Agregar un show choices con las distintas configuraciones del random y la opcion para desactivarlo, en mi caso llamé a las choices "Configurar Random", "Restringir Generaciones" y "Desactivar Random" y puse la opción 4 como vacía para el cancel
         1. Dentro de la opción "Configurar Random"
            1. Crear un label llamado "Opciones"
            2. Hay que poner un conditional branch con el script `show_config_options != -1`. En el true hacen un Jump to Label "Opciones"
            3. En el else ponen un Jump to Label "Choices"
         2. Dentro de la opción "Restringir Generaciones"
            1. Crear un label llamado "Gens"
            2. Hay que poner un conditional branch con el script `show_gens_chooser != -1`. En el true hacen un Jump to Label "Gens"
            3. En el else ponen un Jump to Label "Choices"
         3. Dentro de la opcion "Desactivar Random"
            1. Piden una confirmacion para la desactivación con un Show Choices de Sí/No
            2. En el Sí:
               1. Llaman al script `disable_random`
               2. Muestran un mensaje de que el random fue desactivado
               3. Hacen un Exit Event Processing
            3. En el No:
               1. Hacen un Jump to Label "Choices"
      5. En el false de la primer conditional branch ponen un show choices de Sí o No para activar el random.
         1. Piden la confirmacion para activar el random y muestran un Show Choices de Sí/No
         2. En el Sí:
            1. Llaman al script `enable_random`
            2. Muestran un mensaje de que el random fue activado
         3. En el No:
            1. No hace falta hacer nada

   Aquí dejo unas imagenes de como se veria el evento
   ![evento_configuracion](images/evento_configuracion.png)
   ![opciones random](images/opciones_random.png)
   ![restringir generaciones](images/restringir_gens.png)

### Evento Iniciales

En el evento de los iniciales se debe generar una nueva página con la condición de que el switch del random este activo

1. En el evento hay que agregar una sentencia de tipo script con esta linea `SpeciesIntro.new(pbGet(803)).set_mark_as_seen(false).show` 803 es el id de la variable que se usa para guardar el primer inicial random, para el segundo inicial se usa la variable 804 y para el tercero 805, estas variables se pueden cambiar en la constante `STATERS_VARIABLES`
2. Luego si el jugador confirma que quiere ese inicial

   1. Hay que desactivar el control switch del random
   2. Hay que agregar otra sentencia de tipo script con esta linea `pbAddPokemon(pbGet(803),5)` para que se le asigne el inicial random que se generó al activar el random y que el jugador no pueda reiniciar hasta que le salga el inicial que quiere
   3. Luego hay que volver a activar el switch del random

      Aquí dejo un ejemplo del evento, las partes importantes están marcadas con un cuadro rojo

      ![Evento Iniciales](images/evento_inicial_random.png)
