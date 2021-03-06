require_relative 'player.rb'

class ComputerPlayer < Player
  def initialize(board, color, team, display = {})
    super
    @priorities = {
      Queen => 5,
      Rook => 4,
      Bishop => 3,
      Knight => 2,
      Pawn => 1,
      NullPiece => 0
    }
    @valid_moves = []
  end

  def get_move(board)
    sleep(0.4)
    best_move = pick_valuable_move
    starting_pos = best_move[0]
    @display.send(:cursor_pos=, starting_pos)
    @display.selected = starting_pos
    target_pos = best_move[1]
    @display.render
    sleep(0.4)
    @display.send(:cursor_pos=, target_pos)
    @display.render
    sleep(0.6)

    unless @board[target_pos].is_a?(NullPiece)
      @captured_pieces << @board[target_pos].to_s
    end

    @display.selected = nil
    [starting_pos, target_pos]
  end

  private
  attr_reader :valid_moves

  def pick_valuable_move
    # reset @valid_moves
    get_valid_moves

    # only process best outcomes
    if can_checkmate?
      return checkmates.sample
    elsif can_check?
      return checks.sample
    elsif can_attack?
      return attacks.first
    else
      return @valid_moves.sample
    end
  end

  def get_moveable_pieces
    @board.pieces(@team)
      .select { |piece| piece.valid_moves(@board).any? }
  end

  def get_valid_moves
    # costly step, save output to instance var
    @valid_moves = []
    get_moveable_pieces.each do |piece|
      piece.valid_moves(@board).each do |move|
        @valid_moves << [piece.pos, move]
      end
    end
    @valid_moves
  end

  def can_checkmate?
    !checkmates.empty?
  end

  def checkmates
    moves = []
    @valid_moves.each do |move|
    # open new process
      board_copy = @board.dup
      board_copy.move(move[0], move[1])

      moves << move if board_copy.checkmate?(opposing_team)
    end
    moves
  end

  def can_check?
    !checks.empty?
  end

  def checks
    moves = []
    @valid_moves.each do |move|
      board_copy = @board.dup
      board_copy.move(move[0], move[1])

      moves << move if board_copy.in_check?(opposing_team)
    end
    moves
  end

  def can_attack?
    !attacks.empty?
  end

  def attacks
    return @valid_moves.select do |move|
      piece = @board[move[1]]
      piece.color == opposing_team
    end.sort do |a, b|
      piece_a = @board[a[1]]
      piece_b = @board[b[1]]
      @priorities[piece_b.class] <=> @priorities[piece_a.class]
    end
  end
end
