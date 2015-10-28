class Match < ActiveRecord::Base
  before_create :prepare_game

  def whos_turn
    players[moves % players.size]
  end

  def result
    if winner.nil?
      nil
    elsif winner.zero?
      "Draw"
    else
      User.find_by(id: winner)
    end
  end

  def action(action)
    # update(state: state << action)
    # win_state = [[ nil,  nil,  nil,  nil],
    #              [ nil,  nil,  nil,  nil],
    #              [ nil,  nil,  nil,  nil],
    #              [ nil, 1024, 1024,  nil]]
    # lose_state = [[2,4,2,4],
    #               [4,2,4,2],
    #               [2,4,2,4],
    #               [4,2,4,2]]

    @game_engine = GameEngine.new(state)
    stack_to(action) unless winner

    if @game_engine.has_2048?
      update(winner: whos_turn)
    elsif @game_engine.is_over?
      update(winner: 0)
    else
      increment!(:moves) if @game_engine.valid
    end
  end

  private

  def prepare_game
    @game_engine = GameEngine.new
    self.state = @game_engine.board
  end

  def stack_to(direction)
    case direction
    when '37'
      self.state = @game_engine.stack_to_left
    when '38'
      self.state = @game_engine.stack_to_top
    when '39'
      self.state = @game_engine.stack_to_right
    when '40'
      self.state = @game_engine.stack_to_bottom
    end
    update(state: state)
  end
end