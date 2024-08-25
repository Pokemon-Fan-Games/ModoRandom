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

Si se quiere deshabilitar la progresivadad del random hay que poner la variable `PROGRESSIVE_RANDOM` del script `000_Config.rb` en `false`

Se puede hacer que los pokémon iniciales salgan de un listado definido por el maker, para se debe actualizar el script `000_Config.rb` en la variable `RANDOM_STARTERS_LIST` se deben separar los Pokémon por comas, por ejemplo `[:BULBASAUR, :CHARMANDER, :SQUIRTLE, :PIDGEY, :NIDORANmA, :NIDORANfE]`
Si este listado está vacío los iniciales serán 100% random respetando las restricciones de generaciones, BST y blacklist de pokémon.

También se pueden randomizar los objetos obtenidos, para eso en los eventos que dan objetos hay que checkear si el switch del random está activo, si lo está en lugar de llamar a pbItemBall, hay que llamar `random_item_from_pokeball()` abajo dejo un ejemplo de como hacerlo.

En el script `003_Objetos.rb` hay una variable `ITEM_BLACK_LIST` que contiene los objetos que no se pueden obtener, del evento de arriba, si se quiere restringir más de un objeto se debe separar por comas, por ejemplo `[:LOPUNNYTE, :SACREDASH, :BLACKFLUTE]`

También hay una variable `MTLIST_RANDOM` que debe contener las MTs, para que si el objeto que se randomizó es una MT que ya tienes se genere otra MT distinta, las distintas MTs se deben separar por comas, por ejemplo `[:TM01, :TM02, :TM03]`

### Configuraciones Base

- Si quieres desactivar el randomizado de los movimientos, en el script `000_Config.rb` hay una variable que se llama `RANDOM_MOVES_DEFAULT_VALUE` por defecto está en `true` si la cambias a `false` no se randomizarán los movimientos
- Si quieres activar el randomizado de la compatibilidad con las MTs, en el script `000_Config.rb` hay una variable que se llama `RANDOM_TM_COMPAT` por defecto está en `false` si la cambias a `true` se randomizará la compatibilidad con las MTs
- Se puede restringir qué pokémon salen en el random, para eso se debe modificar el script `000_Config.rb` en la variable `BLACKLISTED_POKEMON` si se quiere restringir más de un pokémon se debe separar por comas, por ejemplo `[:ARTICUNO, :MOLTRES, :ZAPDOS]`
- Se puede restringir qué habilidades salen en el random, para eso se debe modificar el script `000_Config.rb` en la variable `ABILITY_EXCLUSIONS` si se quiere restringir más de una habilidad se debe separar por comas, por ejemplo `[:IMPOSTER, :ZENMODE, :WONDERGUARD]`
- Se pueden restringir qué movimientos salen en el random, para eso se debe modificar el script `000_Config.rb` en la variable `MOVEBLACKLIST` si se quiere restringir más de un movimiento se debe separar por comas, por ejemplo `[:CHATTER, :DIG, :TELEPORT, :SONICBOOM, :DRAGONRAGE, :STRUGGLE]`
- Si quieres desactivar que el random sea progresivo, en el script `000_Config.rb` hay una variable que se llama `PROGRESSIVE_RANDOM_DEFAULT_VALUE` por defecto está en `true` si la cambias a `false`, el random no será progresivo, por lo que desde la ruta 1 te podrian salir Pokémons legendarios a menos que esten inluídos en la blacklist
- Se puede elegir como funciona el random de las habilidades, si es 100% random por especie o si mapea una habilidad a otra, o directamente no randomizar las habilidades.
  Unos ejemplos:
  - **Opción 1:** 100% random -> Para esta opcion hay que poner la constante `RANDOM_ABILITY_METHOD` que está en el script `000_Config.rb` en `:FULLRANDOM`
  Ejemplo Pikachu tendra Intimidación y Cura Natural, pero Raichu podría tener otras distintas, como Absorbe agua y levitación
  - **Opción 2:** Mapeo de habilidades -> Para esta opcion hay que poner la constante `RANDOM_ABILITY_METHOD` que está en el script `000_Config.rb` en `:MAPABILITIES`
  Ejemplo Intimidación se convierte en Inicio Lento, lo que no significa, que Inicio Lento se convierta en Intimidación
  - **Opción 3:** Se mantienen las habilidades al evolucionar -> Para esta opcion hay que poner la constante `RANDOM_ABILITY_METHOD` que está en el script `000_Config.rb` en `:SAMEINEVOLUTION`
  
  Cualquier valor distinto a alguno de estos 3 hará que las habilidades no se randomicen.
  
  _Quiero agradecer a los creadores del Plugin Randomizer EX (Abilities), Golisopod User, CrimsonTY, Luka SJ, que es el utilizado para randomizar las habilidades._

- Si quieres cambiar las variables destinadas a los iniciales random puedes cambiarlas en la constante `STATERS_VARIABLES`

### Opciones de randomización

1. **Randomizar movimientos**
   - random_moves_on? -> Devuelve si los movimientos están randomizados, esto es mas que nada por si en un evento le quieren informar al usuario el estado de esta opción del random
   - toggle_random_moves -> Permite cambiar el estado de los movimientos randomizados, si estaban en true los pone en false y viceversa
