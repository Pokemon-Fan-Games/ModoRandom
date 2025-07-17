if LBDSKY::VERSION < "1.1.3"
	class ButtonOption
		include PropertyMixin

		def initialize(name, values, get_proc, set_proc)
			@name = name
			@values = [_INTL("")]
			@get_proc = get_proc
			@set_proc = set_proc
		end

		def values
			return @values
		end

		def next(current)
			return current
		end

		def prev(current)
			return current
		end

		def action(scene)
			@set_proc.call(0, scene)
		end

		def set(value, scene)
			# Do nothing when the value is changed
		end
	end

	class Window_PokemonOption < Window_DrawableCommand
		def initialize(options, x, y, width, height, is_sub_menu = false)
			@options = options
			@values = []
			@options.length.times { |i| @values[i] = 0 }
			@value_changed = false
			@is_sub_menu = is_sub_menu
			super(x, y, width, height)
		end

		def update
			oldindex = self.index
			@value_changed = false
			super
			dorefresh = (self.index != oldindex)
			if self.active && self.index < @options.length
				if @options[self.index].is_a?(ButtonOption)
						if Input.trigger?(Input::USE)
						self[self.index] = @options[self.index].prev(self[self.index])
						dorefresh = true
						@value_changed = true
						end
				else
						if Input.repeat?(Input::LEFT)
						self[self.index] = @options[self.index].prev(self[self.index])
						dorefresh = true
						@value_changed = true
						
						elsif Input.repeat?(Input::RIGHT)
						self[self.index] = @options[self.index].next(self[self.index])
						dorefresh = true
						@value_changed = true
						end
				end
			end
			refresh if dorefresh
		end
	end
	class PokemonOption_Scene
		def pbStartScene(in_load_screen = false, options_menu = :options_menu, is_sub_menu = false)
			@in_load_screen = in_load_screen
			@is_sub_menu = is_sub_menu
			# Get all options
			@options = []
			@hashes = []
			$PokemonSystem.vsync = $PokemonSystem.vsync_initial_value?
			MenuHandlers.each_available(options_menu) do |option, hash, name|
				@options.push(
					hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
				)
				@hashes.push(hash)
			end
			# Create sprites
			@viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
			@viewport.z = 99999
			@sprites = {}
			addBackgroundOrColoredPlane(@sprites, "bg", "optionsbg", Color.new(192, 200, 208), @viewport)
			@sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
				_INTL("Opciones"), 0, -16, Graphics.width, 64, @viewport
			)
			@sprites["title"].back_opacity = 0
			@sprites["textbox"] = pbCreateMessageWindow
			pbSetSystemFont(@sprites["textbox"].contents)
			@sprites["option"] = Window_PokemonOption.new(
				@options, 0, @sprites["title"].y + @sprites["title"].height - 16, Graphics.width,
				Graphics.height - (@sprites["title"].y + @sprites["title"].height - 16) - @sprites["textbox"].height,
				@is_sub_menu
			)
			@sprites["option"].viewport = @viewport
			@sprites["option"].visible  = true
			# Get the values of each option
			@options.length.times { |i| @sprites["option"].setValueNoRefresh(i, @options[i].get || 0) }
			@sprites["option"].refresh
			pbChangeSelection
			pbDeactivateWindows(@sprites)
			pbFadeInAndShow(@sprites) { pbUpdate }
		end

		def pbOptions
			pbActivateWindow(@sprites, "option") do
				index = -1
				submenu_open = false
				@close_sub_menu = false
				loop do
					Graphics.update
					Input.update
					pbUpdate
					if @close_sub_menu
						break
					end
					if @sprites["option"].index != index && !submenu_open
						pbChangeSelection
						index = @sprites["option"].index
					end
					if !submenu_open
						if @options[index].is_a?(ButtonOption)
							# Do nothing
						else
							@options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
							if (Input.trigger?(Input::USE) && @sprites["option"].index == @options.length)
								break
							end
						end
						if Input.trigger?(Input::BACK) && !submenu_open
							break
						elsif Input.trigger?(Input::USE) && @options[index].is_a?(ButtonOption) && !submenu_open
							submenu_open = true
							pbPlayDecisionSE
							@options[index].instance_variable_get(:@set_proc).call(0, self)
							submenu_open = false
						end
					end
				end
			end
		end
	
		def pbCloseSubMenu
			@close_sub_menu = true
		end
	end

	class PokemonOptionScreen
		def pbStartScreen(in_load_screen = false, options_menu = :options_menu)
			@scene.pbStartScene(in_load_screen, options_menu)
			@scene.pbOptions
			@scene.pbEndScene
		end
	end
end