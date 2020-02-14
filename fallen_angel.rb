require 'rubygems'
require 'gosu'

SCREEN_WIDTH = 715
SCREEN_HEIGHT = 471
SCALE = 0.2

#enumeration Zorder initialised
module ZOrder
  BACKGROUND, GOLEM, PLAYER, UI = *0..3
end

class Player
  attr_accessor :score, :images, :image, :slash, :attack, :dead, :x, :y, :w, :h, :radius, :lives, :animation

  def initialize()
    #Initialise player image
    @image = Gosu::Image.new("media/Fallen_Angel/Idle/0_Fallen_Angels_Idle_01.png")

    @attack = false #default
    @dead = false #false till player loose all lives

    @animation = false 
    
    @radius = 10
    @x = 200
    @y = 300

    @w = @x - 50
    @h = @y - 50

    @score = 0 
    @lives = 3 
  end
end


def warp(player, x, y)
  player.x, player.y = x, y
end

#moves the player
def move_left player
  player.x -= 2
  player.x %= (SCREEN_WIDTH - 50)
end

def move_right player
  player.x += 2
  player.x %= (SCREEN_WIDTH - 50)
end

def move_up player
  player.y -= 2
  player.y %= (SCREEN_HEIGHT - 100)
end

def move_down player
  player.y += 2
  player.y %= (SCREEN_HEIGHT - 100)
end

#Animation when player is walking
def walking player
  player.attack = false
  player.animation = true
  player.images = (1...11).map do |i|
    Gosu::Image.new("media/Fallen_Angel/Running/0_Fallen_Angels_Running_0#{i}.png")
  end
end

#Animation when player is slashing
def slashing player
  player.attack = true
  player.animation = true
  player.images = (1...11).map do |i|
    Gosu::Image.new("media/Fallen_Angel/Slashing/0_Fallen_Angels_Slashing_0#{i}.png")
  end
end


def draw_player player
  #Show animation
  if player.animation == true
    player.image = @player.images[Gosu.milliseconds / 80 % player.images.size]
    player.image.draw(@player.x - 50 , @player.y - 50, ZOrder::PLAYER, SCALE, SCALE)
  else #show image
    player.image.draw(@player.x - 50, @player.y - 50, ZOrder::PLAYER, SCALE, SCALE)
  end

end

def attack_golem(golems, player)
  #Removes golem after it gets attacked
  golems.reject! do |golem|
  if Gosu.distance(player.x, player.y, golem.x - 200, golem.y) < 80  
    if player.attack == true 
        player.score += 1
        true
      else #Reduce a life when player didn't attack the golem, when it's in her radius
        if (player.lives > 1)
          player.lives -= 1
        else
          player.dead = true 
        end
      end
    else
        false
      end
    
  end
end


class Golem
  attr_accessor :x, :y, :vel_x, :vel_y, :image, :x, :y, :radius, :level

  def initialize(image)
  
    #Initialise Golem Image
    @image = Gosu::Image.new(image);

    @radius = 10

    @vel_x = rand(-2..-1)
    @vel_y = rand(-2..2)

    @x = SCREEN_WIDTH #Only send golems from x = SCREEN_WIDTH
    @y = rand(150..400) 

  end
end

#Moves the golem around
def move golem
  golem.x += golem.vel_x
  golem.x %= (SCREEN_WIDTH - 50) 
  golem.y %= (SCREEN_HEIGHT - 100)
end

#Draw Golem Image
def draw_golem golem
  golem.image.draw(golem.x - 50, golem.y - 50, ZOrder::GOLEM, -SCALE, SCALE)
end