2. **Random Progresivo**
   - progressive_random_on? -> Similar al primer metodo, devuelve si la progresividad del random está activa
   - toggle_progressive_random -> Permite cambiar el estado de la progresividad del random, si estaba en true lo pone en false y viceversa

3. **Randomizar compatibilidad con las MTs**
   - random_tm_compat_on? -> Similar al primer metodo, devuelve si la compatibilidad con las MTs está randomizada
   - toggle_random_tm_compat -> Permite cambiar el estado de la compatibilidad con las MTs, si estaba en true lo pone en false y viceversa

4. **Randomizar habilidades**
   - choose_random_ability_mode -> Permite cambiar el modo de random de las habilidades, recibe en el modo esperado :FULL_RANDOM_ABS para el modo full random (la opcion 1 mencionanda mas arriba) o :MAP_RANDOM_ABS para el modo de mapeo de habilidades (la opcion 2 mencionanda mas arriba)

   Tengan en cuenta de que cambiar el modo de las habilidades las regenerará, por lo que si el jugador ya tiene un pokémon con habilidades randomizadas, estas se perderán

5. **Randomizar evoluciones**
   - `random_evos_on?`, `random_evos_similar_bst_on?` -> Permiten validar si los las evoluciones están randomizadas y si el BST de las evoluciones debe ser similar al de la evolución original
   - `toggle_random_evos`, `toggle_random_evos_similar_bst` -> para poder activar y desactivar fácilmente el random de evoluciones

6. **Randomizar tipos de los Pokémon**
   - `random_types_enabled?` Devuelve true si los tipos random están activados, de lo contrario devuelve false
   - `toggle_random_types` Permite cambiar el estado de los tipos random, si estaba en true lo pone en false y viceversa

### Objetos Random

Hay 4 constantes de configuracion relacionadas con los objetos random

- `ITEM_BLACK_LIST` -> Lista de objetos que no se pueden obtener, por ejemplo `[:LOPUNNYTE, :SACREDASH, :BLACKFLUTE]`. Los objetos clave nunca se generarán
- `UNRANDOMIZABLE_ITEMS` -> Lista de objetos que si son dadas en algun evento no serán randomizados. Los objetos clave nunca se randomizarán
- `MT_GET_RANDOMIZED_TO_ANOTHER_MT` -> Si es true, las MTs serán randomizadas a otra MT
- `MTLIST_RANDOM` -> Listado de MTs que pueden ser generadas en el random, si este listado está vacío cualquier MT podrá salir en el random

### Opciones por defecto

- `FULL_RANDOM_ABS = true` o `MAP_RANDOM_ABS = true` -> Esto determina el modo de random de las habilidades, si no se predefine ninguna de estas constantes, las habilidades no se randomizarán, si ambas están en true se utilizará la opcion 1
- `PROGRESSIVE_RANDOM_DEFAULT_VALUE = true o false` -> Esto determina si la progresividad del random está activa, el usuario podría cambiar esta opción si le crean un evento que llame al método toggle_progressive_random
- `RANDOM_MOVES_DEFAULT_VALUE = true o false` -> Esto determina si los movimientos están randomizados, el usuario podría cambiar esta opción si le crean un evento que llame al método toggle_random_moves
- `RANDOM_TM_COMPAT_DEFAULT_VALUE = true o false` -> Esto determina si la compatibilidad con las MTs está randomizada, el usuario podría cambiar esta opción si le crean un evento que llame al método toggle_random_tm_compat
- `RANDOM_EVOS_DEFAULT_VALUE` -> Esto determina si las evoluciones están randomizadas, el usuario puede cambiar esta opción si le crean un evento que llame al método `toggle_random_evos`
- `RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE` -> Esto determina si las evoluciones random deben tener un BST similar a la evolución original. El usuario puede cambiar esta opción si le crean un evento que llame al método `toggle_random_evos_similar_bst`
- `RANDOM_TYPES_DEFAULT_VALUE` -> Esto determina si los tipos random están activados, el usuario puede cambiar esta opción si le crean un evento que llame al método `toggle_random_types`
- `INVALID_TYPES` -> Esto determina los tipos que nunca podran salir en el random, por defecto solo tiene el tipo QMARKS

Los valores por defecto para estas constantes son:

- `FULL_RANDOM_ABS = true`
- `MAP_RANDOM_ABS = false`
- `PROGRESSIVE_RANDOM_DEFAULT_VALUE = true`
- `RANDOM_MOVES_DEFAULT_VALUE = true`
- `RANDOM_TM_COMPAT_DEFAULT_VALUE = false`
- `RANDOM_EVOS_DEFAULT_VALUE = false`
- `RANDOM_EVOS_SIMILAR_BST_DEFAULT_VALUE = false`
- `RANDOM_TYPES_DEFAULT_VALUE = false`
- `INVALID_TYPES = [:QMARKS]`

## Implementación

1. Descargar el zip "ModoRandom.zip" desde [aquí](https://github.com/Pokemon-Fan-Games/ModoRandom/releases/download/21_LBDSKY_v1.4.0/ModoRandom.zip)
2. Copiar la carpeta del zip dentro de la carpeta de tu juego.
3. En La Base de Sky en el Mapa de Scripts pueden encontrar todos los eventos para el random, estos son el activador/configurador, el de las balls para cada inicial random y el de las Pokeball con objetos random
![eventos](images/eventosLBDSKY.png)
