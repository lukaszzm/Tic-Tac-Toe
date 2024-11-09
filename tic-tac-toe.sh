#!/bin/bash

declare -a board

rows=3
columns=3

empty=0
x_player=1
o_player=2

function initialize_matrix {
  local max=$((rows*columns))

    for ((i=0; i<max; i++)); do
        board[$i]=$empty
    done
}

function print_guide {
    echo "------------------------------------GUIDE------------------------------------"
    echo "The board is numbered as follows:"
    echo " 1 | 2 | 3 "
    echo "-----------"
    echo " 4 | 5 | 6 "
    echo "-----------"
    echo " 7 | 8 | 9 "

    echo "To make a move, enter the number of the place you want to put your symbol in"
    echo "-----------------------------------------------------------------------------"
}

function print_matrix {
    echo "------------------------------------BOARD------------------------------------"

    for ((i=0; i<rows; i++)); do
      print_row "$i"
      if [ "$i" -ne $((rows-1)) ]; then
        echo "-----------"
      fi
    done

    echo "-----------------------------------------------------------------------------"
}

function print_row {
    local row=$i

    for ((j=0; j<columns; j++)); do
        local current_place=$((row*columns+j))

        print_symbol ${board[$current_place]}

        if [ "$j" -ne $((columns-1)) ]; then
            echo -n "|"
        fi
    done

    echo ""
}

function print_symbol {
    local symbol=$1

    if [ "$symbol" -eq $empty ]; then
        echo -n "   "
    elif [ "$symbol" -eq $x_player ]; then
        echo -n " X "
    elif [ "$symbol" -eq $o_player ]; then
        echo -n " O "
    fi
}

function check_winner {

  # Check rows
  for ((i=0; i<rows; i++)); do
    local row=$((i*columns))
    if [ ${board[$row]} -eq $x_player ] && [ ${board[$row+1]} -eq $x_player ] && [ ${board[$row+2]} -eq $x_player ]; then
      echo "First player wins [X]!"
      exit 0
    elif [ ${board[$row]} -eq $o_player ] && [ ${board[$row+1]} -eq $o_player ] && [ ${board[$row+2]} -eq $o_player ]; then
      echo "Second player wins [O]!"
      exit 0
    fi
  done

  # Check columns
  for ((i=0; i<columns; i++)); do
    if [ ${board[$i]} -eq $x_player ] && [ ${board[$i+3]} -eq $x_player ] && [ ${board[$i+6]} -eq $x_player ]; then
      echo "First player wins [X]!"
      exit 0
    elif [ ${board[$i]} -eq $o_player ] && [ ${board[$i+3]} -eq $o_player ] && [ ${board[$i+6]} -eq $o_player ]; then
      echo "Second player wins [O]!"
      exit 0
    fi
  done

  # Check first diagonal
  if [ ${board[0]} -eq $x_player ] && [ ${board[4]} -eq $x_player ] && [ ${board[8]} -eq $x_player ]; then
    echo "First player wins [X]!"
    exit 0
  elif [ ${board[0]} -eq $o_player ] && [ ${board[4]} -eq $o_player ] && [ ${board[8]} -eq $o_player ]; then
    echo "Second player wins [O]!"
    exit 0
  fi

  # Check second diagonal
  if [ ${board[2]} -eq $x_player ] && [ ${board[4]} -eq $x_player ] && [ ${board[6]} -eq $x_player ]; then
    echo "First player wins [X]!"
    exit 0
  elif [ ${board[2]} -eq $o_player ] && [ ${board[4]} -eq $o_player ] && [ ${board[6]} -eq $o_player ]; then
    echo "Second player wins [O]!"
    exit 0
  fi
}

function check_draw {
  local max=$((rows*columns))
  local is_full=true

  for ((i=0; i<max; i++)); do
    if [ ${board[$i]} -eq $empty ]; then
      is_full=false
      break
    fi
  done

  echo "is_full: $is_full"

  if [ "$is_full" = true ]; then
    echo "It's a draw!"
    exit 0
  fi
}

function player_move {
  local player=$1
  local command=""

  echo "Player $player's turn - enter a place to put your symbol in (or type 'help' to get help): "
  read -r command

  if [ "$command" = "help" ]; then
    print_guide
    player_move "$player"
    return
  fi

  re='^[1-9]$'

  if ! [[ $command =~ $re ]] ; then
    echo "Provided value is invalid, please provide a number from 1 to 9" >&2;
    player_move "$player"
    return
  fi

  local place=$((command-1))

  if [ ${board[$place]} -ne $empty ]; then
    echo "This place is already taken, please choose another one"
    player_move "$player"
    return
  fi

  board[$place]=$player

  print_matrix

  check_winner "$player"
  check_draw
}

function play_game {
  while true; do
    player_move $x_player
    player_move $o_player
  done
}

echo "Hello, welcome to Tic-Tac-Toe game!"

initialize_matrix
play_game