class FallenAngel < (Example rescue Gosu::Window)
  
  def initialize

    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Fallen Angel"

    #Start background image assigned
    @start_background_image = Gosu::Image.new("media/background/start_background.jpg", :tileable => true)

    #Start background music aasigned
    @background_music = Gosu::Song.new("media/Sounds/music.mp3")
    @background_music.play(true)
 
    @info_font = Gosu::Font.new(20)

    @scene = :start #Show Start scene
    @level = 0

  end

  #When start scene, initialse start
  def initialize_start
    @start_background_image = Gosu::Image.new("media/background/start_background.jpg", :tileable => true)
    @background_music = Gosu::Song.new("media/Sounds/music.mp3")
    @background_music.play(true)
    
    @scene = :start
    @level = 0
  end  

  #When Game scene, initialise game
  def initialize_game(level)
    @scene = :game
    @level = level #level is choosen from what the user selected from start menu
    
    #background image for level 1
    @background_image_1 = Gosu::Image.new("media/background/background_1.jpg", :tileable => true)
    #background image for level 2
    @background_image_2 = Gosu::Image.new("media/background/background_2.png", :tileable => true)
    #background image for level 3
    @background_image_3 = Gosu::Image.new("media/background/background_3.png", :tileable => true)

    #Game music
    @game_music = Gosu::Song.new("media/Sounds/game_music.mp3")
    @game_music.play(true)

    @player = Player.new()
    @golems = Array.new

    warp(@player, 10, 250)

    @font = Gosu::Font.new(20)
    
  end 

  #when End scene, initialise end
  def initialize_end
    @end_background_image = Gosu::Image.new("media/background/end_background.jpg", :tileable => true)
    @end_music = Gosu::Song.new("media/Sounds/music.mp3")
    @end_music.play(true)
    @scene = :end
  end

  #when game scene, update game
  def update_game(level)
    if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::GP_LEFT
      move_left @player
    end
    if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
      move_right @player
    end
    if Gosu.button_down? Gosu::KB_UP or Gosu.button_down? Gosu::GP_BUTTON_0
      move_up @player
    end
    if Gosu.button_down? Gosu::KB_DOWN or Gosu.button_down? Gosu::GP_BUTTON_9
      move_down @player
    end

    #generate golems
    if rand(100) < 2 and @golems.size < 4
      case level
      when 1
      @golems.push Golem.new("media/Golem_1/Walking/0_Golem_Walking_1.png")
      when 2
      @golems.push Golem.new("media/Golem_2/Running/0_Golem_Running_01.png")
      when 3
      @golems.push Golem.new("media/Golem_3/Running/0_Golem_Running_01.png") 
      end
    end
    
    @golems.each { |golem| move golem } #move each golem
    self.remove_golem #remove golems when they go out of screen
    attack_golem(@golems, @player) 
    initialize_end if @player.dead == true #When player is dead, initialise end
  end

  #Choose which scene for update
  def update
    case @scene
    when :game 
      update_game(@level)
    end
  end

  #draw background for start
  def draw_start
    @start_background_image.draw(0, 0, ZOrder::BACKGROUND)
  end
  
  #when game scene, draw game
  def draw_game
    case @level
    when 1
      @background_image_1.draw(0, 0, ZOrder::BACKGROUND)
    when 2
      @background_image_2.draw(0, 0, ZOrder::BACKGROUND)
    when 3
      @background_image_3.draw(0, 0, ZOrder::BACKGROUND)
    end
    draw_player @player
    @golems.each { |golem| draw_golem golem}
    #Display score of player
    @font.draw_markup("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
    #Dsiplay lives of Player
    @font.draw_markup("Lives: #{@player.lives}", 600, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::WHITE)
  end

  #Draw end
  def draw_end
    @end_background_image.draw(0, 0, ZOrder::BACKGROUND)
  end

  #Selects which to draw, according to scene.
  def draw
    case @scene
    when :start
      draw_start
    when :game 
      draw_game
    when :end
      draw_end
    end
  end

  #Removes golems when goes out of the scene
  def remove_golem
    @golems.reject! do |golem|
      if golem.x > SCREEN_WIDTH || golem.y > SCREEN_HEIGHT || golem.x < 0 || golem.y < 0
        true
      else
        false
      end
    end
  end

  def needs_cursor?; true; end

  #Start scene menu selection
  def start_area_clicked(mouse_x, mouse_y)
    if ((mouse_x > 288 and mouse_x < 457) and (mouse_y > 200 and mouse_y < 220))
      @level = 1
      true
    elsif ((mouse_x > 288 and mouse_x < 457) and (mouse_y > 246  and mouse_y < 267))
       @level = 2
       true
    elsif ((mouse_x > 288 and mouse_x < 457) and (mouse_y > 290 and mouse_y < 312))
       @level = 3
       true
    else
      false
     end
  end

  #End scence menu selection
  def end_area_clicked(mouse_x, mouse_y)
    if ((mouse_x > 76 and mouse_x < 198) and (mouse_y > 160 and mouse_y < 180))
      @select = 1
      true
    elsif ((mouse_x > 78 and mouse_x < 200) and (mouse_y > 200  and mouse_y < 218))
       @select = 2
       true
    elsif ((mouse_x > 81 and mouse_x < 200) and (mouse_y > 240 and mouse_y < 259))
       @select = 3
       true
    else
      false
     end
  end

  #when selection is made in the end scene, do what is selected
  def selection(select)
    case select
    when 1
      initialize_game(@level)
    when 2
      initialize_start
    when 3
      close
    end
  end

  #when left mouse button is clicked in start scene, initialise game in chosen level
  def button_down_start(id)
    case id
    when Gosu::MsLeft
      if start_area_clicked(mouse_x, mouse_y)
        initialize_game(@level)
      end
    end
  end 

  #When space bar is pressed in game scene, player attacks
  def button_down_game(id)
    if id == Gosu::KB_SPACE
      slashing @player 
    end
  end

  #In end scene, if left mouse button is clicked, calls out selection function
  def button_down_end(id)
    case id
    when Gosu::MsLeft
      if end_area_clicked(mouse_x, mouse_y)
        selection(@select)
      end
    end
  end

  #According to which scene, button down function is called out
  def button_down(id)
    case @scene
    when :start
      button_down_start(id)
    when :game
      button_down_game(id)
    when :end
      button_down_end(id)
    end
  end

  
  #when button is up in game, player animation of walking is drawn
  def button_up(id)
    if id == Gosu::KB_SPACE
      walking @player 
    end
  end

end


FallenAngel.new.show if __FILE__ == $0
